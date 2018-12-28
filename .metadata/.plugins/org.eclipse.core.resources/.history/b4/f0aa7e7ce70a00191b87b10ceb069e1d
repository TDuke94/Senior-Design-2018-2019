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
#include "task.h"
#include "talky.h"
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
	void * parameters;
	int QueueLength = 5;
	int BlockSize = 30;

	QueueHandle_t myQueue = NULL;

	BaseType_t xReturned;

	TaskHandle_t xBlabHandle = NULL;
	TaskHandle_t xChatTXHandle = NULL;
	TaskHandle_t xBlinkHandle = NULL;
	TaskHandle_t xQSendHandle = NULL;
	TaskHandle_t xQReceiveHandle = NULL;

	xil_printf("I'm in dispatch\n");

	xReturned = xTaskCreate(
			blabber,
			"Blab",
			STACK_SIZE,
			NULL,
			tskIDLE_PRIORITY + 1,
			&xBlabHandle
			);

	if (xReturned != pdPASS) printError();

	xReturned = xTaskCreate(
			chatTX,
			"ChatTX",
			STACK_SIZE,
			NULL,
			tskIDLE_PRIORITY + 1,
			&xChatTXHandle
			);

	if (xReturned != pdPASS) printError();

	xReturned = xTaskCreate(
				blinky,
				"Blink",
				STACK_SIZE,
				NULL,
				tskIDLE_PRIORITY + 1,
				&xBlinkHandle
				);

	if (xReturned != pdPASS) printError();

	xReturned = xTaskCreate(
				SendTask,
				"QSend",
				STACK_SIZE,
				NULL,
				tskIDLE_PRIORITY + 1,
				&xQSendHandle
				);

	if (xReturned != pdPASS) printError();

	/*
	 * The next Two Tasks require parameters, including an initialized Queue
	 *
	 * parameters are as follows:
	 * 		- parameters[0] -> QueueHandle_t
	 * 		- parameters[1] -> int QueueLength
	 * 		- parameters[2] -> int BlockSize
	 */

	parameters;

	xReturned = xTaskCreate(
					ReceiveTask,
					"QReceive",
					STACK_SIZE,
					parameters,
					tskIDLE_PRIORITY + 1,
					&xQReceiveHandle
					);

	if (xReturned != pdPASS) printError();

	xReturned = xTaskCreate(
						SendTask,
						"QSend",
						STACK_SIZE,
						parameters,
						tskIDLE_PRIORITY + 1,
						&xQSendHandle
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

