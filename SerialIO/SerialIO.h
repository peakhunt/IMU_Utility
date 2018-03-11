//
//  SerialIO.h
//
//  Created by 김혁 on 07/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  SerialIO_Baud_9600,
  SerialIO_Baud_19200,
  SerialIO_Baud_38400,
  SerialIO_Baud_57600,
  SerialIO_Baud_115200
} SerialIO_Baud;

typedef enum {
  SerialIO_Parity_None,
  SerialIO_Parity_Odd,
  SerialIO_Parity_Even
} SerialIO_Parity;

typedef enum {
  SerialIO_DataBit_8,
  SerialIO_DataBit_7
} SerialIO_DataBit;

typedef enum {
  SerialIO_StopBit_1,
  SerialIO_StopBit_2,
} SerialIO_StopBit;

@protocol SerialIODelegate
- (void)serialIORxData:(NSData*)data;

@end

@interface SerialIO : NSObject

@property (readonly) BOOL IsOpen;

+ (NSMutableArray*)enumSerialDevice;
- (BOOL)openDevice:(NSString*)device
              baud:(SerialIO_Baud)baud
            parity:(SerialIO_Parity)parity
           databit:(SerialIO_DataBit)databit
           stopbit:(SerialIO_StopBit)stopbit
          delegate:(id<SerialIODelegate>)delegate;
- (void)closeDevice;
- (void)writeData:(NSData*)data;

@end
