/*
 * QueueTest.h
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

#ifndef QUEUETEST_H
#define QUEUETEST_H

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "xgpio.h"

// Queue Data Set
typedef struct QueueData
{
	QueueHandle_t inputQueue;
	QueueHandle_t outputQueue;
	int queueLength;
	int blockSize;
} QueueData;

// primary task functions
void SendTask(void *);
void ReceiveTask(void *);

#endif
