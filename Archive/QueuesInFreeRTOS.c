 ///////////////////////////////////////////////////////////////////////////////
 // Authored by: Daniel Gutierrez
 //
 // FileName: QueuesInFreeRTOS.c
 // Project: QueueBufferImplementation
 // Description:Passing data between tasks using a queue buffer 
 //
 //
 // File Made: 12/21/2018
 //                 
 //
 ///////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include "FreeRTOS.h"
#include "task.h" 
#include "queue.h"

TaskHandle_t myTask1Handle = NULL;
TaskHandle_t myTask2Handle = NULL;

QueueHandle_t myQueue;

// first parameter will be the size of the queue
// second parameter will be the size of the each of the blocks
void myTask1(void *p)
{

	char myTxBuff[30];

	myQueue = xQueueCreate( 5 , sizeof(TxBuff) );

	sprintf(myTxBuff, "message 1")
	xQueueSend(myQueue, (void*) myTxBuff, (TickType_t) 0);

	sprintf(myTxBuff, "message 2")
	xQueueSend(myQueue, (void*) myTxBuff, (TickType_t) 0);
	
	sprintf(myTxBuff, "message 3")
	xQueueSend(myQueue, (void*) myTxBuff, (TickType_t) 0);

	//xQueueSendToFront will reverse the order!!//
	
	// this will reset the buffer data entirely //
	//xQueueReset(myQueue);
	
	printf("data waiting to be read: %d\r\n ", uxQueueMessageWaiting( myQueue));
	printf("available spaces: %d\r\n", uxQueueSpacesAvailable(myQueue));
	
	while(1)
	{}

}


// this second task is being created to read the dat that is being passed in from task1 
void myTask2(void *p)
{
	char myRxBuff[30];
	
	
	while(1)
	{
		vTaskDelay(200);
		
		if(myQueue != 0)
		{
			// reads and removes the data 
			//xQueuePeek will not remove and the first message will be repeatedly sent instead
			if(xQueueReceive( myQueue, (void*) myRxBuff,(TickType_t) 5 ))
			{
				printf("data received: %s\r\n", myRxBuff);
			}
		}
		
	}
	
}

int main()
{

xTaskCreate(myTask1, "task1", 200, (void*) 0, tskIDLE_PRIORITY,&myTask1Handle)

xTaskCreate(myTask2, "task2", 200, (void*) 0, tskIDLE_PRIORITY,&myTask2Handle)

vTaskStartSchduler();
}


