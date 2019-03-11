/*
 * MathLibrary.c
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
#include "MathLibrary.h"

#include <math.h>
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))
#define PI 3.14159265
#define EPSILON 1.0e-9

/*
 * crossProduct
 *
 * Calculates the cross product of 2 3-dimensional vectors
 *
 * Input:
 * 		vect1: pointer to A
 * 		vect2: pointer to B
 * 		cross_P: pointer to A X B
 */
void crossProduct(float *vect1, float *vect2, float *cross_P)
{ 
	cross_P[0] = vect1[1] * vect2[2] - vect1[2] * vect2[1]; 
	cross_P[1] = vect1[0] * vect2[2] - vect1[2] * vect2[0]; 
	cross_P[2] = vect1[0] * vect2[1] - vect1[1] * vect2[0];
}

/*
 * dotProduct
 *
 * Calculates the dot product of 2 3-dimensional vectors
 *
 * Input:
 * 		vect1: pointer to A
 * 		vect2: pointer to B
 * 		dotP: pointer to A * B
 */
void dotProduct(float *vect1, float *vect2, float *dotP)
{
	*dotP = 0;
	*dotP += vect1[0] * vect2[0];
	*dotP += vect1[1] * vect2[1];
	*dotP += vect1[2] * vect2[2];
}

/*
 * vectorProjection
 *
 * calculates projection of one vector onto another
 *
 * Input:
 * 		vect1: pointer to A
 * 		vect2: pointer to B
 * 		resultV: pointer to result - vector projection B onto A
 */
void vectorProjection(float *vect1, float *vect2, float *proj)
{
	float dotP, mag;

	dotProduct(vect1, vect2, &dotP);

	magnitudeVect(vect1, &mag);

	proj[0] = (dotP / (mag * mag)) * vect1[0];
	proj[1] = (dotP / (mag * mag)) * vect1[1];
	proj[2] = (dotP / (mag * mag)) * vect1[2];
}

/*
 * magnetometerHardIron
 *
 * This function takes the Magnetometer data from each of the
 * x, y, z components and gets rid of the "hard iron" data
 * by
 */
void magnetometerHardIron(float *mag, float *result)
{
	//for each IMU -- these might need to be done directly in the pipeline
//	mag[0] -= (min_x + max_x)/2.0;
//	mag[1] -= (min_y + max_y)/2.0;
//	mag[2] -= (min_z + max_z)/2.0;
//
}

/*
 * magnetometerSoftIron
 *
 * "soft iron" data is a but more complex to deal with, we
 * believe this to be a pretty simple compromise.
 */
void magnetometerSoftIron(float *mag, float *result)
{

}

/*
 * This function normalizes the quaternion passed to it
 */
void normalizeQ (float *q)
{
	float mag;
	
	mag = sqrtf(q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3]);
	
	q[0] /= mag;
	q[1] /= mag;
	q[2] /= mag;
	q[3] /= mag;
}

/*
 * Quaternion Multiplication: qReturn = q1 * q2
 *
 * Safe for *= type operations
 *
 * Modifies qReturn for return
 *
 * Input;
 * 		q1: input1
 * 		q2: input 2
 * 		qReturn: output - can safely be q1 or q2
 */
void multiplyQ(float *q1, float *q2, float *qReturn)
{
	int i;
	float resultQ[4];

	resultQ[0] = ((q1[0]*q2[0]) - (q1[1]*q2[1]) - (q1[2]*q2[2]) - (q1[3]*q2[3]));
	resultQ[1] = ((q1[0]*q2[1]) + (q1[1]*q2[0]) + (q1[2]*q2[3]) - (q1[3]*q2[2]));
	resultQ[2] = ((q1[0]*q2[2]) - (q1[1]*q2[3]) + (q1[2]*q2[0]) + (q1[3]*q2[1]));
	resultQ[3] = ((q1[0]*q2[3]) + (q1[1]*q2[2]) - (q1[2]*q2[1]) + (q1[3]*q2[0]));
	
	for (i = 0; i < 4; i++)
		qReturn[i] = resultQ[i];
}

