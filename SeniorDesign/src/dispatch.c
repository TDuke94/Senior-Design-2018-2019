/*
 * dispatch.c
 *
 * Author: Timothy Duke
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * The primary task dispatcher
 *
 * Revision History:
 * 		- v0.0 - December 20, 2019 - Initial release of task dispatcher
 * 		- v1.0 - February 14, 2019 - Updated for I2C_Release
 * 		- v1.1 - February 15, 2019 - Updated for Pipeline Integration
 */

#include "dispatch.h"

// helper functions
void printError (void);

/*
 * dispatchPipeline
 *
 * input:
 * 		void
 *
 * 	output:
 * 		void
 */

TaskHandle_t xI2CHandle;

void dispatchPipeline(void)
{
	int STACK_SIZE = 400;
	int QueueLength = 10;
	int BlockSize = sizeof(void *);

	QueueHandle_t Queue_1, Queue_2, Queue_3, Queue_4, Queue_5;

	QueueData *Q_Data_1, *Q_Data_2, *Q_Data_3, *Q_Data_4, *Q_Data_5, *Q_Data_6;

	BaseType_t xReturned;

	xI2CHandle = NULL;
	TaskHandle_t xSetupHandle = NULL;
	TaskHandle_t xVectQuatHandle = NULL;
	TaskHandle_t xFilterHandle = NULL;
	TaskHandle_t xSlerpHandle = NULL;
	TaskHandle_t xSPIHandle = NULL;

	/*
	 * Create the Queue
	 */
	Queue_1 = xQueueCreate(QueueLength, BlockSize);

	// Allocate space to store data
	Q_Data_1 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_1->inputQueue = NULL;
	Q_Data_1->outputQueue = Queue_1;

	xReturned = xTaskCreate(
					I2C_Task,
					"I2C",
					STACK_SIZE,
					(void *) Q_Data_1,
					tskIDLE_PRIORITY + 2,
					&xI2CHandle
					);

	if (xReturned != pdPASS) printError();

	/*
	 * Create the Queue
	 */
	Queue_2 = xQueueCreate(QueueLength, BlockSize);

	// Allocate space to store data
	Q_Data_2 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_2->inputQueue = Queue_1;
	Q_Data_2->outputQueue = Queue_2;

	xReturned = xTaskCreate(
					QMathSetupTask,
					"QPrint",
					STACK_SIZE,
					(void *) Q_Data_2,
					tskIDLE_PRIORITY + 1,
					&xSetupHandle
					);

	if (xReturned != pdPASS) printError();

	/*
	 * Create the Queue
	 */
	Queue_3 = xQueueCreate(QueueLength, BlockSize);

	// Allocate space to store data
	Q_Data_3 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_3->inputQueue = Queue_2;
	Q_Data_3->outputQueue = Queue_3;

	xReturned = xTaskCreate(
					QVectorToQuaternionTask,
					"QPrint",
					STACK_SIZE,
					(void *) Q_Data_3,
					tskIDLE_PRIORITY + 1,
					&xVectQuatHandle
					);

	if (xReturned != pdPASS) printError();

	/*
	 * Create the Queue
	 */
	Queue_4 = xQueueCreate(QueueLength, BlockSize);

	// Allocate space to store data
	Q_Data_4 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_4->inputQueue = Queue_3;
	Q_Data_4->outputQueue = Queue_4;

	xReturned = xTaskCreate(
					QQuaternionFilterTask,
					"QPrint",
					STACK_SIZE,
					(void *) Q_Data_4,
					tskIDLE_PRIORITY + 1,
					&xFilterHandle
					);

	if (xReturned != pdPASS) printError();

	/*
	 * Create the Queue
	 */
	Queue_5 = xQueueCreate(QueueLength, BlockSize);

	// Allocate space to store data
	Q_Data_5 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_5->inputQueue = Queue_4;
	Q_Data_5->outputQueue = Queue_5;

	xReturned = xTaskCreate(
					QSlerpTask,
					"QSlerp",
					STACK_SIZE,
					(void *) Q_Data_5,
					tskIDLE_PRIORITY + 1,
					&xSlerpHandle
					);

	if (xReturned != pdPASS) printError();

	// Allocate space to store data
	Q_Data_6 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_6->inputQueue = Queue_5;
	Q_Data_6->outputQueue = NULL;

	xReturned = xTaskCreate(
					SPI_Task,
					"SPI",
					STACK_SIZE,
					(void *) Q_Data_6,
					tskIDLE_PRIORITY + 1,
					&xSPIHandle
					);

	if (xReturned != pdPASS) printError();

	// start the scheduler
	vTaskStartScheduler();

	// return to main - safe even if scheduler crashes, enters infinite loop back in main()
	return;
}

/*
 * continualDispatcher
 *
 * for now, empty function
 */
void continualDispatcher (void * parameter)
{
	// for now, this is empty
	return;
}

void printError (void)
{
	xil_printf("error in creating task");
}

