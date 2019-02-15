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
 */

#include "dispatch.h"
#include "FreeRTOS.h"
#include "QueueTest.h"
#include "I2C_manager.h"

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

void dispatchPipeline(void)
{
	int STACK_SIZE = 400;
	int QueueLength = 5;
	int BlockSize = 5;

	QueueHandle_t Queue_1;

	QueueData *Q_Data_1, *Q_Data_2;

	BaseType_t xReturned;

	TaskHandle_t xQPrintHandle = NULL;
	TaskHandle_t xI2CHandle = NULL;

	/*
	 * Create the Queue
	 */
	Queue_1 = xQueueCreate(QueueLength, BlockSize);

	// Allocate space to store data
	Q_Data_1 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_1->inputQueue = NULL;
	Q_Data_1->outputQueue = Queue_1;
	Q_Data_1->queueLength = QueueLength;
	Q_Data_1->blockSize = BlockSize;

	xReturned = xTaskCreate(
					I2C_Task,
					"I2C",
					STACK_SIZE,
					(void *) Q_Data_1,
					tskIDLE_PRIORITY + 1,
					&xI2CHandle
					);

	if (xReturned != pdPASS) printError();

	// Allocate space to store data
	Q_Data_2 = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data_2->inputQueue = Queue_1;
	Q_Data_2->outputQueue = NULL;
	Q_Data_2->queueLength = QueueLength;
	Q_Data_2->blockSize = BlockSize;

	xReturned = xTaskCreate(
					QPrintTask,
					"QPrint",
					STACK_SIZE,
					(void *) Q_Data_2,
					tskIDLE_PRIORITY + 1,
					&xQPrintHandle
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

