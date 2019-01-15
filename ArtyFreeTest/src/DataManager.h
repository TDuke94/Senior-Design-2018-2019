/*
 * DataManager.h
 *
 * Author: Timothy Duke
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * Revision History:
 *
 * Date				Version			Summary
 * ====				=======			=======
 * 12/28/2018		0.0				Initial Revision
 *
 * Header for DataManager, primary storage of Enqueued data
 */

#ifndef DATA_MANAGER_H
#define DATA_MANAGER_H

typedef struct IMUData
{
	float accelData[3];
	float magData[3];
	float gyroData[3];
	int invalidFlag;
} IMUData;

// IMU ID enumeration
enum IMU_ID
{
	shoulder1, shoulder2,
	upperArm1,	upperArm2,
	elbow1,		elbow2,
	wrist1,		wrist2,
	carpal1,	carpal2,
	metacarpalI, metacarpalII_III, metacarpalIV_V,
	proxPhalangesI, proxPhalangesII, proxPhalangesIII, proxPhalangesIV, proxPhalangesV,
	intPhalangesII, intPhalangesIII, intPhalangesIV, intPhalangesV,
	distPhalangesI, distPhalangesII, distPhalangesIII, distPhalangesIV, distPhalangesV
} IMU_ID;

#define IMU_NUMBER 27

typedef struct IMUSet
{
	IMUData data[IMU_NUMBER];
	int timestamp;
} IMUSet;

/*
 *
 */

#endif
