//
//  Point3D.m
//  Golden Triangle
//
//  Created by 김혁 on 06/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import "Point3D.h"

@implementation Point3D

- (id)init {
  self = [super init];
  
  _x = 0;
  _y = 0;
  _z = 0;
  
  return self;
}

- (id)initWithX:(float)x Y:(float)y Z:(float)z {
  self = [self init];
  
  _x = x;
  _y = y;
  _z = z;
  
  return self;
}

@end
