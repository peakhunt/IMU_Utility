//
//  MyOpenGLView.h
//  Golden Triangle
//
//  Created by 김혁 on 05/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <OpenGL/gl.h>

@interface MyOpenGLView : NSOpenGLView {
#ifdef USE_TIMER_TEST
  NSTimer*          timer;
#endif
}

- (void)drawRect:(NSRect)dirtyRect;
- (IBAction) resetCamera:(id)sender;

@end
