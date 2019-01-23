/*
 * MathLibraryVersion2.c
 *
 * Author: Daniel Gutierrez
 *
 *  * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Timothy D.
 * 		Fred D.
 * 		Linnette M.
 *
 * main function for ArtySDSoCTest program
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "MathLibraryVersion2.h"
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))
#define PI 3.14159265


float crossProduct(float vect1[], float vect2[], float cross_P[]) 
{ 
	cross_P[0] = vect1[1] * vect2[2] - vect1[2] * vect2[1]; 
	cross_P[1] = vect1[0] * vect2[2] - vect1[2] * vect2[0]; 
	cross_P[2] = vect1[0] * vect2[1] - vect1[1] * vect2[0]; 
} 

// copysign function built to mimic the functionality of the function used in IMU Calculations
float copysign_zero(float x,float y)
{// x = 1, y = -3	
	if( y == 0)
	{
		return 0;
	}
	
	else if(y < 0 && x > 0)
	{
		return -x;
	}
	else if(y < 0 && x < 0)
	{
		return x;
	}
	else if (y > 0)
	{
		return x;
	}
	else 
		return 0;
}

void rotationMatrix(float vectNorth[], float vectEast[], float vectDown[]) 
{
	float rMat [3][3];
	
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

	float w = sqrtf(MAX(0, 1 + rMat[0][0] + rMat[1][1] + rMat[2][2])) / 2.0f;
	float x = sqrtf(MAX(0, 1 + rMat[0][0] - rMat[1][1] - rMat[2][2])) / 2.0f;
	float y = sqrtf(MAX(0, 1 - rMat[0][0] + rMat[1][1] - rMat[2][2])) / 2.0f;
	float z = sqrtf(MAX(0, 1 - rMat[0][0] - rMat[1][1] + rMat[2][2])) / 2.0f;
	
	x = copysign_zero(x, rMat[2][1] - rMat[1][2]);
    y = copysign_zero(y, rMat[0][2] - rMat[2][0]);
    z = copysign_zero(z, rMat[1][0] - rMat[0][1]);
	
	printf("\nQuaternion w: %f", w);
	printf("\nQuaternion x: %f", x);
	printf("\nQuaternion y: %f", y);
	printf("\nQuaternion z: %f", z);
}

/*
 * This function normalizes the quaternion passed to it
 * The value passed in IS MODIFIED
 */
void normalizeQ (float q[])
{
	float mag;
	
	mag = sqrtf(q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3]);
	
	q[0] /= mag;
	q[1] /= mag;
	q[2] /= mag;
	q[3] /= mag;
	
	
/*	printf("\nNormalized W: %f", q[0]);
	printf("\nNormalized X: %f", q[1]);
	printf("\nNormalized Y: %f", q[2]);
	printf("\nNormalized Z: %f", q[3]);
*/	
}

// muliplication of quartenions 
void multiplyQ(float q1[], float q2[])
{
	
		float resultQ[4];
		 
		 resultQ[0] = ((q1[0]*q2[0]) - (q1[1]*q2[1]) - (q1[2]*q2[2]) - (q1[3]*q2[3]));
		 resultQ[1] = ((q1[0]*q2[1]) + (q1[1]*q2[0]) + (q1[2]*q2[3]) - (q1[3]*q2[2]));
		 resultQ[2] = ((q1[0]*q2[2]) - (q1[1]*q2[3]) + (q1[2]*q2[0]) + (q1[3]*q2[1]));
		 resultQ[3] = ((q1[0]*q2[3]) + (q1[1]*q2[2]) - (q1[2]*q2[1]) + (q1[3]*q2[0]));
		 
		printf("\nProduct of Quaternions W: %f", resultQ[0]);
		printf("\nProduct of Quaternions X: %f", resultQ[1]);
		printf("\nProduct of Quaternions Y: %f", resultQ[2]);
		printf("\nProduct of Quaternions Z: %f", resultQ[3]);
		 
}

float conjugateQ(float q[])
{
	q[1] = -q[1];
	q[2] = -q[2];
	q[3] = -q[3];
	
	printf("\nConjugate of Quaternion W: %f", q[0]);
	printf("\nConjugate of Quaternion X: %f", q[1]);
	printf("\nConjugate of Quaternion Y: %f", q[2]);
	printf("\nConjugate of Quaternion Z: %f", q[3]);
}

