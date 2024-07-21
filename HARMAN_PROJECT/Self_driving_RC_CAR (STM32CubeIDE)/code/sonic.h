/*
 * sonic.h
 *
 *  Created on: Jun 18, 2024
 *      Author: user
 */

#ifndef INC_SONIC_H_
#define INC_SONIC_H_

#include "stm32f4xx_hal.h"
#include "tim.h"


void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim);
void HC_SR04(void);


#endif /* INC_SONIC_H_ */
