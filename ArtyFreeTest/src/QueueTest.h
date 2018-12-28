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

// primary task functions
void SendTask(void *);
void ReceiveTask(void *);

#endif
