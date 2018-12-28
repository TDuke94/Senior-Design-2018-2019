/*
 * main.c
 *
 * Author: Timothy Duke
 *
 *  * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * main function for ArtySDSoCTest program
 */

/* Standard includes. */
#include <stdio.h>
#include <limits.h>

/* Scheduler include files. */
#include "FreeRTOS.h"
#include "task.h"
#include "semphr.h"

#include "xparameters.h"
#include "xscutimer.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xgpio.h"
#include "sleep.h"

/*user header files */
#include "dispatch.h"

/*-----------------------------------------------------------*/

int main( void )
{
	int i;

	dispatchPipeline();

	for (i = 0; i < 10; i++)
	{
		xil_printf("counting inside of main :)\n");
	}

	for(;;)
	{
		// Catch this so it doesn't run off the end
	}

	/* Don't expect to reach here. */
	return 0;
}
/*-----------------------------------------------------------*/
