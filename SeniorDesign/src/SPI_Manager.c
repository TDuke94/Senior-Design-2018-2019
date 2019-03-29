/*
 * SPI_Manager.c
 *
 * Author: Timothy Duke
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * Header File for SPI Transmitter manager
 *
 * Version:
 * 		0.0 - March 1, 2019: Initial revision
 */

/*
 * This code substantively uses Adam Taylor SPI Example from Microzed Chronicles
 * Copyright statement drawn from that code below:
 */

/*Copyright (c) 2015, Adam Taylor
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project*/

#include "SPI_Manager.h"

#define SPI_DEVICE			XPAR_XSPIPS_0_DEVICE_ID
#define GPIO_DEVICE_ID_LED	XPAR_GPIO_0_DEVICE_ID
#define GPIO_DEVICE_ID_SS	XPAR_GPIO_1_DEVICE_ID

#define SEND_COUNT		IMU_COUNT * 18
#define RECEIVE_COUNT	10

#define CHANNEL 1
#define SLAVE_SELECT	0xff

/*
 * Helper Functions
 */

void convertFloatToByte (float F, u8 * byte);

void evaluate (float * q);
int firstFlag;

/*
 * Global Variables
 */
static XSpiPs 			SpiInstance;
static XGpio			Gpio_LED;
static XGpio			Gpio_SS;

u8 WriteBuffer[SEND_COUNT];
u8 ReadBuffer[RECEIVE_COUNT];

void SPI_Task (void * parameters)
{
	firstFlag = TRUE;

	int DelayFlag, i, j;

	u8 byteBuffer[4];

	/*
	 *
	 */
	float * InArray;

	QueueHandle_t inputQueue;

	QueueData myQueueData;

	if (parameters == NULL)
	{
		xil_printf("no parameters sent to QStartTask()\nabort\n");
		vTaskDelete(NULL);
	}

	myQueueData = *((QueueData *) parameters);

	inputQueue = myQueueData.inputQueue;

	vPortFree(parameters);

	DelayFlag = TRUE;

	for (;;)
	{
		// delay if flag is set
		if (DelayFlag == TRUE)
		{
			// clear flag
			DelayFlag = FALSE;
			// delay
			vTaskDelay (200);
		}

		// clear the array pointer
		InArray = NULL;

		/*
		 * Take from Buffer, including RX Condition Checking
		 */
		if (uxQueueMessagesWaiting(inputQueue) == 0)
		{
			// set delay flag to not waste processor time
			DelayFlag = TRUE;

			// re-enter loop
			continue;
		}

		xQueueReceive (inputQueue, &InArray, (TickType_t) 5);

		/*
		 * Setup Data for transfer
		 *
		 * per IMU, send 4 floats, but decompose as bytes
		 */
		for (i = 0; i < IMU_COUNT * 4; i++)
		{
			convertFloatToByte(InArray[i], byteBuffer);
			for (j = 0; j < 4; j++)
				WriteBuffer[i * 4 + j + 1] = byteBuffer[j];
		}

		WriteBuffer[0] = 'A';

		// TEST CODE
		//for (i = 1; i < SEND_COUNT; i++)
		//	WriteBuffer[i] = i + 'A';

		WriteBuffer[SEND_COUNT - 1] = 0;

		/*
		 * Perform SPI Write
		 */

		XGpio_DiscreteClear(&Gpio_SS, CHANNEL, SLAVE_SELECT);

		XSpiPs_SetSlaveSelect(&SpiInstance, 0x00);
		XSpiPs_PolledTransfer(&SpiInstance, WriteBuffer, NULL, SEND_COUNT + 4);
		XGpio_DiscreteWrite(&Gpio_SS, CHANNEL, SLAVE_SELECT);

		evaluate(InArray);

		vPortFree(InArray);
	}

	vTaskDelete(NULL);
}

void convertFloatToByte(float F, u8 * byte)
{
	int i;

	union {
		float F;
		u8 byte[4];
	} U;

	U.F = F;

	for (i = 0; i < 4; i++)
	{
		byte[i] = U.byte[i];
	}
}

float lastQ[4];

int counter;

void evaluate(float *q)
{
	normalizeQ(q);

	float localQ[4];
	float localLastQ[4];
	float refQ[4];
	float diffQ[4];
	float axis[3];

	float compare, angle;

	// catches NAN values
	if (q[0] != q[0])
		return;

	if (firstFlag == TRUE)
	{
		counter = 0;

		firstFlag = FALSE;
		lastQ[0] = q[0];
		lastQ[1] = q[1];
		lastQ[2] = q[2];
		lastQ[3] = q[3];
	}

	localQ[0] = q[0];
	localQ[1] = q[1];
	localQ[2] = q[2];
	localQ[3] = q[3];

	localLastQ[0] = lastQ[0];
	localLastQ[1] = lastQ[1];
	localLastQ[2] = lastQ[2];
	localLastQ[3] = lastQ[3];

	differenceQ(q, lastQ, diffQ);

	normalizeQ(diffQ);

	toAxisAngle(diffQ, axis, &angle);

	compare = angle;

	if (compare < 1.25f)
	{
		if (counter > 0)
			counter--;
	}
	else
		if (counter < 10)
			counter++;

	if (counter < 9)
		XGpio_DiscreteWrite(&Gpio_LED, CHANNEL, SLAVE_SELECT);
	else
		XGpio_DiscreteClear(&Gpio_LED, CHANNEL, SLAVE_SELECT);

}

int SPI_Init (void)
{
	int Status;

	XSpiPs_Config *SpiConfig;

	SpiConfig = XSpiPs_LookupConfig((u16)SPI_DEVICE);

	Status = XSpiPs_CfgInitialize(&SpiInstance, SpiConfig, SpiConfig->BaseAddress);
    if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	XSpiPs_SetOptions(&SpiInstance, XSPIPS_MASTER_OPTION |  XSPIPS_FORCE_SSELECT_OPTION);

	XSpiPs_SetClkPrescaler(&SpiInstance, XSPIPS_CLK_PRESCALE_256);

	/*
	 * Also, perform GPIO initialization, since that's how we're doing Slave Select
	 */

	Status = XGpio_Initialize(&Gpio_SS, GPIO_DEVICE_ID_SS);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XGpio_SetDataDirection(&Gpio_SS, CHANNEL, 0x00);

	Status = XGpio_Initialize(&Gpio_LED, GPIO_DEVICE_ID_LED);
	if (Status != XST_SUCCESS)
	{
		return XST_FAILURE;
	}

	XGpio_SetDataDirection (&Gpio_LED, CHANNEL, 0x00);

	return XST_SUCCESS;
}