/*
 * conjugateQ
 *
 * return the complex conjugate of the input quaternion
 *
 * Input:
 * 		q: input
 * 		qConj: return, conjugate of q
 */
void conjugateQ(float *q, float *qConj)
{
	qConj[0] = q[0];
	qConj[1] = -q[1];
	qConj[2] = -q[2];
	qConj[3] = -q[3];
}

/*
 * identityQ
 *
 * returns an identity version of the input quaternion
 *
 * Input:
 * 		q: input
 * 		resultQ: quaternion with 0 for all values but w
 */
void identityQ(float *q)
{
	q[0] = 1.0f;
	q[1] = 0.0f;
	q[2] = 0.0f;
	q[3] = 0.0f;
}

/*
 * inverseQ
 *
 * takes input of Quaternion
 *
 * Input:
 * 		q: input quaternion
 * 		resultQ: inverse of q
 */
void inverseQ(float *q, float *resultQ)
{
	float denominator;

	denominator = q[0] * q[0] + q[1] * q[1] + q[2] * q[2] + q[3] * q[3];

	denominator *= -1;

	resultQ[0] = q[0] / denominator;
	resultQ[1] = q[1] / denominator;
	resultQ[2] = q[2] / denominator;
	resultQ[3] = q[3] / denominator;
}

/*
 * slerpQ()
 *
 * Spherical-Linear-Interpolation - Quaternions
 *
 * Interpolates between q1 with q2 at a gain of t
 *
 * Safe for *= type operations
 *
 * Input:
 * 		q1: first Quaternion
 * 		q2: second Quaternion
 * 		qReturn: return value - can safely be q1 or q2
 * 		t: gain
 */
void slerpQ(float *q1, float *q2, float *qReturn, float t)
{
	int i;

	float tempReturn[4];

	double cosHalfTheta = q1[0] * q2[0] + q1[1] * q2[1] + q1[2]* q2[2] + q1[3] * q2[3];
	
	if(cosHalfTheta < 0)
	{
		q2[0] = -q2[0];
		q2[1] = -q2[1];
		q2[2] = -q2[2];
		q2[3] = -q2[3];
		cosHalfTheta = -cosHalfTheta;
	}
	
	if (fabs(cosHalfTheta) >= 1.0)
	{
		qReturn[0] = q1[0];
		qReturn[1] = q1[1];
		qReturn[2] = q1[2];
		qReturn[3] = q1[3];
		return;
	}
	
	double halfTheta = acos(cosHalfTheta);
	double sinHalfTheta = sqrt(1.0 - cosHalfTheta*cosHalfTheta);
	
	if (fabs(sinHalfTheta) < 0.001)
	{
		// fabs is floating point absolute
		// safe to modify qReturn in all cases because no cross indicies
		qReturn[0] = (q1[0] * 0.5 + q2[0] * 0.5);
		qReturn[1] = (q1[1] * 0.5 + q2[1] * 0.5);
		qReturn[2] = (q1[2] * 0.5 + q2[2] * 0.5);
		qReturn[3] = (q1[3] * 0.5 + q2[3] * 0.5);

		return;
	}
	
	double ratioA = sin((1 - t) * halfTheta) / sinHalfTheta;
	double ratioB = sin(t * halfTheta) / sinHalfTheta; 

	//calculate Quaternion.
	tempReturn[0] = (q1[0] * ratioA + q2[0] * ratioB);
	tempReturn[1] = (q1[1] * ratioA + q2[1] * ratioB);
	tempReturn[2] = (q1[2] * ratioA + q2[2] * ratioB);
	tempReturn[3] = (q1[3] * ratioA + q2[3] * ratioB);

	for (i = 0; i < 4; i++)
		qReturn[i] = tempReturn[i];

	return;
}

/*
 * lerpQ
 *
 * Linear Interpolation of Quaternions
 *
 * inherently safe for *= type operations
 *
 * Input:
 * 		q1: quaternion A
 * 		q2: quaternion B
 * 		qReturn: result LERP(A, B)
 * 		t: gain (usually 0.5 for central interpolation)
 */
