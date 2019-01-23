/*
 * data.c
 *
 * Author: Daniel Gutierrez
 *
 *  * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Timothy D.
 * 		Fred D.
 * 		Linnette M.
 *
 * main function for MathLibraryVersion2...
 * Basically laying out the order in which to conduct certain operations on given data.
 */
#include "MathLibraryVersion2.h"

int main(void) 
{ 
	// defining and allocating space our input vectors: North, East, Down(accelerometer data) and magnometer data
	float vectEast[3]; 
	float vectNorth[3]; 
	float vectDown[3];
	float vectMagRead[3];	
	//float normalVect[3];
	
	// defining the and allocating space for the rotation matrix and quaternions that are generated
	float matrix[3][3];
	float quaternion [4];
	float q2[4];	
	
	// these are the input vectors being hard-coded in.(Accelerometer and Magnetometer)
	vectMagRead[0] = 0.761905;
	vectMagRead[1] = -0.190476;
	vectMagRead[2] = -0.619048;
	vectDown[0] = 0.380953;
	vectDown[1] = 0.904762;
	vectDown[2] = 0.190476;

	printf("\nVector East:");
	crossProduct(vectDown, vectMagRead, vectEast); 
	for (int i = 0; i < 3; i++) 
		printf("%f ", vectEast[i]);
	
		printf("\nVector North:");
	crossProduct(vectEast, vectDown, vectNorth); 
		
	for (int i = 0; i < 3; i++) 
		printf("%f ", vectNorth[i]);
	
	
	normalizeVect(vectNorth);
	normalizeVect(vectEast);
	normalizeVect(vectDown);
	for (int i = 0; i < 3; i++) 
		printf("\nVector North[%d] normalized:%f ", i, vectNorth[i]);
	for (int i = 0; i < 3; i++) 
		printf("\nVector East[%d] normalized:%f ", i , vectEast[i]);
	for (int i = 0; i < 3; i++) 
		printf("\nVector Down[%d] normalized:%f ", i , vectDown[i]);
	
	
	vectorToMatrix(vectNorth, vectEast, vectDown, matrix);
   
    fromMatrix(matrix, quaternion);
	
	normalizeQ(quaternion);
    
	//slerpQ(quaternion, q2, .5);
	
//	qDiff = last_accel_q.conjugate() * accel_q;
//	last_accel_q = accel_q;
	
    q2[0] = 4;
	q2[1] = 3.9;
	q2[2] = -1;
	q2[3] = -3;
	
   
	//Quaternion qw(1, w.x()*dt/2.0, w.y()*dt/2.0, w.z()*dt/2.0);
	//qw.normalize();
	
	conjugateQ(quaternion);
	
	toAngularVelocity(quaternion, 0.5);
   
    
   
//	printf("\nResult: %f", matrix[0][0]);
//	printf("\nResult: %f", matrix[0][1]);
	
	
	
	
	return 0; 
} 