/*
 * MathLibrary.h
 *
 * Author: Daniel Gutierrez
 *
 *  * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Timothy D.
 * 		Fred D.
 * 		Linnette M.
 *
 * Revision History:
 * 		v 1.0 - Initial Release
 * 		v 2.0 - Tested Release - Math Debugged
 * 		v 3.0 - February 15, 2019 - Integration Release
 * 		v 3.1 - March 3, 2019 - Addition of LERP, STERP, qDiff, and associated helper functions
 */
 
 
#ifndef MATHLIBRARY_H
#define MATHLIBRARY_H

#include <math.h>

/*
 * Vector Helper Functions
 */
void vectorToMatrix(float *vectNorth, float *vectEast, float *vectDown, float rMat[][3]);
void crossProduct(float *vect1, float *vect2, float *cross_P);
void dotProduct(float *vect1, float *vect2, float *dotP);
void normalizeVect(float *vect);
void magnitudeVect(float *vect, float *mag);
void angleBetweenVect(float *vect1, float *vect2, float *angle);
void vectorProjection(float *vect1, float *vect2, float *proj);

void magnetometerSoftIron(float *mag, float *result);
void magnetometerHardIron(float *mag, float *result);

/*
 * Quaternion Conversion Functions
 */
void toAxisAngle(float *q, float *axis, float *angle);
void toAngularVelocity(float *q, float dt, float *vect);
void fromAngularVelocity(float *vect, float dt, float *quaternion);
void fromAxisAngle(float *vect, float theta, float *quaternion);
void fromMatrix(float rMat[][3], float *quaternion);

/*
 * Quaternion Helper Functions
 */
void identityQ(float *q);
void inverseQ(float *q, float *resultQ);
void normalizeQ (float *q);
void conjugateQ(float *q, float *qReturn);
void subtractQ(float *q1, float *q2, float *resultQ);
void differenceQ(float *q1, float *q2, float *resultQ);
void multiplyQ(float *q1, float *q2, float *qReturn);
void quatMultVect(float *q, float *v, float *resultV);

/*
 * Quaternion Operation Functions
 */
void slerpQ(float *q1, float *q2, float *qReturn, float t);
void lerpQ(float *q1, float *q2, float *qReturn, float t);
void swingTwistDecomp(float *q, float *twistAxis, float *swing, float *twist);
void sterpQ(float *q1, float *q2, float *twistAxis, float *resultQ, float t);

#endif
