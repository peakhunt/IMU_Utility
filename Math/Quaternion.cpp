//
//  Quaternion.cpp
//  Golden Triangle
//
//  Created by 김혁 on 07/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#include "Quaternion.hpp"
#include <math.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// quaternion can be used to represent a rotation around arbitrary unit axis and
// its representation is shown below in b). The actual rotation is performed by
// using equation shown below in a). The key insight you need about quaternion is
// "A ROTATION AROUND AN ARBITRARY AXIS CAN BE DECOMPOSED INTO A COMBINATION OF
//  ROTATION AROUND X/Y/Z AXIS. So a quaternion rotation can be described as
//  'a' angle rotation by x-axis + 'b' angle rotation by y-axis + 'c' angle rotation by z-axis'.
// This is why quaternion can be used to represent an orientation of a rigid body in 3D space assuming
// the rigid body is at the origin of 3D space.
//
// Here is how we use it.
// we have roll/pitch/yaw for an orientation. Then we convert them to quaternion.
// Do some operation. Then we have a new quaternion. To get an orientation that is easier
// to understand for humans, we convert the quaternion back to roll/pitch/yaw and we
// have a new orientation. Wala!
// So why boehter with quaternion? It is because quaternions are mathematically better than
// euler angles for gimbal lock prevention and other complicated operations.
//
// when quaternions are used purely for rotation, it is even easier to understand.
// For an arbitrary object in an arbitrary location in 3D space, a quaternion simply
// represents rotating the rigid body around arbitrary axis by some amount, which can be
// decomposed into rotation around each axis as Euler has proved many years ago.
//
// don't forget this about quaternion. just remember it!
//
// a) q * p * qInv takes p ([v,w]) to p'([v', w])
//    this means only v component is changed regardless of w.
//
// b) if norm(q) is 1 and q = [v*sin(Omega), cos(Omega)],
//    q * p * qInverse acts to rotate p around v by 2*Omega
//
// This is the hart of quaternion when it comes to rotation
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////


Quaternion::Quaternion() {
  this->_x =
  this->_y =
  this->_z = 0;
  this->_w = 1;
}

Quaternion::Quaternion(float x, float y, float z, float w) {
  this->_x = x;
  this->_y = y;
  this->_z = z;
  this->_w = w;
}

void
Quaternion::operator=(Quaternion &q) {
  this->_x = q._x;
  this->_y = q._y;
  this->_z = q._z;
  this->_w = q._w;
}

Quaternion
Quaternion::operator+(const Quaternion& q) {
  Quaternion result;
  
  result._x = this->_x + q._x;
  result._y = this->_y + q._y;
  result._z = this->_z + q._z;
  result._w = this->_w + q._w;
  
  return result;
}

Quaternion
Quaternion::operator-(const Quaternion& q) {
  Quaternion result;
  
  result._x = this->_x - q._x;
  result._y = this->_y - q._y;
  result._z = this->_z - q._z;
  result._w = this->_w - q._w;
  
  return result;
}

Quaternion
Quaternion::operator*(const Quaternion& q) {
  Quaternion result;
  float x = this->_x;
  float y = this->_y;
  float z = this->_z;
  float w = this->_w;
  float num4 = q._x;
  float num3 = q._y;
  float num2 = q._z;
  float num  = q._w;
  
  float num12 = (y * num2) - (z * num3);
  float num11 = (z * num4) - (x * num2);
  float num10 = (x * num3) - (y * num4);
  float num9 = ((x * num4) + (y * num3)) + (z * num2);
  
  result._x = ((x * num) + (num4 * w)) + num12;
  result._y = ((y * num) + (num3 * w)) + num11;
  result._z = ((z * num) + (num2 * w)) + num10;
  result._w = (w * num) - num9;
  
  return result;
}

Quaternion
Quaternion::operator*(const float& scale) {
  Quaternion result = *this;
  
  result.scale(scale);
  
  return result;
}

void
Quaternion::conjugate(void) {
  this->_x = -this->_x;
  this->_y = -this->_y;
  this->_z = -this->_z;
  // this->_w =  this->_w; unnecessary
}

float
Quaternion::norm(void) {
  float num2 = (((this->_x * this->_x) + (this->_y * this->_y)) +
                (this->_z * this->_z)) + (this->_w * this->_w);
  
  return num2;
}

float
Quaternion::length(void) {
  return sqrtf(this->norm());
}

void
Quaternion::normalize(void) {
  float len = this->length();
  
  this->_x /= len;
  this->_y /= len;
  this->_z /= len;
  this->_w /= len;
}

void
Quaternion::negate(void) {
  this->_x *= -1;
  this->_y *= -1;
  this->_z *= -1;
  this->_w *= -1;
}

void
Quaternion::inverse(void) {
  float norm = this->norm();
  
  this->conjugate();
  
  this->_x /= norm;
  this->_y /= norm;
  this->_z /= norm;
  this->_w /= norm;
}

void
Quaternion::scale(float scale) {
  this->_x *= scale;
  this->_y *= scale;
  this->_z *= scale;
  this->_w *= scale;
}
