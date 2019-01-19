#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
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
	
	/*
	printf("\nNormalized W: %f", q[0]);
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
	
}


// should really only take in a matrix to do these calculations to turn it into a quaternion.
void rotationNewMatrix(float vectNorth[], float vectEast[], float vectDown[]) 
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
	
	printf("\nRotationalMatrix[0][0]:%f ",rMat[0][0]);
	printf("\nShould be value 2:%f ",rMat[1][0]);
	printf("\nShould be value 3:%f ",rMat[2][0]);
	
	
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
	
	float q1[4];
	float q2[4];
	
	q1[0] = 0;
	//(-sin(PI));
	q1[1] = 3;
	q1[2] = 4;
	q1[3] = 3;
	
	q2[0] = 4;
	q2[1] = 3.9;
	q2[2] = -1;
	q2[3] = -3;
	
	multiplyQ(q1, q2);
	//normalizeQ(q);
	slerpQ(q1, q2, 0.5);
	
	printf("\nW:%f \n",w);
	printf("X:%f \n",x);
	printf("Y:%f \n",y);
	printf("Z:%f \n",z);
	
	conjugateQ(q2);
	
	
}

float normalizeVect(float vect[], float vecResult[])
{
	float w = sqrt( vect[0] * vect[0] + vect[1] * vect[1] + vect[2] * vect[2] );
   vecResult[0] = vect[0] / w;
   vecResult[1] = vect[1] / w;
   vecResult[2] = vect[2] / w;
	//printf("this is w: %f", w);
	//return vect[0];
	/*printf("%f ", vect[0]);
	printf("%f ", vect[1]);
	printf("%f", vect[2]);*/
	
}

int main() 
{ 
	//North, East, Down
	float vect_A[] = {1, 2, 3 }; 
	float vect_B[] = { 1,2,3 }; 
	// magn
	float vect_C[] = { 1,2,3}; 
	
	
	float cross_P[3]; 
	float vectEast[3]; 
	float vectNorth[3]; 
	float vectDown[3];
	float normalVect[3];

	//printf("Cross Product:%d\n", crossProduct(vect_A, vect_B, cross_P)); 
	printf("Cross Product:");
	crossProduct(vect_A, vect_B, cross_P); 
	
	for (int i = 0; i < 3; i++) 
		printf("%f ", cross_P[i]);
	//return 0; 
	crossProduct(vect_B, vect_C, cross_P); 
	
	normalizeVect(vect_A, normalVect);
	memcpy(vectEast, normalVect, sizeof(vectEast));
	//vectEast = normalVect;
	for (int i = 0; i < 3; i++) 
		printf("\nVector 1 normalized:%f ", normalVect[i]);
	
	
	normalizeVect(vect_B, normalVect);
	memcpy(vectNorth, normalVect, sizeof(vectNorth));
	for (int i = 0; i < 3; i++) 
		printf("\nVector 2 normalized:%f ", normalVect[i]);
	
	normalizeVect(vect_C, normalVect);
	memcpy(vectDown, normalVect, sizeof(vectDown));
	
	
	vectNorth[0] = 0.761905;
	vectNorth[1] = -0.190476;
	vectNorth[2] = -0.619048;
	vectEast[0] = -0.523809;
	vectEast[1] = 0.380953;
	vectEast[2] = -0.761905;
	vectDown[0] = 0.380953;
	vectDown[1] = 0.904762;
	vectDown[2] = 0.190476;
	
	
/*	for (int i = 0; i < 3; i++) 
		printf("\nVector 1 normalized:%f ", vectNorth[i]);
	for (int i = 0; i < 3; i++) 
		printf("\nVector 2 normalized:%f ", vectEast[i]);
	for (int i = 0; i < 3; i++) 
		printf("\nVector 3 normalized:%f ", vectDown[i]);
*/	
	rotationNewMatrix(vectNorth, vectEast, vectDown);
	
	
	return 0; 
} 
