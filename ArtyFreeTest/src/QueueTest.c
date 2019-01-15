/*
 * QueueTest.c
 *
 * Author: Timothy Duke/Daniel Guttierez
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Fred D.
 * 		Linnette M.
 *
 * Version:
 * 		0.0 - December 28, 2018 - initial test of queues
 * 		0.1 - January 3, 2019 - test of dynamic allocated queue and data motion (4 tasks)
 *
 * Test of Queue functionality in FreeRTOS
 * 		- Two tasks
 * 		- Initialize a Queue Between them (note: task 1 creates task after initialization)
 */

#include "QueueTest.h"

/*
 * SendTask
 *
 * sends data to the queue
 *
 * queue must be created externally with xQueueCreate
 *
 * input:
 * 		- QueueData (struct)
 */
void QStartTask(void *parameters)
{
	int queueLength, blockSize, DelayFlag, i;

	// data sent through this queue
	int *array;

	QueueHandle_t outputQueue;

	QueueData myQueueData;

	xil_printf("in_1");

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QStartTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	outputQueue = myQueueData.outputQueue;
	queueLength = myQueueData.queueLength;
	blockSize = myQueueData.blockSize;

	// set DelayFlag to FALSE, no initial delay
	DelayFlag = FALSE;

	for (;;)
	{
		// check for delay
		if (DelayFlag == TRUE)
		{
			// Reset Flag
			DelayFlag = FALSE;

			// Delay
			vTaskDelay(200);
		}

		// send condition checking, currently false
		if (FALSE)
		{
			// Avoid Spin, cause delay
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		// allocate the array
		array = pvPortMalloc(10 * sizeof(int));

		for (i = 0; i < 10; i++)
		{
			array[i] = i;
		}

		configASSERT ( outputQueue );

		xQueueSend(outputQueue, (void *) &array, (TickType_t) 0);

		// task termination condition, currently false, leads to task termination
		if (FALSE)
		{
			xil_printf("Start Task Termination Called\n");
			break;
		}
	}

	// Don't fall off the end
	vTaskDelete(NULL);
}

/*
 * QAddTask Task
 *
 * Take Data from the queue, adds 1, puts in next queue
 *
 * input:
 * 		- QueueData (struct)
 */
void QAddTask(void *parameters)
{
	int queueLength, blockSize, DelayFlag, i;

	int * array;

	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;

	xil_printf("in_2");

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QAddTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;
	outputQueue = myQueueData.outputQueue;
	queueLength = myQueueData.queueLength;
	blockSize = myQueueData.blockSize;

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

		// RX Condition Checking - queue is not empty
		if (inputQueue == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		// take from Buffer
		xQueueReceive (inputQueue, (void*) &array, (TickType_t) 5);

		for (i = 0; i < 10; i++)
		{
			array [i] += 1;
		}

		xQueueSend (outputQueue, (void*) &array, (TickType_t) 5);

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
 * QMultTask Task
 *
 * Take Data from the queue, multiplies it by 2, puts in next queue
 *
 * input:
 * 		- QueueData (struct)
 */
void QMultTask(void *parameters)
{
	int queueLength, blockSize, DelayFlag, i;

	int * array;

	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;

	xil_printf("in_3");

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QMultTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;
	outputQueue = myQueueData.outputQueue;
	queueLength = myQueueData.queueLength;
	blockSize = myQueueData.blockSize;

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

		// RX Condition Checking - queue is not empty
		if (inputQueue == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		// take from Buffer
		xQueueReceive (inputQueue, (void*) &array, (TickType_t) 5);

		for (i = 0; i < 10; i++)
		{
			array [i] *= 2;
		}

		xQueueSend (outputQueue, (void*) &array, (TickType_t) 5);

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
 * QPrintTask Task
 *
 * Take Data from the queue
 *
 * input:
 * 		- QueueData (struct)
 */
void QPrintTask(void *parameters)
{
	int queueLength, blockSize, DelayFlag, i;

	int * array;

	QueueHandle_t inputQueue;

	QueueData myQueueData;

	xil_printf("in_4");

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QPrintTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;
	queueLength = myQueueData.queueLength;
	blockSize = myQueueData.blockSize;

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

		// RX Condition Checking - queue is not empty
		if (inputQueue == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		// take from Buffer
		xQueueReceive (inputQueue, (void*) &array, (TickType_t) 5);

		for (i = 0; i < 10; i++)
		{
			xil_printf("%d\n", array[i]);
		}
		xil_printf("\n");

		vPortFree(array);

		// Termination Condition Checking
		if (FALSE)
		{
			xil_printf("Print Task Termination Called\n");
			break;
		}
	}

	vTaskDelete(NULL);
}

