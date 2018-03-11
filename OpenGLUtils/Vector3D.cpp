//
//  Vector3D.cpp
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#include "Vector3D.hpp"

Vector3D::Vector3D() {
  _x = 0;
  _y = 0;
  _z = 0;
}

Vector3D::Vector3D(float x, float y, float z) {
  _x = x;
  _y = y;
  _z = z;
}
