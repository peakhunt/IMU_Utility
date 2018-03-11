//
//  ModelCamera.cpp
//
//  Created by 김혁 on 07/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#include "ModelCamera.hpp"
#include <OpenGL/gl.h>

ModelCamera::ModelCamera() {
  this->reset();
}

void
ModelCamera::reset(void) {
  _camRotX = 0;
  _camRotY = 0;
  _camDistZ  = 10;
}

void
ModelCamera::rotate(float dx, float dy) {
  _camRotX += dx;
  _camRotY += dy;
}

void
ModelCamera::z_dist(float dz) {
  _camDistZ += dz;
}

void
ModelCamera::setupGLMatrix(void) {
  glTranslatef(0.0f, 0.0f, -_camDistZ);
  glRotatef(_camRotY, 1, 0, 0);
  glRotatef(_camRotX, 0, 1, 0);
}
