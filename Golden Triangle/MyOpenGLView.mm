//
//  MyOpenGLView.m
//  Golden Triangle
//
//  Created by 김혁 on 05/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "MyOpenGLView.h"
#import "Point3D.h"
#include "ModelCamera.hpp"
#include "AxisDrawer.hpp"
#include "PointSphere.hpp"

#define ANGLE_STEP        10

/////////////////////////////////////////////////////////////////////
//
// utlities in C
//
/////////////////////////////////////////////////////////////////////
#if NO
static void drawAxis(void) {
  glColor3f(1.0,0.0,0.0); // red x
  glBegin(GL_LINES);
  // x aix
  glVertex3f(-4.0, 0.0f, 0.0f);
  glVertex3f(4.0, 0.0f, 0.0f);
  
  // arrow
  glVertex3f(4.0, 0.0f, 0.0f);
  glVertex3f(3.0, 1.0f, 0.0f);
  
  glVertex3f(4.0, 0.0f, 0.0f);
  glVertex3f(3.0, -1.0f, 0.0f);
  glEnd();
  glFlush();
  
  // y
  glColor3f(0.0,1.0,0.0); // green y
  glBegin(GL_LINES);
  glVertex3f(0.0, -4.0f, 0.0f);
  glVertex3f(0.0, 4.0f, 0.0f);
  
  // arrow
  glVertex3f(0.0, 4.0f, 0.0f);
  glVertex3f(1.0, 3.0f, 0.0f);
  
  glVertex3f(0.0, 4.0f, 0.0f);
  glVertex3f(-1.0, 3.0f, 0.0f);
  glEnd();
  glFlush();
  
  // z
  glColor3f(0.0,0.0,1.0); // blue z
  glBegin(GL_LINES);
  glVertex3f(0.0, 0.0f ,-4.0f );
  glVertex3f(0.0, 0.0f ,4.0f );
  
  // arrow
  glVertex3f(0.0, 0.0f ,4.0f );
  glVertex3f(0.0, 1.0f ,3.0f );
  
  glVertex3f(0.0, 0.0f ,4.0f );
  glVertex3f(0.0, -1.0f ,3.0f );
  glEnd();
  glFlush();
}
#endif

/////////////////////////////////////////////////////////////////////
//
// camera tracking
//
/////////////////////////////////////////////////////////////////////
@interface MyOpenGLView ()
- (void)drawPoints;
- (void)initPoints;

@end

@implementation MyOpenGLView {
  ModelCamera       camera;
  AxisDrawer        axis_drawer;
  PointSphere       point_sphere;
  NSMutableArray    *points;
}

- (void) initPoints {
  points = [[NSMutableArray alloc] init];
  
  for(int angle = 0; angle < 360; angle += ANGLE_STEP) {
    float   x, y, z;
    float   r = 3.0f;
    Point3D *p;
    
    x = cosf(angle) * r;
    y = sinf(angle) * r;
    z = 0;
    
    p = [[Point3D alloc] initWithX:x Y:y Z:z];
    [points addObject:p];
  }
}

- (id)initWithCoder:(NSCoder *)c {
  self = [super initWithCoder:c];
  
#if NO
  [self initPoints];
#endif
  return self;
}

- (void)reshape {
  [super reshape];
  
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glFrustum(-1.0, 1.0, -1.0, 1.0, 1.5f, 50.0f);
}

#ifdef USE_TIMER_TEST
- (void)updateRect:(NSTimer *)timer {
  camera.rotate(0.1, 0.1);
  [self setNeedsDisplay:YES];
}
#endif

- (void)drawPoints {
  glColor3f(1.0,1.0,1.0); // white dot
  
  for(int i = 0; i < 360; i += ANGLE_STEP) {
    glPushMatrix();
    glRotatef(i, 0, 1, 0);
    
    glBegin(GL_POINTS);
    for(Point3D* p in points) {
      glVertex3f(p.x, p.y, p.z);
    }
    glEnd();
    glFlush();
    
    glPopMatrix();
  }
}

- (void)drawRect:(NSRect)dirtyRect {
#ifdef USE_TIMER_TEST
  if (timer == nil) {
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                             target:self
                                           selector:@selector(updateRect:)
                                           userInfo:nil
                                            repeats:YES];
  }
#endif
  
  [super drawRect:dirtyRect];
  
  [[self openGLContext] makeCurrentContext];
  
  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT);
  
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity ();
  camera.setupGLMatrix();

#if NO
  drawAxis();
  [self drawPoints];
#else
  axis_drawer.draw();
  point_sphere.draw();
#endif
  

  glFlush();
}

/////////////////////////////////////////////////////////////////////
//
// camera tracking
//
/////////////////////////////////////////////////////////////////////
- (void)scrollWheel:(NSEvent *)theEvent {
  NSEventModifierFlags  flags = [theEvent modifierFlags];
  
  if (flags & NSEventModifierFlagControl) {
    // z distance handling
    float dz = [theEvent deltaY];
    
    camera.z_dist(dz);
    [self setNeedsDisplay:YES];
  } else {
    // rotation handling
    float dx = [theEvent deltaX];
    float dy = [theEvent deltaY];
    
    camera.rotate(dx, -dy);
    [self setNeedsDisplay:YES];
  }
}

- (IBAction) resetCamera:(id)sender {
  camera.reset();
  [self setNeedsDisplay:YES];
}
@end
