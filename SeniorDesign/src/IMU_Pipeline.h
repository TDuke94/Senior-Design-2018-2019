/*
 * IMU_Pipeline.h
 *
 * Author: Timothy Duke/Daniel Guttierez
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Fred D.
 * 		Linnette M.
 *
 * Test of IMU Half of Queue functionality in FreeRTOS
 * 		- 4 tasks
 * 		- Receive Data from I2C Handler
 * 		- Send Data to Human
 *
 * Revision:
 * 		- v0.0 - December 28, 2018 - initial test of queues
 * 		- v1.0 - February 25, 2019 - Integrated as IMU_Pipeline, Connected with I2C_Manager
 */

#ifndef IMU_PIPELINE_H
#define IMU_PIPELINE_H

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"

// Global IMU Count Definition
#define IMU_COUNT 1
#define GYRO_RATE 1000.0
#define GYRO_LERP_GAIN 0.5
#define GYRO_SLERP_GAIN 0.5

// Queue Data Set
typedef struct QueueData
{
	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;
	int blockSize;
} QueueData;

// IMU Data Structs
typedef struct IMU_Data_Int
{
	short accel[3];
	short gyro[3];
	short mag[3];
	long timestamp;
} IMU_Data_Int;

typedef struct IMU_Data_Float
{
	float accel[3];
	float gyro[3];
	float mag[3];
	long timestamp;
} IMU_Data_Float;

// primary task functions
void QMathSetupTask(void *);
void QVectorToQuaternionTask(void *);
void QQuaternionFilterTask(void *);
void QSlerpTask(void *);

#endif