void lerpQ(float *q1, float *q2, float *qResult, float t)
{
	// Clamp gain [0:1]
	if (t > 1)
		t = 1;
	else if (t < 0)
		t = 0;

	qResult[0] = (q1[0] * (1 - t)) + (q2[0] * (1 - t));
	qResult[1] = (q1[1] * (1 - t)) + (q2[1] * (1 - t));
	qResult[2] = (q1[2] * (1 - t)) + (q2[2] * (1 - t));
	qResult[3] = (q1[3] * (1 - t)) + (q2[3] * (1 - t));

	normalizeQ(qResult);
}

/*
 * swingTwistDecomp
 *
 * decomposes a quaternion into swing and twist components about the twist axis input
 *
 * Input:
 * 		q: input quaternion
 * 		twistAxis: vector 3 input axis of decomposition
 * 		swing: quaternion output
 * 		twist: quaternion output
 */
void swingTwistDecomp(float *q, float *twistAxis, float *swing, float *twist)
{
	float sqMag, swingAngle;
	float rotTwistAxis[3];
	float swingAxis[3];
	float projV[3];
	float vectQ[3];
	float twistInverse[4];

	// populate vectQ
	vectQ[0] = q[1];
	vectQ[1] = q[2];
	vectQ[2] = q[3];

	// populate sqMag - magnitude of quaternion vector components
	sqMag = vectQ[0] * vectQ[0] + vectQ[1] * vectQ[1] + vectQ[2] * vectQ[2];

	if (sqMag < EPSILON)
	{
		quatMultVect(q, twistAxis, rotTwistAxis);
		crossProduct(twistAxis, rotTwistAxis, swingAxis);

		sqMag = swingAxis[0] * swingAxis[0] + swingAxis[1] * swingAxis[1] + swingAxis[2] * swingAxis[2];

		if (sqMag > EPSILON)
		{
			angleBetweenVect(twistAxis, rotTwistAxis, &swingAngle);

			fromAxisAngle(swingAxis, swingAngle, swing);
		}
		else
		{
			// no swing component
			identityQ(swing);
		}

		fromAxisAngle(twistAxis, 180.0f, twist);
	}
	else
	{
		vectorProjection(vectQ, twistAxis, projV);

		twist[0] = q[0];
		twist[1] = projV[0];
		twist[2] = projV[1];
		twist[3] = projV[2];

		normalizeQ(twist);

		inverseQ(twist, twistInverse);

		multiplyQ(q, twistInverse, swing);
	}
}

/*
 * sterpQ
 *
 * swing-twist interpolation
 *
 * interpolates two quaternions about a twist axis
 *
 * Input:
 * 		q1: pointer to quaternion A
 * 		q2: pointer to quaternion B
 * 		twistAxis: pointer to vector defining axis of twist
 * 		resultQ: pointer to result
 * 		t: gain
 */
void sterpQ(float *q1, float *q2, float *twistAxis, float *resultQ, float t)
{
	// local quaternions
	float deltaRotation[4];
	float qInverse[4];
	float swingQ[4];
	float twistQ[4];
	float swingFull[4];
	float twistFull[4];

	inverseQ(q1, qInverse);
	multiplyQ(q2, qInverse, deltaRotation);

	swingTwistDecomp(deltaRotation, twistAxis, swingFull, twistFull);

	identityQ(swingQ);
	slerpQ(swingQ, swingFull, swingQ, t);

	identityQ(twistQ);
	slerpQ(twistQ, twistFull, twistQ, t);

	multiplyQ(twistQ, swingQ, resultQ);
}

/*
 * subtractQ
 *
 * Computes resultQ = q1 - q2
 */
void subtractQ(float *q1, float *q2, float *resultQ)
{
	resultQ[0] = q1[0]-q2[2];
	resultQ[1] = q1[1]-q2[1];
	resultQ[2] = q1[2]-q2[2];
	resultQ[3] = q1[3]-q2[3];
}

/*
 * differenceQ
 *
 * calculates quaternion difference
 *
 * more mathematically correct than subtractQ
 *
 * performs conjugate(A) * B
 *
 * save for -= operations
 *
 * Input:
 * 		q1: pointer to A
 * 		q2: pointer to B
 * 		resultQ: pointer to result = A - B
 */
