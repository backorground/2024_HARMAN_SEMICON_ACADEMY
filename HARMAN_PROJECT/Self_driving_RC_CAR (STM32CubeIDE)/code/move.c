/*
 * move.c
 *
 *  Created on: Jun 28, 2024
 *      Author: user
 */

#include "move.h"

void forward()
{
  TIM3->CCR1 = 900;
  TIM3->CCR2 = 900;

  // left wheel
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_SET);
  // right wheel
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_SET);
}

void forward_slow()
{
  TIM3->CCR1 = 500;
  TIM3->CCR2 = 500;

  // left wheel
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_SET);
  // right wheel
  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_SET);
}

void backward()
{
  TIM3->CCR1 = 300;
  TIM3->CCR2 = 300;

  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_RESET);

  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_RESET);
}

void stop()
{
  TIM3->CCR1 = 0;
  TIM3->CCR2 = 0;
}

void turn_right()
{
  TIM3->CCR1 = 0;
  TIM3->CCR2 = 700;

  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_RESET);

  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_SET);
}

void turn_left()
{
  TIM3->CCR1 = 700;
  TIM3->CCR2 = 0;

  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_SET);

  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_RESET);
}


void turn_right_oposite()
{
  TIM3->CCR1 = 200;
  TIM3->CCR2 = 500;

  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_RESET);

  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_SET);
}

void turn_left_oposite()
{
  TIM3->CCR1 = 500;
  TIM3->CCR2 = 200;

  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_RESET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_SET);

  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_RESET);
}


void back_right()
{
  TIM3->CCR1 = 700;
  TIM3->CCR2 = 0;

  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_RESET);

  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_RESET);
}

void back_left()
{
  TIM3->CCR1 = 0;
  TIM3->CCR2 = 700;

  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6,GPIO_PIN_RESET);

  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7,GPIO_PIN_SET);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_9,GPIO_PIN_RESET);
}
