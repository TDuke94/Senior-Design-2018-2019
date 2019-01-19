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
 */

#ifndef DISPATCH_H
#define DISPATCH_H

/*
 * Primary Dispatcher
 *
 * inputs:
 * 		Pointer to character flags, used for debugging
 */
void dispatchPipeline (void);

void continualDispatcher (void *);

#endif
