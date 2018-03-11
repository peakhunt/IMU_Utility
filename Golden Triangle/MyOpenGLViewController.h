//
//  MyOpenGLViewController.h
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "SerialIO.h"

@interface MyOpenGLViewController : NSObject <SerialIODelegate> {
  IBOutlet NSView*        openGLView;
  IBOutlet NSWindow*      serialPortSheet;
  IBOutlet NSPopUpButton* serialPortPopUp;
  
  IBOutlet NSWindow*      debugWindow;
  IBOutlet NSTextView*    debugTextView;
  IBOutlet NSTextField*   debugInputText;
}

@property BOOL IsSerialPortAvailable;
@property(readonly) BOOL IsSerialPortOpen;
@property(readonly) BOOL IsSerialPortClosed;

@property NSInteger SerialPortNdx;
@property NSInteger BaudRateNdx;
@property NSInteger ParityNdx;
@property NSInteger DataBitNdx;
@property NSInteger StopBitNdx;

- (IBAction)openSerialPort:(id)sender;
- (IBAction)endSpeedSheet:(id)sender;
- (IBAction)closeSerialPort:(id)sender;
- (IBAction)showHideDebugWindow:(id)sender;
- (IBAction)debugInputEnter:(id)sender;

@end
