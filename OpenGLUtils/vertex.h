//
//  vertex.h
//  Golden Triangle
//
//  Created by 김혁 on 09/03/2018.
//  Copyright © 2018 KongjaStudio. All rights reserved.
//

#ifndef vertex_h
#define vertex_h

#include <OpenGL/gl.h>

typedef struct {
  GLfloat   x;
  GLfloat   y;
  GLfloat   z;
} vertex3;

static inline void
vertex3_set(vertex3* vtx, GLfloat x, GLfloat y, GLfloat z) {
  vtx->x = x;
  vtx->y = y;
  vtx->z = z;
}

#endif /* vertex_h */
