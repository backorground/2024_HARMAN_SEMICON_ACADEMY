/*
 * move.h
 *
 *  Created on: Jun 28, 2024
 *      Author: user
 */

#ifndef INC_MOVE_H_
#define INC_MOVE_H_

#include "stm32f4xx_hal.h"
#include "tim.h"
#include "sonic.h"


void forward();
void forward_slow();
void backward();
void stop();
void back_right();
void back_left();
void turn_right();
void turn_left();
void turn_right_oposite();
void turn_left_oposite();


#endif /* INC_MOVE_H_ */
