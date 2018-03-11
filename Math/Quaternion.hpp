//
//  Quaternion.h
//  Golden Triangle
//
//  Created by 김혁 on 07/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef Quaternion_h
#define Quaternion_h

class Quaternion {
public:
  Quaternion();
  Quaternion(float x, float y, float z, float w);
  
  //
  // operator overloading for quaternions
  //
  void operator=(Quaternion &q);
  Quaternion operator+(const Quaternion& q);
  Quaternion operator-(const Quaternion& q);
  Quaternion operator*(const Quaternion& q);
  Quaternion operator*(const float& scale);

  //
  // basic quaternion operations
  //
  void conjugate(void);
  void normalize(void);
  float norm(void);
  float length(void);
  void negate(void);
  void inverse(void);
  void scale(float scale);
  
  //
  // getter/setter
  //
  inline float x() { return _x; };
  inline float y() { return _y; };
  inline float z() { return _z; };
  inline float w() { return _w; };
  
  inline void x(float x) { _x = x; };
  inline void y(float y) { _y = y; };
  inline void z(float z) { _z = z; };
  inline void w(float w) { _w = w; };

protected:
  
private:
  float   _x;
  float   _y;
  float   _z;
  float   _w;
};


#endif /* Quaternion_h */
