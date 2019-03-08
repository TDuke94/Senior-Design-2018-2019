/*
 * QueueTest.c
 *
 * Author: Timothy Duke/Daniel Guttierez
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Fred D.
 * 		Linnette M.
 * Test of Queue functionality in FreeRTOS
 * 		- Two tasks
 * 		- Initialize a Queue Between them (note: task 1 creates task after initialization)
 *
 * Revision History:
 * 		- v0.0 - December 28, 2018 - initial test of queues
 * 		- v0.1 - January 3, 2019 - test of dynamic allocated queue and data motion (4 tasks)
 * 		- v1.0 - February 12, 2019 - Integrated as IMU_Pipeline, Connected with I2C_Manager
 */

#include "IMU_Pipeline.h"
#include "MathLibrary.h"
#include "xil_printf.h"

/*
 * Full Scale Range, input from IMU Data
 *
 * This is loaded from the MSP430 at the start of the I2C Task
 */
extern short accel_fsr;
extern short gyro_fsr;
extern short mag_fsr;

/*
 * QMathSetupTask Task
 *
 * Take Data from the queue, rearranges into neat struct, puts in next queue
 *
 * input:
 * 		- QueueData (struct)
 */
void QMathSetupTask(void *parameters)
{
	int DelayFlag, i, j;

	u8 *InBuffer;

	IMU_Data_Int **OutArray;

	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QAddTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;
	outputQueue = myQueueData.outputQueue;

	// I no longer need you, give back to Heap
	vPortFree(parameters);

	// set Delay Flag to true, start with a delay
	DelayFlag = TRUE;

	for (;;)
	{
		// delay if flag is set
		if(DelayFlag == TRUE)
		{
			// clear flag
			DelayFlag = FALSE;
			// delay
			vTaskDelay (200);
		}

		// clear the array pointer
		InBuffer = NULL;

		/*
		 * Take from Buffer, including RX Condition Checking
		 */
		/* legacy version
		if (uxQueueMessagesWaiting(inputQueue) == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}
		*/

		// alternate version, needs to be tested
		if (xQueueReceive (inputQueue, &InBuffer, portMAX_DELAY)!= pdPASS)
		{
			DelayFlag = TRUE;
			continue;
		}

		OutArray = pvPortMalloc(IMU_COUNT * sizeof(IMU_Data_Int *));

		/*
		 * Iterate over IMUs, allocate a data struct, put the data back together again
		 */
		for (i= 0; i < IMU_COUNT; i++)
		{
			OutArray[i] = pvPortMalloc(sizeof(IMU_Data_Int));
			for (j = 0; j < 3; j++)
			{
				OutArray[i]->accel[j]	= (short) InBuffer[2 * j + (i * 18)] << 8		| InBuffer[2 * j + 1 + (i * 18)];
				OutArray[i]->gyro[j]	= (short) InBuffer[2 * j + 6 + (i * 18)] << 8 	| InBuffer[2 * j + 7 + (i * 18)];
				OutArray[i]->mag[j]		= (short) InBuffer[2 * j + 12 + (i * 18)] << 8 	| InBuffer[2 * j + 13 + (i * 18)];
				// TIMESTAMP
			}
		}

		/*
		 * Enqueue, if failed, free to avoid a leak
		 */
		if (xQueueSend (outputQueue, &OutArray, portMAX_DELAY) != pdPASS)
			vPortFree(OutArray);

		vPortFree(InBuffer);

		// Termination Condition Checking
		if (FALSE)
		{
			xil_printf("Add Task Termination Called\n");
			break;
		}
	}

	vTaskDelete(NULL);
}

/*
 * QMatrixToQuaternionTask()
 *
 * Take Data from the queue, converts raw IMU to Quaternion, puts in next queue
 *
 * input:
 * 		- QueueData (struct)
 */
