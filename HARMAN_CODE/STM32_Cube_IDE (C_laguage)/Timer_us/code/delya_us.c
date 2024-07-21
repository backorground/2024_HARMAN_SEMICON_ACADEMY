/*
 * delya_us.c
 *
 *  Created on: Jun 14, 2024
 *      Author: 82108
 */
#include "delay_us.h"

void delay_us(uint16_t us)
{
	__HAL_TIM_SET_COUNTER(&htim10, 0);//timer no.10's cnt value= 0
	while((__HAL_TIM_GET_COUNTER(&htim10)) < us);
}


