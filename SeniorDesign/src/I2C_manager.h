/*
 * I2C_manager.h
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
 * Header File for I2C receiver manager
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


#ifndef I2C_MANAGER
#define I2C_MANAGER

/*
 * Include Files
 */
#include "xiic.h"
#include "xscugic.h"
#include "xil_exception.h"

/*
 * Cast Xilinx Device ID's to internal use name
 */
#define IIC_DEVICE_ID		XPAR_IIC_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_SCUGIC_0_DEVICE_ID
#define IIC_INTR_ID			XPAR_FABRIC_IIC_0_VEC_ID

/*
 * Function Prototypes
 */
void I2C_Task(void *parameters);
int I2CInit(void);
int SlaveWriteData (u16 ByteCount);
int SlaveReadData (u8 *BufferPtr, u16 ByteCount);
static int SetupInterruptSystem (XIic * IicInstPtr);
static void StatusHandler (XIic *InstancePtr, int Event);
static void SendHandler (XIic *InstancePtr);
static void ReceiveHandler (XIic *InstancePtr);

#endif
