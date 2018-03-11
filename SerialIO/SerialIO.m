//
//  SerialIO.m
//  Golden Triangle
//
//  Created by 김혁 on 07/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

#import "SerialIO.h"

/////////////////////////////////////////////////////////////////////////////////////////////
//
// Serial I/O utilities
//
/////////////////////////////////////////////////////////////////////////////////////////////
static inline speed_t
serial_io_get_speed(SerialIO_Baud baud) {
  switch(baud) {
    case SerialIO_Baud_9600:
      return B9600;
    case SerialIO_Baud_19200:
      return B19200;
    case SerialIO_Baud_38400:
      return B38400;
    case SerialIO_Baud_57600:
      return B57600;
    case SerialIO_Baud_115200:
      return B115200;
  }
}

static inline tcflag_t
serial_io_get_flag(SerialIO_DataBit databit, SerialIO_Parity parity, SerialIO_StopBit stopbit) {
  tcflag_t ret = 0;
  
  switch(databit) {
    case SerialIO_DataBit_7:
      ret |= CS7;
      break;
      
    case SerialIO_DataBit_8:
      ret |= CS8;
      break;
  }
  
  switch(parity) {
    case SerialIO_Parity_Odd:
      ret |= PARODD;
      break;
      
    case SerialIO_Parity_Even:
      ret |= PARENB;
      break;
      
    case SerialIO_Parity_None:
      break;
      
  }
  
  switch(stopbit) {
    case SerialIO_StopBit_1:
      break;
      
    case SerialIO_StopBit_2:
      ret |= CSTOPB;
      break;
  }
  return ret;
}

static kern_return_t
serial_io_utility_find_serial_device (io_iterator_t *matchingServices) {
  kern_return_t           kernResult;
  CFMutableDictionaryRef  classesToMatch;
  
  classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
  if (classesToMatch == NULL)
  {
    printf("IOServiceMatching returned a NULL dictionary.\n");
  } else {
    CFDictionarySetValue(classesToMatch,
                         CFSTR(kIOSerialBSDTypeKey),
                         CFSTR(kIOSerialBSDAllTypes));
  }
  kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, matchingServices);
  if (KERN_SUCCESS != kernResult) {
    goto exit;
  }
  
exit:
  return kernResult;
}

static NSMutableArray*
serial_io_utility_get_device_path(io_iterator_t serialPortIterator) {
  io_object_t     deviceService;
  char            devicePath[MAXPATHLEN];
  NSMutableArray  *retArray;

  retArray = [[NSMutableArray alloc] init];
  
  while ((deviceService = IOIteratorNext(serialPortIterator))) {
    CFTypeRef   deviceFilePathAsCFString;
    
    devicePath[0] = '\0';
    
#if YES
    deviceFilePathAsCFString = IORegistryEntryCreateCFProperty(deviceService,
                                                               CFSTR(kIOCalloutDeviceKey),
                                                               kCFAllocatorDefault,
                                                               0);
#else
    deviceFilePathAsCFString = IORegistryEntrySearchCFProperty(
                                    deviceService,
                                    kIOServicePlane,
                                    CFSTR(kIODialinDeviceKey),
                                    kCFAllocatorDefault,
                                    kIORegistryIterateRecursively);
#endif
    if (deviceFilePathAsCFString) {
      Boolean result;
      
      result = CFStringGetCString(deviceFilePathAsCFString,
                                  devicePath,
                                  MAXPATHLEN,
                                  kCFStringEncodingASCII);
      CFRelease(deviceFilePathAsCFString);
      
      if (result)
      {
#if NO
        NSString* nsDevicePath = [NSString stringWithCString:devicePath encoding:NSASCIIStringEncoding];
#else
        NSString *nsDevicePath = @(devicePath);
#endif
        
        [retArray addObject:nsDevicePath];
      }
    }
    // Release the io_service_t now that we are done with it.
    (void) IOObjectRelease(deviceService);
  }
  return retArray;
}