void slerpQ(float q1[], float q2[], float t )
{
	float resultQ[4];
	
	double cosHalfTheta = q1[0] * q2[0] + q1[1] * q2[1] + q1[2]* q2[2] + q1[3] * q2[3];
	
		
	if(cosHalfTheta < 0)
	{
		q2[0] = -q2[0];
		q2[1] = -q2[1];
		q2[2] = -q2[2];
		q2[3] = -q2[3];
		cosHalfTheta = -cosHalfTheta;
	}
	
	if (abs(cosHalfTheta) >= 1.0)
	{
		resultQ[0] = q1[0];
		resultQ[1] = q1[1];
		resultQ[2] = q1[2];
		resultQ[3] = q1[3];
	//	return qm;
		printf("\nSLERP of Quaternions W: %f", resultQ[0]);
		printf("\nSLERP of Quaternions X: %f", resultQ[1]);
		printf("\nSLERP of Quaternions Y: %f", resultQ[2]);
		printf("\nSLERP of Quaternions Z: %f", resultQ[3]);
		return;
	}
	
	double halfTheta = acos(cosHalfTheta);
	double sinHalfTheta = sqrt(1.0 - cosHalfTheta*cosHalfTheta);
	
	if (fabs(sinHalfTheta) < 0.001)
	{ // fabs is floating point absolute
		resultQ[0] = (q1[0] * 0.5 + q2[0] * 0.5);
		resultQ[1] = (q1[1] * 0.5 + q2[1] * 0.5);
		resultQ[2] = (q1[2] * 0.5 + q2[2] * 0.5);
		resultQ[3] = (q1[3] * 0.5 + q2[3] * 0.5);
		//return qm;
		printf("\nSLERP of Quaternions W: %f", resultQ[0]);
		printf("\nSLERP of Quaternions X: %f", resultQ[1]);
		printf("\nSLERP of Quaternions Y: %f", resultQ[2]);
		printf("\nSLERP of Quaternions Z: %f", resultQ[3]);
		return;
	}
	
	double ratioA = sin((1 - t) * halfTheta) / sinHalfTheta;
	double ratioB = sin(t * halfTheta) / sinHalfTheta; 
	//calculate Quaternion.
	resultQ[0] = (q1[0] * ratioA + q2[0] * ratioB);
	resultQ[1] = (q1[1] * ratioA + q2[1] * ratioB);
	resultQ[2] = (q1[2] * ratioA + q2[2] * ratioB);
	resultQ[3] = (q1[3] * ratioA + q2[3] * ratioB);
	//return qm;
	printf("\nSLERP of Quaternions W: %f", resultQ[0]);
	printf("\nSLERP of Quaternions X: %f", resultQ[1]);
	printf("\nSLERP of Quaternions Y: %f", resultQ[2]);
	printf("\nSLERP of Quaternions Z: %f", resultQ[3]);
	return;
	
}