void QVectorToQuaternionTask(void *parameters)
{
	int DelayFlag, i, j;

	/*
	IMU_Data_Int ** InArray;
	*/

	IMU_Data_Int *InArray;

	float * OutArray;

	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;

	// Local Math Variables
	float vectEast[3];
	float vectDown[3];
	float vectNorth[3];
	float rawMag[3];
	float matrix[3][3];
	float quaternion[4];

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QMultTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;
	outputQueue = myQueueData.outputQueue;

	// I no longer need you, give back to Heap
	vPortFree(parameters);

	// set Delay Flag to true, start with a delay
	DelayFlag = TRUE;

	for (;;)
	{
		// delay if flag is set
		if(DelayFlag == TRUE)
		{
			// clear flag
			DelayFlag = FALSE;
			// delay
			vTaskDelay (200);
		}

		// clear the array pointer
		InArray = NULL;

		/*
		 * Take from Buffer, including RX Condition Checking
		 */
		if (uxQueueMessagesWaiting(inputQueue) == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		xQueueReceive (inputQueue, &InArray, portMAX_DELAY);

		// allocate IMU_COUNT Quaternions
		OutArray = pvPortMalloc(IMU_COUNT * sizeof(float) * 8);

		/*
		 * Do the Math
		 */
		for (i= 0; i < IMU_COUNT; i++)
		{
			for (j = 0; j < 3; j++)
			{
				// modified for test
				vectDown[j] =	(float) InArray[i].accel[j];
				rawMag[j] 	=	(float) InArray[i].mag[j];
			}

			crossProduct(vectDown, rawMag, vectEast);
			crossProduct(vectEast,vectDown, vectNorth);

			// these function might change over time(integer space incoming)
			normalizeVect(vectNorth);
			normalizeVect(vectEast);
			normalizeVect(vectDown);

			vectorToMatrix(vectNorth, vectEast, vectDown, matrix);

			fromMatrix(matrix, quaternion);

			normalizeQ(quaternion);

			for (j = 0; j < 8; j++)
			{
				if (j < 3)
					OutArray[i * 8 + j] = (float) InArray[i].gyro[j];
				else if (j > 3)
					OutArray[i * 8 + j] = quaternion[j];
			}
		}

		/*
		 * Enqueue, if failed, free to avoid a leak
		 */
		if (xQueueSend (outputQueue, &OutArray, portMAX_DELAY) != pdPASS)
			vPortFree(OutArray);

		vPortFree(InArray);

		// Termination Condition Checking
		if (FALSE)
		{
			xil_printf("Mult Task Termination Called\n");
			break;
		}
	}

	vTaskDelete(NULL);
}

/*
 * QQuaternionFilterTask() Task
 *
 * Take Data from the queue, applies filters, puts in next queue
 *
 * input:
 * 		- QueueData (struct)
 */
void QQuaternionFilterTask(void *parameters)
{
	u8 DelayFlag, FirstFlag;

	int i, j;

	float * InArray;

	float gyroVector[3];
	float gyroQuaternion[4];
	float gyroMult[4];
	float gyroAccumulator[4 * IMU_COUNT];

	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QQuaternionFilterTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;
	outputQueue = myQueueData.outputQueue;

	// I no longer need you, give back to Heap
	vPortFree(parameters);

	// set Delay Flag to true, start with a delay
	DelayFlag = TRUE;

	FirstFlag = TRUE;

	for (;;)
	{
		// delay if flag is set
		if(DelayFlag == TRUE)
		{
			// clear flag
			DelayFlag = FALSE;
			// delay
			vTaskDelay (200);
		}

		// clear the array pointer
		InArray = NULL;

		/*
		 * Take from Buffer, including RX Condition Checking
		 */
		if (uxQueueMessagesWaiting(inputQueue) == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		xQueueReceive (inputQueue, &InArray, portMAX_DELAY);

		for (i = 0; i < IMU_COUNT; i++)
		{
			for (j = 0; j < 3; j++)
				gyroVector[j] = InArray[i * 8 + j];

			fromAngularVelocity(gyroVector, 1 / GYRO_RATE, gyroQuaternion);

			if (FirstFlag == TRUE)
			{
				FirstFlag = FALSE;

				for (j = 0; j < 4; j++)
					gyroAccumulator[i * 4 + j] = gyroQuaternion[j];
			}
			else
			{
				// optimization would be nice here :)
				for (j = 0; j < 4; j++)
					gyroMult[j] = gyroAccumulator[i * 4 + j];

				multiplyQ(gyroMult, gyroQuaternion, gyroMult);

				for (j = 0; j < 4; j++)
					gyroAccumulator[i * 4 + j] = gyroMult[j];
			}

			for (j = 0; j < 4; j++)
				InArray[i * 8 + j] = gyroAccumulator[j];
		}

		/*
		 * Enqueue, if failed, free to avoid a leak
		 */
		if (xQueueSend (outputQueue, &InArray, portMAX_DELAY) != pdPASS)
			vPortFree(InArray);

		// Termination Condition Checking
		if (FALSE)
		{
			xil_printf("Quaternion Filter Task Termination Called\n");
			break;
		}
	}

	vTaskDelete(NULL);
}

/*
 * QSlerpTask
 *
 * Takes Data from Queue, performs SLERP, places in the next Queue
 *
 * input:
 * 		- QueueData (struct)
 */
void QSlerpTask(void *parameters)
{
	int DelayFlag, i, j;

	float * InArray;
	float * OutArray;

	float qGyro[4];
	float qCross[4];
	float qOut[4];

	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QPrintTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;
	outputQueue = myQueueData.outputQueue;

	// I no longer need you, give back to Heap
	vPortFree(parameters);

	// set Delay Flag to true, start with a delay
	DelayFlag = TRUE;

	for (;;)
	{
		// delay if flag is set
		if(DelayFlag == TRUE)
		{
			// clear flag
			DelayFlag = FALSE;
			// delay
			vTaskDelay (200);
		}

		// clear the array pointer
		InArray = NULL;

		/*
		 * Take from Buffer, including RX Condition Checking
		 */
		if (uxQueueMessagesWaiting(inputQueue) == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		xQueueReceive (inputQueue, &InArray, portMAX_DELAY);

		OutArray = pvPortMalloc(IMU_COUNT * sizeof(float) * 4);

		for (i = 0; i < IMU_COUNT; i++)
		{
			for (j = 0; j < 4; j++)
			{
				qGyro[j] = InArray[i * 8 + j];
				qCross[j] = InArray[i * 8 + j + 4];
			}

			slerpQ(qGyro, qCross, qOut, GYRO_SLERP_GAIN);

			for (j = 0; j < 4; j++)
				OutArray[i * 4 + j] = qOut[j];
		}

		/*
		 * Enqueue, if failed, free to avoid a leak
		 */
		if (xQueueSend (outputQueue, &OutArray, portMAX_DELAY) != pdPASS)
			vPortFree(OutArray);

		vPortFree(InArray);

		// Termination Condition Checking
		if (FALSE)
		{
			xil_printf("Print Task Termination Called\n");
			break;
		}
	}

	vTaskDelete(NULL);
}