void differenceQ(float *q1, float *q2, float *resultQ)
{
	float conjQ[4];

	conjugateQ(q1, conjQ);

	multiplyQ(conjQ, q2, resultQ);
}

/*
 * quatMultVect
 *
 * multiplies quaternion by vector
 *
 * Input:
 * 		q: pointer to quaternion
 * 		v: pointer to vector
 * 		resultQ: pointer to vector - q * v
 */
void quatMultVect(float *q, float *v, float *resultV)
{
	float vQ[4];
	float multQ[4];
	float conjQ[4];

	vQ[0] = 0;
	vQ[1] = v[0];
	vQ[2] = v[1];
	vQ[3] = v[2];

	multiplyQ(q, vQ, multQ);

	conjugateQ(q, conjQ);

	multiplyQ(multQ, conjQ, multQ);

	resultV[0] = multQ[1];
	resultV[1] = multQ[2];
	resultV[2] = multQ[3];
}

/*
 * toAxisAngle
 *
 * Helper function for toAngularVelocity
 *
 * Calculates axis (vector3) and angle (float) of a quaternion
 *
 * Input:
 * 		q: quaternion to draw from
 * 		axis: vector output
 * 		angle: angle output (deg?rad? who knows)
 */
void toAxisAngle(float *q, float *axis, float *angle)
{
	normalizeQ(q);
	
	axis[0] = 0;
	axis[1] = 0;
	axis[2] = 0;
	
	*angle = 0;
	
	//if w is 1, then this is a singularity (axis angle is zero)
	if(q[0] ==  1.0 || q[0] == 0.0001)
		return;

	float sqw = sqrtf(1.0-(q[0]*q[0]));

	 //it's a singularity and divide by zero, avoid
	if(sqw ==  0.0f || sqw == 0.0001f)
		return;
	
	//make sure that this is a pointer because we want to manipulate the value
	*angle = 2 * acosf(q[0]);
	axis[0] = q[1] / sqw;
	axis[1] = q[2] / sqw;
	axis[2] = q[3] / sqw;
}

/*
 * toAngularVelocity
 *
 * takes a quaternion representing the change in angle over time (dt)
 * calculates velocity represented by angle
 *
 * Input:
 * 		q - quaternion delta
 * 		dt - time change
 * 		vect - vector 3 angular velocity
 */
void toAngularVelocity(float *q, float dt, float *vect)
{
	if (dt == 0)
		return;
	
	float angle = 0.0;
	
	toAxisAngle(q, vect, &angle);

	vect[0] *= angle;
	vect[1] *= angle;
	vect[2] *= angle;

	vect[0] /= dt;
	vect[1] /= dt;
	vect[2] /= dt;
}

/*
 * Takes North-East-Down vector[3] and converts to rotation matrix
 *
 * This provides clarity, compiler optimization should remove
 */
void vectorToMatrix(float *vectNorth, float *vectEast, float *vectDown, float rMat[][3])
{
	// rotation matrix defined by right hand rule: N-E-D
	rMat[0][0] = vectNorth[0];
	rMat[1][0] = vectNorth[1];
	rMat[2][0] = vectNorth[2];
	rMat[0][1] = vectEast[0];
	rMat[1][1] = vectEast[1];
	rMat[2][1] = vectEast[2];
	rMat[0][2] = vectDown[0];
	rMat[1][2] = vectDown[1];
	rMat[2][2] = vectDown[2];
}

/*
 * generate quaternion from a 3x3 rotation matrix
 *
 * uses algorithm to reduce sqrt() calls while avoiding singularities
 *
 * Inputs:
 * 		rMat: 3x3 float rotation matrix
 * 		quaternion: output value - allocated elsewhere
 */
