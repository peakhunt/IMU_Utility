//
//  AxisDrawer.hpp
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef AxisDrawer_hpp
#define AxisDrawer_hpp

#include "Vector3D.hpp"
#include "vertex.h"

class AxisDrawer {
public:
  AxisDrawer();
  
  virtual ~AxisDrawer();
  virtual void draw(void);
  
protected:
private:
  Vector3D    _x_color;
  Vector3D    _y_color;
  Vector3D    _z_color;
  
  vertex3*    _x_axis_vertices;
  vertex3*    _y_axis_vertices;
  vertex3*    _z_axis_vertices;
};
#endif /* AxisDrawer_hpp */
