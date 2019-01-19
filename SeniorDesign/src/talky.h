/*
 * talky.h
 *
 * Author: Timothy Duke
 *
 * UCF ECE Department
 * Developed as part of Senior Design with:
 * 		Daniel G.
 * 		Fred D.
 * 		Linnette M.
 *
 * Header file for a test talkative task set
 */

#ifndef TALKY_H
#define TALKY_H

#include "xgpio.h"
#include "xparameters.h"

/*
 * basic blabby function
 *
 * void * parameter cast as (int)
 */
void blabber(void *);

/*
 * pair of functions, chat RX/TX - they chat to each other
 *
 * input void * parameters should be single value, cast as (int) internally
 */
void chatTX(void *);
void chatRX(void *);

/*
 * blinky()
 *
 * basic LED blink function
 *
 * void * parameter cast as (int)
 *
 */

// constants for the LED
#define LED_OUT 0xFF
#define LED_DELAY 100000
#define LED_CHANNEL 1
#define LED_ID XPAR_GPIO_1_DEVICE_ID

void blinky(void *);

#endif
