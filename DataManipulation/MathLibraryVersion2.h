/*
 * MathLibraryVersion2.h
 *
 * Author: Daniel Gutierrez
 *
 *  * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Timothy D.
 * 		Fred D.
 * 		Linnette M.
 *
 * 
 */
 
 
#ifndef MATHLIBRARYVERSION2_H
#define MATHLIBRARYVERSION2_H


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>



float crossProduct(float vect1[], float vect2[], float cross_P[]); 
void toAxisAngle(float q[], float axis[], float *angle);
void multiplyQ(float q1[], float q2[]);
void toAngularVelocity(float q[], float dt);

void fromMatrix(float rMat[][3], float quaternion[]);
void vectorToMatrix(float vectNorth[], float vectEast[], float vectDown[], float rMat[][3]);

float normalizeVect(float vect[]);
void normalizeQ (float q[]);
float conjugateQ(float q[]);
void slerpQ(float q1[], float q2[], float t);
void toAxisAngle(float q[], float axis[], float *angle);



#endif
