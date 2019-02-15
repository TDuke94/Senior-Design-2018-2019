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
#include "sleep.h"

/*user header files */
#include "dispatch.h"
#include "I2C_manager.h"

/*
 * vector table installation enabled at runtime
 *
 * declared in port_asm_vectors.s file
 */
extern void vPortInstallFreeRTOSVectorTable( void );

/*
 * Prototype for general hardware setup
 *
 * Note: place any top level hardware setup calls here
 */
static void prvSetupHardware (void);

/*
 * Tick Counter - just a placeholder
 */
volatile int tickCount;

/*
 * General Interrupt Controller
 *
 * Register All Interrupts Here
 */
extern XScuGic xInterruptController;

/*
 * Callback Function Prototypes
 */
void vApplicationMallocFailedHook (void);
void vApplicaitonIdleHook (void);
void vApplicationStackOverflowHook (TaskHandle_t pxTask, char *pcTaskName);
void vApplicationTickHook (void);

/*-----------------------------------------------------------*/

int main( void )
{
	int i;

	prvSetupHardware();

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

/*
 * prvSetupHardware
 *
 * Sets up hardware platform/interface
 */
static void prvSetupHardware (void)
{
	BaseType_t xStatus;
	XScuGic_Config * pxGICConfig;

	portDISABLE_INTERRUPTS();

	/* Obtain the configuration of the GIC. */
	pxGICConfig = XScuGic_LookupConfig( XPAR_SCUGIC_SINGLE_DEVICE_ID );

	/* Sanity check the FreeRTOSConfig.h settings are correct for the
	hardware. */
	configASSERT( pxGICConfig );
	configASSERT( pxGICConfig->CpuBaseAddress == ( configINTERRUPT_CONTROLLER_BASE_ADDRESS + configINTERRUPT_CONTROLLER_CPU_INTERFACE_OFFSET ) );
	configASSERT( pxGICConfig->DistBaseAddress == configINTERRUPT_CONTROLLER_BASE_ADDRESS );

	/* Install a default handler for each GIC interrupt. */
	xStatus = XScuGic_CfgInitialize( &xInterruptController, pxGICConfig, pxGICConfig->CpuBaseAddress );
	configASSERT( xStatus == XST_SUCCESS );
	( void ) xStatus; /* Remove compiler warning if configASSERT() is not defined. */

	/*
	 * GIC Setup is performed in Scheduler Launch
	 *
	 * portZynq7000.c includes vApplicationIRQHandler which calls GIC registered functions.
	 */

	I2CInit();

	vPortInstallFreeRTOSVectorTable();
}
/*-----------------------------------------------------------*/


void vApplicationMallocFailedHook( void )
{
	/* Called if a call to pvPortMalloc() fails because there is insufficient
	free memory available in the FreeRTOS heap.  pvPortMalloc() is called
	internally by FreeRTOS API functions that create tasks, queues, software
	timers, and semaphores.  The size of the FreeRTOS heap is set by the
	configTOTAL_HEAP_SIZE configuration constant in FreeRTOSConfig.h. */
	taskDISABLE_INTERRUPTS();
	for( ;; );
}
/*-----------------------------------------------------------*/

void vApplicationStackOverflowHook( TaskHandle_t pxTask, char *pcTaskName )
{
	( void ) pcTaskName;
	( void ) pxTask;

	/* Run time stack overflow checking is performed if
	configCHECK_FOR_STACK_OVERFLOW is defined to 1 or 2.  This hook
	function is called if a stack overflow is detected. */
	taskDISABLE_INTERRUPTS();
	for( ;; );
}
/*-----------------------------------------------------------*/

void vApplicationIdleHook( void )
{
volatile size_t xFreeHeapSpace, xMinimumEverFreeHeapSpace;

	/* This is just a trivial example of an idle hook.  It is called on each
	cycle of the idle task.  It must *NOT* attempt to block.  In this case the
	idle task just queries the amount of FreeRTOS heap that remains.  See the
	memory management section on the http://www.FreeRTOS.org web site for memory
	management options.  If there is a lot of heap memory free then the
	configTOTAL_HEAP_SIZE value in FreeRTOSConfig.h can be reduced to free up
	RAM. */
	xFreeHeapSpace = xPortGetFreeHeapSize();
	xMinimumEverFreeHeapSpace = xPortGetMinimumEverFreeHeapSize();

	/* Remove compiler warning about xFreeHeapSpace being set but never used. */
	( void ) xFreeHeapSpace;
	( void ) xMinimumEverFreeHeapSpace;
}
/*-----------------------------------------------------------*/

void vApplicationTickHook( void )
{
	tickCount++;
}