float subtractQ(float q1[], float q2[], float resultQ[])
{
		resultQ[0] = q1[0]-q2[2];
		resultQ[1] = q1[1]-q2[1];
		resultQ[2] = q1[2]-q2[2];
		resultQ[3] = q1[3]-q2[3];
		 
	//	printf("\nSubtraction of Quaternions W: %f", resultQ[0]);
	//	printf("\nSubtraction of Quaternions X: %f", resultQ[1]);
	//	printf("\nSubtraction of Quaternions Y: %f", resultQ[2]);
	//	printf("\nSubtraction of Quaternions Z: %f", resultQ[3]);
}
void toAxisAngle(float q[], float axis[], float *angle)
{
	normalizeQ(q);
	
	axis[3];
	axis[0] = 0;
	axis[1] = 0;
	axis[2] = 0;
	
	*angle = 0;
	
	//if w is 1, then this is a singularity (axis angle is zero)
         if(q[0] ==  1.0 || q[0] == 0.0001)
             return;
 
         float sqw = sqrtf(1.0-(q[0]*q[0]));
 
         if(sqw ==  0.0f || sqw == 0.0001f) //it's a singularity and divide by zero, avoid
             return;
 

		//make sure that this is a pointer because we want to manipulate the value
		*angle = 2 * acosf(q[0]);
		 printf("\nangle is: %f\n", *angle);
         axis[0] = q[1] / sqw;
         axis[1] = q[2] / sqw;
         axis[2] = q[3] / sqw;
		 
		printf("\nVector X component: %f\n",axis[0]);
		printf("Vector Y component: %f\n",axis[1]);
		printf("Vector Z component: %f\n",axis[2]);
	
}
void toAngularVelocity(float q[], float dt)
{
	float vect[3];
	//float q[4];

	if (dt == 0)
	{
		printf("\nVector X component: %f\n",vect[0]);
		printf("Vector Y component: %f\n",vect[1]);
		printf("Vector Z component: %f\n",vect[2]);
		//return vect;
		return;
	}
	
	float angle = 0.0;
	
	//vect * 
	toAxisAngle(q, vect, &angle);
	printf("\nangle is: %f\n", angle);
	vect[0] *= angle;
	vect[1] *= angle;
	vect[2] *= angle;
	//printf("Vector X component: %f\n",vect[0]);
	vect[0] /= dt;
	vect[1] /= dt;
	vect[2] /= dt;
	
	printf("Vector X component: %f\n",vect[0]);
	printf("Vector Y component: %f\n",vect[1]);
	printf("Vector Z component: %f\n",vect[2]);
	
}

void vectorToMatrix(float vectNorth[], float vectEast[], float vectDown[], float rMat[][3])
{
//	float rMat [3][3];
	
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
// should really only take in a matrix to do these calculations to turn it into a quaternion.
//void rotationNewMatrix(float vectNorth[], float vectEast[], float vectDown[]) 
void fromMatrix(float rMat[][3], float quaternion[])
{
	/*
	float rMat [3][3];
	
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
	*/
	
	printf("\nResult: %f", rMat[0][1]);
	
	//printf("\nRotationalMatrix[0][0]:%f ",rMat[0][0]);
	//printf("\nShould be value 2:%f ",rMat[1][0]);
	//printf("\nShould be value 3:%f ",rMat[2][0]);
	
	
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
	
	
//	float q1[4];
//	float q2[4];
	
	/*
	q1[0] = 0;
	//(-sin(PI));
	q1[1] = 3;
	q1[2] = 4;
	q1[3] = 3;
	*/
	
	// this quaternion will ACTUALLY WORK with SLERPing quaternions
/*	q1[0] = 1.322876;
	q1[1] = -.944911;
	q1[2] = .566947;
	q1[3] = .188982;
	
	q2[0] = 4;
	q2[1] = 3.9;
	q2[2] = -1;
	q2[3] = -3;
	
	//multiplyQ(q1, q2);
	//normalizeQ(q);
	slerpQ(q1, q2, .5);
	
	//printf("\nW:%f \n",w);
	//printf("X:%f \n",x);
	//printf("Y:%f \n",y);
	//printf("Z:%f \n",z);
	
	//conjugateQ(q2);
	
	float angVelQ[4];
	float diffQ[4];
	float result[4];
	
	angVelQ[0] = 1.322876;
	angVelQ[1] = -.944911;
	angVelQ[2] = .566947;
	angVelQ[3] = .188982;
	
	diffQ[0] = 4;
	diffQ[1] = 3.9;
	diffQ[2] = -1;
	diffQ[3] = -3;
	
	//subtractQ(angVelQ, diffQ, result);
	//printf("\nResult: %f", result[1]);
	//toAngularVelocity(g, .05);
	toAngularVelocity(diffQ, 0.5);
	*/
}

/*
float normalizeVect(float vect[], float vecResult[])
{
	float w = sqrt( vect[0] * vect[0] + vect[1] * vect[1] + vect[2] * vect[2] );
   vecResult[0] = vect[0] / w;
   vecResult[1] = vect[1] / w;
   vecResult[2] = vect[2] / w;
	
}
*/
float normalizeVect(float vect[])
{
	float w = sqrt( vect[0] * vect[0] + vect[1] * vect[1] + vect[2] * vect[2] );
	vect[0] /= w;
	vect[1] /= w;
	vect[2] /= w;
		
	return *vect;
}
