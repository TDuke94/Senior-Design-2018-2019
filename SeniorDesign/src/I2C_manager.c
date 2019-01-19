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
 * Version:
 * 		0.0 - January 19, 2019: Initial revision
 *
 * I2C receiver manager
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
#include "QueueTest.h"

/*
 * I2C Address - bit shifted to right 0xE0 -> 0x70
 */
#define SLAVE_ADDRESS		0x70

/*
 * length for RX/TX
 */
#define RECEIVE_COUNT	25
#define SEND_COUNT		25

/*
 * Global Variables
 */

XIic IicInstance;
XIntc InterruptController;

u8 WriteBuffer[SEND_COUNT];
u8 ReadBufer[RECEIVE_COUNT];

volatile u8 TransmitComplete;
volatile u8 ReceiveComplete;

volatile u8 SlaveRead;
volatile u8 SlaveWrite;

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
	int queueLength, blockSize, DelayFlag, Status, i;

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
	queueLength = myQueueData.queueLength;
	blockSize = myQueueData.blockSize;

	/*
	 * I2C Initialization and setup
	 */
	Status = I2CInit();
	if (Status != XST_SUCCESS)
	{
		xil_printf("I2C Initialization failed\nabort\n");
		vTaskDelete(NULL);
	}

	for(;;)
	{
		/*
		 * For now, simply call the I2C functions
		 */
		SlaveReadData(ReadBuffer, RECEIVE_COUNT);

		/*
		 * Put data into the Queue
		 */

		outputArray = pvPortMalloc(RECEIVE_COUNT * sizeof(u8));

		for (i = 0; i < RECEIVE_COUNT; i++)
			outputArray[i] = ReadBuffer[i];

		xQueueSend(outputQueue, (void *) &outputArray, (TickType_t) 0);

		/*
		 * reply over I2C
		 */
		for (i = 0; i < SEND_COUNT; i++)
			WriteBuffer[i] = i;

		SlaveWriteData(SEND_COUNT);
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

	ConfigPtr = XIic_LookupConfig(IIC_DEVICE_ID);
	if (ConfigPtr == NULL) return XST_FAILURE;

	Status = XIic_CfgInitialize (&IicInstance, ConfigPtr, ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	Status = SetupInterruptSystem (&IicInstance);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	XIic_SlaveInclude();

	XIic_SetStatusHandler (&IicInstance, &IicInstance, (XIic_StatusHandler) StatusHandler);
	XIic_SetSendHandler (&IicInstance, &IicInstance, (XIic_StatusHandler) SendHandler);
	XIic_SetRecvHandler (&IicInstance, &IicInstance, (XIic_StatusHandler) ReceiveHandler);

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
	while ((ReceiveComplete) || (XIic_IsIicBusy(&IicInstance) == TRUE)) {
		if (SlaveRead) {
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
	while ((TransmitComplete) || (XIic_IsIicBusy(&IicInstance) == TRUE)) {
		if (SlaveWrite) {
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
/**
* This function setups the interrupt system so interrupts can occur for the
* IIC. The function is application-specific since the actual system may or
* may not have an interrupt controller. The IIC device could be directly
* connected to a processor without an interrupt controller. The user should
* modify this function to fit the application.
*
* @param	IicInstPtr contains a pointer to the instance of the IIC  which
*		is going to be connected to the interrupt controller.
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
****************************************************************************/
static int SetupInterruptSystem(XIic * IicInstPtr)
{
	int Status;

	if (InterruptController.IsStarted == XIL_COMPONENT_IS_STARTED) return XST_SUCCESS;

	/*
	 * Initialize the interrupt controller driver so that it's ready to use.
	 */
	Status = XIntc_Initialize(&InterruptController, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above
	 * performs the specific interrupt processing for the device.
	 */
	Status = XIntc_Connect (&InterruptController, IIC_INTR_ID, (XInterruptHandler) XIic_InterruptHandler, IicInstPtr);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	/*
	 * Start the interrupt controller so interrupts are enabled for all
	 * devices that cause interrupts.
	 */
	Status = XIntc_Start(&InterruptController, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) return XST_FAILURE;

	/*
	 * Enable the interrupts for the IIC device.
	 */
	XIntc_Enable(&InterruptController, IIC_INTR_ID);

	/*
	 * Initialize the exception table.
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XIntc_InterruptHandler, &InterruptController);

	/*
	 * Enable non-critical exceptions.
	 */
	Xil_ExceptionEnable();


	return XST_SUCCESS;
}

