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
#include "xgpio.h"

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

	QueueHandle_t Queue_1, Queue_2, Queue_3;

	QueueData *Q_Data;

	BaseType_t xReturned;

	TaskHandle_t xQStartHandle = NULL;
	TaskHandle_t xQAddHandle = NULL;
	TaskHandle_t xQMultHandle = NULL;
	TaskHandle_t xQPrintHandle = NULL;

	/*
	 * Create the Queues
	 */
	Queue_1 = xQueueCreate(QueueLength, BlockSize);
	Queue_2 = xQueueCreate(QueueLength, BlockSize);
	Queue_3 = xQueueCreate(QueueLength, BlockSize);

	/*
	 * The next Two Tasks require parameters, including an initialized Queue
	 *
	 * parameters are a QueueData type struct
	 */

	// Allocate space to store data
	Q_Data = pvPortMalloc(sizeof(QueueData));

	// load queues for first task
	Q_Data->inputQueue = NULL;
	Q_Data->outputQueue = Queue_1;
	Q_Data->queueLength = QueueLength;
	Q_Data->blockSize = BlockSize;

	xReturned = xTaskCreate(
					QStartTask,
					"QStart",
					STACK_SIZE,
					(void *) Q_Data,
					tskIDLE_PRIORITY + 1,
					&xQStartHandle
					);

	if (xReturned != pdPASS) printError();

	// load queues for second task
	Q_Data->inputQueue = Queue_1;
	Q_Data->outputQueue = Queue_2;
	Q_Data->queueLength = QueueLength;
	Q_Data->blockSize = BlockSize;

	xReturned = xTaskCreate(
					QAddTask,
					"QAdd",
					STACK_SIZE,
					(void *) Q_Data,
					tskIDLE_PRIORITY + 1,
					&xQAddHandle
					);

	if (xReturned != pdPASS) printError();

	// load queues for first task
	Q_Data->inputQueue = Queue_2;
	Q_Data->outputQueue = Queue_3;
	Q_Data->queueLength = QueueLength;
	Q_Data->blockSize = BlockSize;

	xReturned = xTaskCreate(
					QMultTask,
					"QMult",
					STACK_SIZE,
					(void *) Q_Data,
					tskIDLE_PRIORITY + 1,
					&xQMultHandle
					);

	if (xReturned != pdPASS) printError();

	// load queues for first task
	Q_Data->inputQueue = Queue_3;
	Q_Data->outputQueue = NULL;
	Q_Data->queueLength = QueueLength;
	Q_Data->blockSize = BlockSize;

	xReturned = xTaskCreate(
					QPrintTask,
					"QPrint",
					STACK_SIZE,
					(void *) Q_Data,
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

