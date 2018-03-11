//
//  MyOpenGLViewController.m
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "MyOpenGLViewController.h"

//#define DATA_WRITE_TEST         YES


static SerialIO_Baud _baud_rates[] = {
  SerialIO_Baud_115200,
  SerialIO_Baud_57600,
  SerialIO_Baud_38400,
  SerialIO_Baud_19200,
  SerialIO_Baud_9600,
};

static SerialIO_Parity _parities[] = {
  SerialIO_Parity_None,
  SerialIO_Parity_Even,
  SerialIO_Parity_Odd,
};

static SerialIO_DataBit _databits[] = {
  SerialIO_DataBit_8,
  SerialIO_DataBit_7
};

static SerialIO_StopBit _stopbits [] = {
  SerialIO_StopBit_1,
  SerialIO_StopBit_2
};

@implementation MyOpenGLViewController {
  NSMutableArray* _serialPorts;
  SerialIO*       _serialIO;
  NSFont*         _debugFont;
  NSDictionary*   _debugTextAttrDic;

#ifdef DATA_WRITE_TEST
  NSTimer*      _timer;
#endif
}

- (id)init {
  self = [super init];
  
  if (self) {
    _serialIO = nil;
    _debugFont = [NSFont fontWithName:@"Courier" size:11];
    _debugTextAttrDic = [NSDictionary dictionaryWithObject:_debugFont
                                                    forKey:NSFontAttributeName];
  }
  
  return self;;
}

- (void)fillSerialPortPopup {
  [serialPortPopUp removeAllItems];
  
  _serialPorts = [SerialIO enumSerialDevice];
  
  for(NSString* path in _serialPorts) {
    [serialPortPopUp addItemWithTitle:path];
  }
  
  if ([_serialPorts count] > 0) {
    [serialPortPopUp selectItemAtIndex:0];
    [self setIsSerialPortAvailable:YES];
  } else {
    [self setIsSerialPortAvailable:NO];
  }
}

- (BOOL)IsSerialPortOpen {
  if (_serialIO == nil || [_serialIO IsOpen] == NO) {
    return NO;
  }
  return YES;
}

- (BOOL)IsSerialPortClosed {
  return ![self IsSerialPortOpen];
}

- (void)openAndStartSerialDevice {
  SerialIO_Baud baud          = _baud_rates[_BaudRateNdx];
  SerialIO_Parity parity      = _parities[_ParityNdx];
  SerialIO_DataBit databit    = _databits[_DataBitNdx];
  SerialIO_StopBit stopbit    = _stopbits[_StopBitNdx];
  NSString* port              = _serialPorts[_SerialPortNdx];
  
  _serialIO = [[SerialIO alloc] init];
  
  BOOL ret;
  ret = [_serialIO openDevice:port
                         baud:baud
                       parity:parity
                      databit:databit
                      stopbit:stopbit
                     delegate:self];
  
  if (ret == NO) {
    NSLog(@"failed to open serial port %@", port);
    return;
  }
}


#ifdef DATA_WRITE_TEST
- (void)writeTestData:(NSTimer *)aTimer {
  NSLog(@"DATA_WRITE_TEST begin");
  
  NSDateFormatter *format = [[NSDateFormatter alloc] init];
  [format setDateFormat:@"MMMM dd, yyyy (EEEE) HH:mm:ss z Z"];
  NSDate *now = [NSDate date];
  NSString *nsstr = [format stringFromDate:now];
  NSString *sent = [NSString stringWithFormat:@"%@\r\n", nsstr];
  
  int len = (int)[sent length];
  const char* cstr = [sent cStringUsingEncoding:NSASCIIStringEncoding];
  
  NSData* data = [NSData dataWithBytes:cstr length:len];
  
  [_serialIO writeData:data];
  
  NSLog(@"DATA_WRITE_TEST end");
}
#endif

- (IBAction)openSerialPort:(id)sender {
  NSWindow* window = [openGLView window];
  
  [self fillSerialPortPopup];
  
  [window beginSheet:serialPortSheet completionHandler:^(NSModalResponse returnCode) {
    if (returnCode == NSModalResponseOK) {
      [self openAndStartSerialDevice];
#ifdef DATA_WRITE_TEST
      _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                target:self
                                              selector:@selector(writeTestData:)
                                              userInfo:nil
                                               repeats:YES];
#endif
    }
  }];
  
}

- (IBAction)endSpeedSheet:(id)sender {
  NSWindow* window = [openGLView window];
  
  // Return to normal event handling
  if ([sender tag] == 0) {
    // ok
    [window endSheet:serialPortSheet returnCode:NSModalResponseOK];
  } else {
    // cancel
    [window endSheet:serialPortSheet returnCode:NSModalResponseCancel];
  }
}

- (IBAction)closeSerialPort:(id)sender {
  if (_serialIO && [_serialIO IsOpen] == TRUE) {
    [_serialIO closeDevice];
    _serialIO = nil;
  }
  NSLog(@"serial port closed");
  
#ifdef DATA_WRITE_TEST
  [_timer invalidate];
  _timer = nil;
#endif
}

- (void)handleRxData:(NSData*) data {
  NSString* str = [[NSString alloc] initWithBytes:[data bytes]
                                           length:[data length]
                                         encoding:NSASCIIStringEncoding];
  
  if ([debugWindow isVisible]) {
    NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:str attributes:_debugTextAttrDic];
    
    [[debugTextView textStorage] appendAttributedString:attrText];
    [debugTextView scrollToEndOfDocument:nil];
  }
}

- (void)serialIORxData:(NSData*)data {

  dispatch_async(dispatch_get_main_queue(), ^{
    [self handleRxData:data];
  });
}

- (IBAction)showHideDebugWindow:(id)sender {
  if([debugWindow isVisible] == YES) {
    // hide
    [debugWindow close];
  } else {
    // show
    [debugWindow makeKeyAndOrderFront:nil];
  }
}

- (IBAction)debugInputEnter:(id)sender {
  NSString* input = [debugInputText stringValue];
  
  NSLog(@"input = '%@'", input);
  
  NSString *sent = [NSString stringWithFormat:@"%@\r", input];
  
  [debugInputText setStringValue:@""];
  
  if (_serialIO == nil && ![_serialIO IsOpen]) {
    return;
  }
  
  NSLog(@"sending '%@'", sent);
  
  int len = (int)[sent length];
  const char* cstr = [sent cStringUsingEncoding:NSASCIIStringEncoding];
  
  NSData* data = [NSData dataWithBytes:cstr length:len];
  
  [_serialIO writeData:data];
}

@end
