//
//  Vector3D.hpp
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef Vector3D_hpp
#define Vector3D_hpp

class Vector3D {
public:
  Vector3D();
  Vector3D(float x, float y, float z);
  
  //
  // getter/setter
  //
  inline float x() { return _x; };
  inline float y() { return _y; };
  inline float z() { return _z; };

  inline void x(float x) { _x = x; };
  inline void y(float y) { _y = y; };
  inline void z(float z) { _z = z; };
  
protected:
  
private:
  float   _x;
  float   _y;
  float   _z;
};

#endif /* Vector3D_hpp */
