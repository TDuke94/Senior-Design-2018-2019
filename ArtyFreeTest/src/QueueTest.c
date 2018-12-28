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
 * Test of Queue functionality in FreeRTOS
 * 		- Two tasks
 * 		- Initialize a Queue Between them (note: task 1 creates task after initialization)
 */

#include "QueueTest.h"

/* QueueHandle used by both tasks herein located
 *
 * Likely will move this internal to the two tasks and initialize outside
 * This then enables the task to be the queue manager
 * but use the same functions for multiple queue-tasks
 */
QueueHandle_t myQueue;

/*
 * SendTask
 *
 * sends data to the queue
 *
 * queue must be created externally with xQueueCreate
 *
 * input:
 * 		- parameters[0] -> queueHandle
 * 		- parameters[1] -> size of queue
 * 		- parameters[2] -> size of each block
 */
void SendTask(void *parameters)
{
	char TXBuffer[30];
	int queueLength, blockSize, DelayFlag, i;
	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to SendTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	myQueue = myQueueData.inputQueue;
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

		for (i = 0; i < 10; i++)
		{
			TXBuffer[i] = (char) (i + 65);
		}

		xQueueSend(myQueue, (void *) TXBuffer, (TickType_t) 0);

		// task termination condition, currently false, leads to task termination
		if (FALSE)
		{
			xil_printf("TX Task Termination Called\n");
			break;
		}
	}

	// Don't fall off the end
	vTaskDelete(NULL);
}

/*
 * Receive Task
 *
 * Take Data from the queue
 *
 * input:
 * 		- parameters[0] -> queueHandle
 * 		- parameters[1] -> size of queue
 * 		- parameters[2] -> size of each block
 */
void ReceiveTask(void *parameters)
{
	char RXBuffer[30];
	int queueLength, blockSize, DelayFlag;
	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to ReceiveTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	myQueue = myQueueData.inputQueue;
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
		if (myQueue == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		// take from Buffer
		xQueueReceive (myQueue, (void*) RXBuffer, (TickType_t) 5);

		// Use the Data
		xil_printf(RXBuffer);

		// Termination Condition Checking
		if (FALSE)
		{
			xil_printf("RX Task Termination Called\n");
			break;
		}
	}

	vTaskDelete(NULL);
}
