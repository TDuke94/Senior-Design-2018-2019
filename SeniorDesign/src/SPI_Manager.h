/*
 * SPI_Manager.h
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

#ifndef SPI_MANAGER_H
#define SPI_MANAGER_H

/*
 * FreeRTOS Includes used in SPI Manager
 */
#include "FreeRTOS.h"
#include "queue.h"
#include "task.h"

/*
 * Xilinx BSP includes for SPI Manager
 */
#include "xparameters.h"	/* SDK generated parameters */
#include "xspips.h"		    /* SPI device driver */
#include "xgpio.h"			/* GPIO device driver */

/*
 * Types defined for pipeline are in IMU_Pipeline
 */
#include "IMU_Pipeline.h"

void SPI_Task(void * parameters);
int SPI_Init(void);

#endif
