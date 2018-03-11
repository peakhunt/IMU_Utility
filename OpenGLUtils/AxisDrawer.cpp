//
//  AxisDrawer.cpp
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#include <OpenGL/gl.h>
#include "AxisDrawer.hpp"

AxisDrawer::AxisDrawer() :
  _x_color(1.0,0.0,0.0),
  _y_color(0.0,1.0,0.0),
  _z_color(0.0,0.0,1.0)
{
  _x_axis_vertices = new vertex3[6];
  // x aix
  vertex3_set(&_x_axis_vertices[0], -4.0, 0.0f, 0.0f);
  vertex3_set(&_x_axis_vertices[1], 4.0, 0.0f, 0.0f);
  
  // arrow
  vertex3_set(&_x_axis_vertices[2], 4.0, 0.0f, 0.0f);
  vertex3_set(&_x_axis_vertices[3], 3.0, 1.0f, 0.0f);
  vertex3_set(&_x_axis_vertices[4], 4.0, 0.0f, 0.0f);
  vertex3_set(&_x_axis_vertices[5], 3.0, -1.0f, 0.0f);
  
  // y axis
  _y_axis_vertices = new vertex3[6];
  vertex3_set(&_y_axis_vertices[0], 0.0, -4.0f, 0.0f);
  vertex3_set(&_y_axis_vertices[1], 0.0, 4.0f, 0.0f);
  
  // arrow
  vertex3_set(&_y_axis_vertices[2], 0.0, 4.0f, 0.0f);
  vertex3_set(&_y_axis_vertices[3], 1.0, 3.0f, 0.0f);
  vertex3_set(&_y_axis_vertices[4], 0.0, 4.0f, 0.0f);
  vertex3_set(&_y_axis_vertices[5], -1.0, 3.0f, 0.0f);

  // z axis
  _z_axis_vertices = new vertex3[6];
  vertex3_set(&_z_axis_vertices[0], 0.0, 0.0f ,-4.0f );
  vertex3_set(&_z_axis_vertices[1], 0.0, 0.0f ,4.0f );
  
  // arrow
  vertex3_set(&_z_axis_vertices[2], 0.0, 0.0f ,4.0f );
  vertex3_set(&_z_axis_vertices[3], 0.0, 1.0f ,3.0f );
  vertex3_set(&_z_axis_vertices[4], 0.0, 0.0f ,4.0f );
  vertex3_set(&_z_axis_vertices[5], 0.0, -1.0f ,3.0f );
}

AxisDrawer::~AxisDrawer() {
  delete _x_axis_vertices;
  delete _y_axis_vertices;
  delete _z_axis_vertices;
}

void
AxisDrawer::draw(void) {
  glEnableClientState(GL_VERTEX_ARRAY);
  // x
  glColor3f(_x_color.x(), _x_color.y(), _x_color.z());
  glVertexPointer( 3,                 // number of coordinates per vertex (x,y,z)
                  GL_FLOAT,           // they are floats
                  sizeof(vertex3),    // stride
                  _x_axis_vertices);  // the array pointer
  glDrawArrays(GL_LINES, 0, 6);
  
  // y
  glColor3f(_y_color.x(), _y_color.y(), _y_color.z());
  glVertexPointer( 3,                 // number of coordinates per vertex (x,y,z)
                  GL_FLOAT,           // they are floats
                  sizeof(vertex3),    // stride
                  _y_axis_vertices);  // the array pointer
  glDrawArrays(GL_LINES, 0, 6);
  
  // z
  glColor3f(_z_color.x(), _z_color.y(), _z_color.z());
  glVertexPointer( 3,                 // number of coordinates per vertex (x,y,z)
                  GL_FLOAT,           // they are floats
                  sizeof(vertex3),    // stride
                  _z_axis_vertices);  // the array pointer
  glDrawArrays(GL_LINES, 0, 6);
  glDisableClientState(GL_VERTEX_ARRAY);
}
