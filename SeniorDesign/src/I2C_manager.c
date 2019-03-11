/*
 * I2C_manager.c
 *
 * Author: Timothy Duke
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * I2C receiver manager
 *
 * Revision History:
 * 		0.0 - January 19, 2019: Initial revision
 * 		1.0 - February 15, 2019: Functional revision - writeback faults remain
 */

/*
 * This code substantively uses Xilinx I2C Driver Example
 * Copyright statement drawn from that code below:
 */

/******************************************************************************
*
* Copyright (C) 2006 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

// Include Files - managed within I2C manager.h
#include "I2C_manager.h"
#include "IMU_Pipeline.h"
#include "MathLibrary.h"

/*
 * The following constant defines the address of the IIC device on the IIC bus.
 * Since the address is only 7 bits, this constant is the address divided by 2.
 */
#define SLAVE_ADDRESS		0x70	/* 0xE0 as an 8 bit number. */

#define RECEIVE_COUNT	18
#define SEND_COUNT		5
#define TIME_COUNT		8

/*
 * Local Function Prototypes
 */
static void StatusHandler (XIic *InstancePtr, int Event);
static void SendHandler (XIic *InstancePtr);
static void ReceiveHandler (XIic *InstancePtr);
static int SetupInterruptSystem (XIic * IicInstPtr);
int SlaveWriteData (u16 ByteCount);
int SlaveReadData (u8 *BufferPtr, u16 ByteCount);

/*
 * Global Variables
 */

XIic IicInstance;
extern XScuGic xInterruptController;

u8 WriteBuffer[SEND_COUNT];
u8 ReadBuffer[RECEIVE_COUNT];

volatile u8 TransmitComplete;
volatile u8 ReceiveComplete;

volatile u8 SlaveRead;
volatile u8 SlaveWrite;

/*
 * Full Scale Range - input from the IMUs - used externally in IMU_Pipeline
 */
/*
 * Full Scale Range, input from IMU Data
 */
short accel_fsr;
short gyro_fsr;
short mag_fsr;

/*
 * I2C_Task
 *
 * FreeRTOS task function which manages I2C
 *
 * Calls internal I2C Setup Functions
 *
 * Input:
 * 		- void* parameters, QueueData (struct) - includes where to put data
 */
void I2C_Task(void *parameters)
{
	/*
	 * Queue as output location
	 */
	int i;

	u8 *outputArray;

	QueueHandle_t outputQueue;

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QStartTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	outputQueue = myQueueData.outputQueue;

	vPortFree(parameters);

	for(;;)
	{
		/*
		 * Verify Clear
		 */
		for (i = 0; i < RECEIVE_COUNT; i++)
			ReadBuffer[i] = 0;

		/*
		 * Get Data over I2C
		 */
		SlaveReadData(ReadBuffer, RECEIVE_COUNT);

		/*
		 * Put data into the Queue
		 */
		outputArray = pvPortMalloc(RECEIVE_COUNT * sizeof(u8));

		for (i = 0; i < RECEIVE_COUNT; i++)
			outputArray[i] = ReadBuffer[i];

		/*
		 * enqueue, if failed, free the pointer so no leak occurs
		 */
		if (xQueueSend(outputQueue, &outputArray, (TickType_t) 0) != pdPASS)
			vPortFree(outputArray);

		/*
		 * reply over I2C
		 */
		for (i = 0; i < SEND_COUNT; i++)
			WriteBuffer[i] = i;

		/*
		 * Reply - not currently working
		 */
		//SlaveWriteData(SEND_COUNT);

		/*
		 * Failure Moding - de-latch any fail states, recovery
		 *
		 * For now, this is empty
		 */
		if (FALSE)
		{
			// Nothing for now
		}
	}

	// never fall off the end
	vTaskDelete(NULL);
}

/*
 * I2C Initialization
 *
 * Initialize the I2C driver as a slave
 *
 * Return XST_SUCCESS if success, otherwise, XST FAILURE
 *
 * This code is substantively drawn from Xilinx I2C Driver example code
 */
