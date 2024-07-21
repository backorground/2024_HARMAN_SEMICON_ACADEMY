/*
 * sonic.c
 *
 *  Created on: Jun 18, 2024
 *      Author: user
 */

#include "delay_us.h"
#include "sonic.h"

#define TRIG_PORT       GPIOA
#define TRIG_PIN        GPIO_PIN_8


// LEFT
uint32_t IC_Value1_l;      // input capture Rising Edge
uint32_t IC_Value2_l;     // input capture Falling Edge
uint32_t echoTime_l;
uint16_t captureFlag_l;
uint16_t distance_l;

// MIDDLE
uint32_t IC_Value1_m;      // input capture Rising Edge
uint32_t IC_Value2_m;     // input capture Falling Edge
uint32_t echoTime_m;
uint16_t captureFlag_m;
uint16_t distance_m;

// RIGHT
uint32_t IC_Value1_r;      // input capture Rising Edge
uint32_t IC_Value2_r;     // input capture Falling Edge
uint32_t echoTime_r;
uint16_t captureFlag_r;
uint16_t distance_r;


void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
  if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_1)
  {
    // Rising Edge
    if(captureFlag_l == 0)
    {
      IC_Value1_l = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);
      captureFlag_l = 1;
      __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_FALLING);
    }

    // Falling Edge
    else if(captureFlag_l == 1)
    {
      IC_Value2_l = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);
//      __HAL_TIM_SET_COUNTER(&htim2, 0);

      if(IC_Value2_l > IC_Value1_l)
      {
        echoTime_l = IC_Value2_l - IC_Value1_l;
      }
      else if(IC_Value1_l > IC_Value2_l)
      {
        echoTime_l = (0xffffffff - IC_Value1_l) + IC_Value2_l;
      }
      distance_l = echoTime_l / 58;
      captureFlag_l = 0;
      __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);
      __HAL_TIM_DISABLE_IT(&htim2, TIM_IT_CC1);
    }
  }

  if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_2)
  {
    // Rising Edge
    if(captureFlag_m == 0)
    {
      IC_Value1_m = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_2);
      captureFlag_m = 1;
      __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_2, TIM_INPUTCHANNELPOLARITY_FALLING);
    }

    // Falling Edge
    else if(captureFlag_m == 1)
    {
      IC_Value2_m = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_2);
//      __HAL_TIM_SET_COUNTER(&htim2, 0);

      if(IC_Value2_m > IC_Value1_m)
      {
        echoTime_m = IC_Value2_m - IC_Value1_m;
      }
      else if(IC_Value1_m > IC_Value2_m)
      {
        echoTime_m = (0xffffffff - IC_Value1_m) + IC_Value2_m;
      }
      distance_m = echoTime_m / 58;
      captureFlag_m = 0;
      __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_2, TIM_INPUTCHANNELPOLARITY_RISING);
      __HAL_TIM_DISABLE_IT(&htim2, TIM_IT_CC2);
    }
  }

  if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_3)
  {
    // Rising Edge
    if(captureFlag_r == 0)
    {
      IC_Value1_r = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3);
      captureFlag_r = 1;
      __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_FALLING);
    }
    // Falling Edge
    else if(captureFlag_r == 1)
    {
      IC_Value2_r = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3);
//      __HAL_TIM_SET_COUNTER(&htim2, 0);
     if(IC_Value2_r > IC_Value1_r)
      {
        echoTime_r = IC_Value2_r - IC_Value1_r;
      }
      else if(IC_Value1_r > IC_Value2_r)
      {
        echoTime_r = (0xffffffff - IC_Value1_r) + IC_Value2_r;
      }
      distance_r = echoTime_r / 58;
      captureFlag_r = 0;
      __HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_RISING);
      __HAL_TIM_DISABLE_IT(&htim2, TIM_IT_CC3);
    }
  }

}


void HC_SR04(void)
{
  // Trigger signal
  HAL_GPIO_WritePin(TRIG_PORT, TRIG_PIN, GPIO_PIN_SET);
  delay_us(10);
  HAL_GPIO_WritePin(TRIG_PORT, TRIG_PIN, GPIO_PIN_RESET);
  __HAL_TIM_SET_COUNTER(&htim2, 0);

  __HAL_TIM_ENABLE_IT(&htim2, TIM_IT_CC1);
  __HAL_TIM_ENABLE_IT(&htim2, TIM_IT_CC2);
  __HAL_TIM_ENABLE_IT(&htim2, TIM_IT_CC3);
}