static int
serial_io_utility_open(NSString* devicePath,
                       SerialIO_Baud baud,
                       SerialIO_Parity parity,
                       SerialIO_DataBit databit,
                       SerialIO_StopBit stopbit) {
  int             fileDescriptor = -1;
  struct termios  options;
  char            deviceFilePath[MAXPATHLEN];
  struct termios  originalTtyAttrs;
  
  [devicePath getCString:deviceFilePath maxLength:MAXPATHLEN encoding:NSUTF8StringEncoding];
  
  // Open the serial port read/write, with no controlling terminal,
  // and don't wait for a connection.
  // The O_NONBLOCK flag also causes subsequent I/O on the device to
  // be non-blocking.
  // See open(2) ("man 2 open") for details.
  fileDescriptor = open(deviceFilePath, O_RDWR | O_NOCTTY | O_NONBLOCK);
  if (fileDescriptor == -1) {
    NSLog(@"Error opening serial port %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    goto error;
  }
  
  // Note that open() follows POSIX semantics: multiple open() calls to
  // the same file will succeed unless the TIOCEXCL ioctl is issued.
  // This will prevent additional opens except by root-owned processes.
  // See tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details.
  if (ioctl(fileDescriptor, TIOCEXCL) == -1) {
    NSLog(@"Error setting TIOCEXCL on %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    goto error;
  }
  
  // Now that the device is open, clear the O_NONBLOCK flag so
  // subsequent I/O will block.
  // See fcntl(2) ("man 2 fcntl") for details.
#if YES
  if (fcntl(fileDescriptor, F_SETFL, 0) == -1) {
    NSLog(@"Error clearing O_NONBLOCK %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    goto error;
  }
#endif
  
  // Get the current options and save them so we can restore the
  // default settings later.
  if (tcgetattr(fileDescriptor, &originalTtyAttrs) == -1) {
    NSLog(@"Error getting tty attributes %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    goto error;
  }

  // The serial port attributes such as timeouts and baud rate are set by
  // modifying the termios structure and then calling tcsetattr to
  // cause the changes to take effect. Note that the
  // changes will not take effect without the tcsetattr() call.
  // See tcsetattr(4) ("man 4 tcsetattr") for details.
  options = originalTtyAttrs;
  
  // Print the current input and output baud rates.
  // See tcsetattr(4) ("man 4 tcsetattr") for details.
  NSLog(@"Current input baud rate is %d\n", (int) cfgetispeed(&options));
  NSLog(@"Current output baud rate is %d\n", (int) cfgetospeed(&options));

  // Set raw input (non-canonical) mode, with reads blocking until either
  // a single character has been received or a one second timeout expires.
  // See tcsetattr(4) ("man 4 tcsetattr") and termios(4) ("man 4 termios")
  // for details.

  cfmakeraw(&options);
  
  options.c_cc[VMIN] = 1;
  options.c_cc[VTIME] = 1;

  // The baud rate, word length, and handshake options can be set as follows:
  cfsetspeed(&options, serial_io_get_speed(baud));
  options.c_cflag &= ~(CRTSCTS | CDTR_IFLOW | CDSR_OFLOW);
  options.c_cflag |= serial_io_get_flag(databit, parity, stopbit);
  options.c_cflag |= CLOCAL;
  options.c_lflag &= ~(ECHO | CCAR_OFLOW | ICANON | ISIG);

  // Print the new input and output baud rates.
  NSLog(@"Input baud rate changed to %d\n", (int) cfgetispeed(&options));
  NSLog(@"Output baud rate changed to %d\n", (int) cfgetospeed(&options));

  // Cause the new options to take effect immediately.
  if (tcsetattr(fileDescriptor, TCSANOW, &options) == -1) {
    NSLog(@"Error setting tty attributes %s - %s(%d).\n", deviceFilePath, strerror(errno), errno);
    goto error;
  }
  
  // Success:
  return fileDescriptor;

  // Failure:
error:
  if (fileDescriptor != -1) {
    close(fileDescriptor);
  }
  return -1;
}



/////////////////////////////////////////////////////////////////////////////////////////////
//
// SerialIO class implementation
//
/////////////////////////////////////////////////////////////////////////////////////////////
@implementation SerialIO {
  int                   _fd;
  BOOL                  _gcd_started;
  dispatch_source_t     _readSource;
  id<SerialIODelegate>  _delegate;
}

+ (NSMutableArray*)enumSerialDevice {
  io_iterator_t   serialPortIterator;
  kern_return_t   kernResult;
  NSMutableArray* deviceNames = nil;
  
  kernResult = serial_io_utility_find_serial_device(&serialPortIterator);
  if (kernResult != KERN_SUCCESS) {
    NSLog(@"serial_io_utility_find_serial_device failed: %d\n", kernResult);
    return nil;
  }
  
  deviceNames = serial_io_utility_get_device_path(serialPortIterator);
  
  IOObjectRelease(serialPortIterator);
  
  return deviceNames;
}

- (id)init {
  self = [super init];
  
  if (self) {
    _IsOpen       = NO;
    _fd           = -1;
    _gcd_started  = NO;
    _delegate     = nil;
  }
  return self;
}

- (void)dealloc {
  if (_IsOpen) {
    [self closeDevice];
  }
}

- (void)readData {
  uint8_t buffer[128];
  ssize_t  len;
  
  len = read(_fd, buffer, 128);
  if(len <= 0) {
    NSLog(@"read failed: ret %ld\n", len);
    return;
  }
  
  NSLog(@"got read data %ld bytes", len);
  
#if NO
  for(int ndx = 0; ndx < len; ndx++) {
    NSLog(@"rx: %c:%x", buffer[ndx], buffer[ndx]);
  }
#endif

  NSData* data = [NSData dataWithBytes:buffer length:len];
  
  [_delegate serialIORxData:data];
  
  (void)data;
}

- (void)startRead {
  NSAssert(_IsOpen == YES, @"device is not open");
  NSAssert(_gcd_started == NO, @"GCD already started");
  
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
  _readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, _fd, 0, queue);
  
  if(!_readSource) {
    NSLog(@"failed to start read monitoring");
    return;
  }
  
  _gcd_started = YES;
  
  dispatch_source_set_event_handler(_readSource, ^{
    //
    // quite surprising!!!
    // this is called in another thread context
    //
    [self readData];
  });
  dispatch_resume(_readSource);
}


- (BOOL)openDevice:(NSString*)device
              baud:(SerialIO_Baud)baud
            parity:(SerialIO_Parity)parity
           databit:(SerialIO_DataBit)databit
           stopbit:(SerialIO_StopBit)stopbit
          delegate:(id<SerialIODelegate>)delegate {
  int fd;
  
  NSAssert(_IsOpen == NO, @"device is already open");
  
  if((fd = serial_io_utility_open(device, baud, parity, databit, stopbit)) == -1) {
    return NO;
  }
  
  _IsOpen     = YES;
  _fd         = fd;
  _delegate   = delegate;
  
  [self startRead];
  
  return YES;
}

- (void)closeDevice {
  NSAssert(_IsOpen == YES, @"device is not open");
  
  if(_gcd_started) {
    dispatch_source_cancel(_readSource);
    _gcd_started = NO;
  }
  close(_fd);
  
  _IsOpen   = NO;
  _fd       = -1;
  _delegate = nil;
}

- (void)writeData:(NSData*)data {
  NSAssert(_IsOpen == YES, @"device is not open");
  
  const char* buffer;
  ssize_t     len,
              nwritten = 0,
              ret;
  
  buffer = (const char*)[data bytes];
  len = [data length];
  
  //
  // for now simple sync manner.
  // guess this should be enough for UART without any handshake
  //
  while ( nwritten < len ) {
    ret = write(_fd, &buffer[nwritten], len - nwritten);
    
    if(ret <= 0) {
      NSLog(@"error write failed: %ld", ret);
      NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
      return;
    }
    NSLog(@"loop wrote %ld bytes", ret);
    
#if NO
    for(int ndx = 0; ndx < ret; ndx++) {
      NSLog(@"tx: %c:%x", buffer[nwritten + ndx], buffer[nwritten + ndx]);
    }
#endif
    
    nwritten += ret;
  }
  NSLog(@"wrote %ld bytes", nwritten);
}

@end
