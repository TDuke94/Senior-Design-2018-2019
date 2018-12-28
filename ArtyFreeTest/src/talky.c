/*
 * talky.c
 *
 * Author: Timothy Duke
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * talkative tasks
 *
 * Primary goals
 * 		- initialize and destroy tasks
 * 		- use multiple tasks simultaneously
 */

#include "talky.h"
#include "xgpio.h"

/*
 * blabber
 *
 * inputs:
 * 		- void * parameters: this should be a single integer
 * 			and will be cast as (int) to tell the function
 * 			how many times to blab
 */

void blabber (void * parameters)
{
	// cast parameter value as integer for loop count
	int loop, i;

	if (parameters != NULL)
	{
		// should be null, just using parameters
		i = 0;
	}

	loop = 10;

	for (;;)
	{
		for (i = 1; i <= loop; i++)
		{
			xil_printf("Loop number: %i\n", &i);
		}

		for (i = 0; i < 10000; i++)
		{
			// wait
		}
	}
	// terminate task gracefully
	vTaskDelete (NULL);
}

/*
 * chatTX/chatRX
 *
 * currently not implemented, enter empty infinite loops
 */

void chatTX (void * parameters)
{
	int i;

	// for now, just use the parameter for nothing to shut the compiler up
	if (parameters == NULL)
	{
		i = 0;
	}

	for (;;)
	{
		xil_printf("I'm also printing\n");
	}

	vTaskDelete (NULL);
}

void chatRX (void * parameters)
{
	int i;

	// for now, just use the parameter for nothing to shut the compiler up
	if (parameters == NULL)
	{
		i = 0;
	}

	for (;;)
	{

	}

	vTaskDelete (NULL);
}

/*
 * blinky()
 *
 * an empty LED Blinking task
 *
 * should not use the input parameter - besides to shut compiler up
 *
 * maybe do GPIO INIT elsewhere?
 */

void blinky(void * parameters)
{
	int i, j;
	volatile int hold;
	XGpio LED_Gpio;
	int Status;

	// for now, just use the parameter for nothing to shut the compiler up
	if (parameters == NULL)
	{
		i = 0;
	}

	Status = XGpio_Initialize(&LED_Gpio, LED_ID);
	if (Status != XST_SUCCESS)
	{
		xil_printf("GPIO Init Error\n");
		return;
	}

	XGpio_SetDataDirection(&LED_Gpio, LED_CHANNEL, ~LED_OUT);

	j = 0;

	for (;;)
	{
		for (i = 0; i < LED_DELAY; i++)
		{
			hold = 0;
		}

		xil_printf ("LED\n");

		if (j == 0)
		{
			XGpio_DiscreteWrite(&LED_Gpio, LED_CHANNEL, LED_OUT);
			j++;
		}
		else
		{
			j = 0;
			XGpio_DiscreteClear(&LED_Gpio, LED_CHANNEL, LED_OUT);
		}
	}

	vTaskDelete (NULL);
}
