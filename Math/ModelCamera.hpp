//
//  ModelCamera.hpp
//
//  Created by 김혁 on 07/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef ModelCamera_hpp
#define ModelCamera_hpp

class ModelCamera {
public:
  ModelCamera();
  
  void rotate(float dx, float dy);
  void z_dist(float dz);
  
  void setupGLMatrix(void);
  void reset(void);
  
private:
  float   _camRotX;
  float   _camRotY;
  float   _camDistZ;
};

#endif /* ModelCamera_hpp */
