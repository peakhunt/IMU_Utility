//
//  PointSphere.cpp
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#include <OpenGL/gl.h>
#include <math.h>
#include "PointSphere.hpp"

#define ANGLE_STEP        10

PointSphere::PointSphere() :
  _color(1.0,1.0,1.0)
{
  _num_vertices = 360 / ANGLE_STEP;
  _vertices = new vertex3[_num_vertices];
  
  for(int angle = 0, ndx = 0; angle < 360; angle += ANGLE_STEP, ndx++) {
    float   r = 3.0f;
    
    _vertices[ndx].x = cosf(angle) * r;
    _vertices[ndx].y = sinf(angle) * r;
    _vertices[ndx].z = 0;
  }
}

PointSphere::~PointSphere() {
}

void
PointSphere::draw(void) {
  glColor3f(_color.x(), _color.y(), _color.z());
  
  glEnableClientState(GL_VERTEX_ARRAY);
  
  for(int i = 0; i < 360; i += ANGLE_STEP) {
    glPushMatrix();
    glRotatef(i, 0, 1, 0);
    
    glVertexPointer( 3,                 // number of coordinates per vertex (x,y,z)
                    GL_FLOAT,           // they are floats
                    sizeof(vertex3),    // stride
                    _vertices);  // the array pointer
    glDrawArrays(GL_POINTS, 0, _num_vertices);
    
    glPopMatrix();
  }
  glDisableClientState(GL_VERTEX_ARRAY);
}
