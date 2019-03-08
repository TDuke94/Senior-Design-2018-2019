/*
 * dispatch.h
 *
 * Author: Timothy Duke
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * Header file for the primary dispatcher of tasks
 *
 * Revision History:
 * 		- v0.0 - December 20, 2019 - Initial release of task dispatcher
 */

#ifndef DISPATCH_H
#define DISPATCH_H

#include "FreeRTOS.h"
#include "I2C_manager.h"
#include "SPI_Manager.h"
#include "IMU_Pipeline.h"

/*
 * Primary Dispatcher
 *
 * inputs:
 * 		Pointer to character flags, used for debugging
 */
void dispatchPipeline (void);

void continualDispatcher (void *);

#endif
