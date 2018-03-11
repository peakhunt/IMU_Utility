//
//  PointSphere.hpp
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef PointSphere_hpp
#define PointSphere_hpp

#include "Vector3D.hpp"
#include "vertex.h"

class PointSphere {
public:
  PointSphere();
  virtual ~PointSphere();
  
  virtual void draw();
  
protected:
  
private:
  Vector3D      _color;
  vertex3*      _vertices;
  int           _num_vertices;
};

#endif /* PointSphere_hpp */