void fromMatrix(float rMat[][3], float *quaternion)
{
	// take the max of these elements
	//r11 + r22 + r33  =>  0
	//r11 => 1
	//r22 => 2
	//r33 => 3
	
	int index = 0;
	float w, x, y, z;
	
	float f = rMat[1][1] + rMat[2][2] + rMat[3][3];
	
	if( f < rMat[1][1]) 
	{
		index = 1;
		f = rMat[1][1];
	}
	
	if( f < rMat[2][2])
	{
		index = 2;
		f = rMat[2][2];
	}
	
	if( f < rMat[3][3])
	{
		index = 3;
	}
	
	switch(index)
	{
			
		case 0:
			w = sqrtf(1 + rMat[0][0] + rMat[1][1] + rMat[2][2]);
			x = (rMat[2][1] - rMat[1][2]) / w;
			y = (rMat[0][2] - rMat[2][0]) / w;
			z = (rMat[1][0] - rMat[0][1]) / w;
			break;
		case 1:		
			x = sqrtf(1 + rMat[0][0] - rMat[1][1] - rMat[2][2]);
			w = (rMat[2][1] - rMat[1][2]) / x;
			y = (rMat[0][1] + rMat[1][0]) / x;
			z = (rMat[2][0] - rMat[0][2]) / x;
			break;
		case 2:
			y = sqrtf( 1 - rMat[0][0] + rMat[1][1] - rMat[2][2]);
			w = (rMat[0][2] - rMat[2][0]) / y;
			x = (rMat[0][1] + rMat[1][0]) / y;
			z = (rMat[1][2] + rMat[2][1]) / y;
			break;
		case 3:	
			z = sqrtf( 1 - rMat[0][0] - rMat[1][1] + rMat[2][2]);
			w = (rMat[1][0] - rMat[0][1]) / z;
			x = (rMat[2][0] + rMat[0][2]) / z;
			y = (rMat[0][1] + rMat[1][0]) / z;
			break;
	}
	
	w /= 2.0f;
	x /= 2.0f;
	y /= 2.0f;
	z /= 2.0f;
	
	quaternion[0] = w;
	quaternion[1] = x;
	quaternion[2] = y;
	quaternion[3] = z;
}

/*
 * normalizes the vector passed in
 */
void normalizeVect(float *vect)
{
	float w = sqrt( vect[0] * vect[0] + vect[1] * vect[1] + vect[2] * vect[2] );
	vect[0] /= w;
	vect[1] /= w;
	vect[2] /= w;

	return;
}

/*
 * Generate a Quaternion from Angular Velocity
 *
 * Uses Axis Angle Pair and Integration
 *
 * Used for Gyro version q derivation
 */
void fromAngularVelocity(float *vect, float dt, float *quaternion)
{
	float magnitude, theta;

	magnitude = sqrtf(vect[0] * vect[0] + vect[1] * vect[1] + vect[2] * vect[2]);

	theta = magnitude * dt;

	fromAxisAngle(vect, theta, quaternion);
}

/*
 * Generate a Quaternion from Axis-Angle pair
 */
void fromAxisAngle(float *vect, float theta, float *quaternion)
{
	float sinHalfTheta;

	sinHalfTheta = sinf(theta / 2.0f);

	quaternion[0] = cosf(theta / 2.0f);
	quaternion[1] = vect[0] + sinHalfTheta;
	quaternion[2] = vect[1] + sinHalfTheta;
	quaternion[3] = vect[2] + sinHalfTheta;
}

/*
 * returns vector magnitude
 */
void magnitudeVect(float *vect, float *mag)
{
	*mag = sqrtf(vect[0] * vect[0] + vect[1] * vect[1] + vect[2] * vect[2]);
}

/*
 * angleBetweenVect
 *
 * calculates the angle between two vectors
 *
 * Input:
 * 		vect1: vector 1 pointer
 * 		vect2: vector 2 pointer
 * 		angle: output pointer - angle in degrees
 */
void angleBetweenVect(float *vect1, float *vect2, float *angle)
{
	float dotP, magV1, magV2;

	dotProduct(vect1, vect2, &dotP);

	magnitudeVect(vect1, &magV1);
	magnitudeVect(vect2, &magV2);

	// combine these two
	magV1 *= magV2;

	*angle = acosf(dotP / magV1);
}
