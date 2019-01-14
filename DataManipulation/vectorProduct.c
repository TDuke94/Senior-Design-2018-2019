
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

float crossProduct(float vect1[], float vect2[], float cross_P[]) 

{ 

	cross_P[0] = vect1[1] * vect2[2] - vect1[2] * vect2[1]; 
	cross_P[1] = vect1[0] * vect2[2] - vect1[2] * vect2[0]; 
	cross_P[2] = vect1[0] * vect2[1] - vect1[1] * vect2[0]; 
} 

void normalizeVect(float vect[])
{
	float w = sqrt( vect[0] * vect[0] + vect[1] * vect[1] + vect[2] * vect[2] );
    vect[0] /= w;
    vect[1] /= w;
    vect[2] /= w;
	//printf("this is w: %f", w);
	//return vect[0];
	printf("%f ", vect[0]);
	printf("%f ", vect[1]);
	printf("%f", vect[2]);
	
}

int main() 
{ 
	// simiulating our read
	float vect_A[] = {1, 12, 53}; 
	float vect_B[] = { 21, 75.3, 113.73}; 
	float cross_P[3]; 

	//printf("Cross Product:%d\n", crossProduct(vect_A, vect_B, cross_P)); 
	printf("Cross Product:");
	crossProduct(vect_A, vect_B, cross_P); 

	for (int i = 0; i < 3; i++) 
		printf("%f ", cross_P[i]);
	//return 0; 
	
	printf("\nVector 1 normalized:");
	normalizeVect(vect_A);
	printf("\nVector 2 normalized: ");
	normalizeVect(vect_B);
	
	return 0; 
} 
