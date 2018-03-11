//
//  Point3D.h
//  Golden Triangle
//
//  Created by 김혁 on 06/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Point3D : NSObject

- (id)initWithX:(float)x Y:(float)y Z:(float)z;

@property float x;
@property float y;
@property float z;

@end