int I2CInit(void)
{
	int Status;
	XIic_Config *ConfigPtr;

	/*
	 * General I2C Setup
	 */

	// Slave Required
	XIic_SlaveInclude();

	ConfigPtr = XIic_LookupConfig(IIC_DEVICE_ID);
	if (ConfigPtr == NULL) return XST_FAILURE;

	Status = XIic_CfgInitialize (&IicInstance, ConfigPtr, ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	Status = SetupInterruptSystem (&IicInstance);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	XIic_SetStatusHandler (&IicInstance, (void *) &IicInstance, (XIic_StatusHandler) StatusHandler);
	XIic_SetSendHandler (&IicInstance, (void *) &IicInstance, (XIic_StatusHandler) SendHandler);
	XIic_SetRecvHandler (&IicInstance, (void *) &IicInstance, (XIic_StatusHandler) ReceiveHandler);

	Status = XIic_SetAddress(&IicInstance, XII_ADDR_TO_RESPOND_TYPE, SLAVE_ADDRESS);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
* This function reads a buffer of bytes  when the IIC Master on the bus writes
* data to the slave device.
*
* @param	BufferPtr contains the address of the data buffer to be filled.
* @param	ByteCount contains the number of bytes in the buffer to be read.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None
*
******************************************************************************/
int SlaveReadData(u8 *BufferPtr, u16 ByteCount)
{
	int Status;

	/*
	 * Set the defaults.
	 */
	ReceiveComplete = 1;

	/*
	 * Start the IIC device.
	 */
	Status = XIic_Start(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Set the Global Interrupt Enable.
	 */
	XIic_IntrGlobalEnable(IicInstance.BaseAddress);

	/*
	 * Wait for AAS interrupt and completion of data reception.
	 */
	while ((ReceiveComplete) /*|| (XIic_IsIicBusy(&IicInstance) == TRUE) */) {
		Status = XIic_IsIicBusy(&IicInstance);
		if (SlaveRead)
		{
			XIic_SlaveRecv(&IicInstance, ReadBuffer, RECEIVE_COUNT);
			SlaveRead = 0;
		}
	}


	/*
	 * Disable the Global Interrupt Enable.
	 */
	XIic_IntrGlobalDisable(IicInstance.BaseAddress);

	/*
	 * Stop the IIC device.
	 */
	Status = XIic_Stop(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
* This function writes a buffer of bytes to the IIC bus when the IIC master
* initiates a read operation.
*
* @param	ByteCount contains the number of bytes in the buffer to be
*		written.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
int SlaveWriteData(u16 ByteCount)
{
	int Status;

	/*
	 * Set the defaults.
	 */
	TransmitComplete = 1;

	/*
	 * Start the IIC device.
	 */
	Status = XIic_Start(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Set the Global Interrupt Enable.
	 */
	XIic_IntrGlobalEnable(IicInstance.BaseAddress);

	/*
	 * Wait for AAS interrupt and transmission to complete.
	 */
 	while ((TransmitComplete) /* || (XIic_IsIicBusy(&IicInstance) == TRUE) */ ) {
		if (SlaveWrite)
		{
			XIic_SlaveSend(&IicInstance, WriteBuffer, SEND_COUNT);
			SlaveWrite = 0;
		}
	}


	/*
	 * Disable the Global Interrupt Enable bit.
	 */
	XIic_IntrGlobalDisable(IicInstance.BaseAddress);

	/*
	 * Stop the IIC device.
	 */
	Status = XIic_Stop(&IicInstance);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/****************************************************************************/
/**
* This Status handler is called asynchronously from an interrupt context and
* indicates the events that have occurred.
*
* @param	InstancePtr is not used, but contains a pointer to the IIC
* 		device driver instance which the handler is being called for.
* @param	Event indicates whether it is a request for a write or read.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
static void StatusHandler(XIic *InstancePtr, int Event)
{
	//Check whether the Event is to write or read the data from the slave.
	if (Event == XII_MASTER_WRITE_EVENT)
	{
		// Its a Write request from Master.
		SlaveRead = 1;
	}
	else
	{
		// Its a Read request from the master./
		SlaveWrite = 1;
	}
}

/****************************************************************************/
/**
* This Send handler is called asynchronously from an interrupt
* context and indicates that data in the specified buffer has been sent.
*
* @param	InstancePtr is a pointer to the IIC driver instance for which
*		the handler is being called for.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
static void SendHandler(XIic *InstancePtr)
{
	TransmitComplete = 0;
}

/****************************************************************************/
/**
* This Receive handler is called asynchronously from an interrupt
* context and indicates that data in the specified buffer has been Received.
*
* @param	InstancePtr is a pointer to the IIC driver instance for which
* 		the handler is being called for.
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
static void ReceiveHandler(XIic *InstancePtr)
{
	ReceiveComplete = 0;
}

/****************************************************************************/
static int SetupInterruptSystem(XIic * IicInstPtr)
{
	// maybe do this more carefully
	XScuGic_SetPriorityTriggerType(&xInterruptController, IIC_INTR_ID, 0xA0, 0x3);

	XScuGic_Connect(&xInterruptController, IIC_INTR_ID , (Xil_ExceptionHandler) XIic_InterruptHandler, IicInstPtr);

	XScuGic_Enable(&xInterruptController, IIC_INTR_ID);

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, &xInterruptController);

	/*
	 * Enable non-critical exceptions.
	 */
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

