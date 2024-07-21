/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "cmsis_os.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

#include <stdio.h>
#include "delay_us.h"
#include "sonic.h"
#include "move.h"

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

#define Sol	255
#define Ra	227

#define qNote 150
#define wNote 1800

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

// for print function uses - uart
int _write(int file, unsigned char* p, int len)
{
    HAL_StatusTypeDef status = HAL_UART_Transmit(&huart2, p, len, 100);
    return (status == HAL_OK ? len : 0);
}

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

extern uint16_t distance_l;
extern uint16_t distance_m;
extern uint16_t distance_r;

uint8_t rxData[2];


/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
void MX_FREERTOS_Init(void);
/* USER CODE BEGIN PFP */

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) //interrupt occur, come into this function
{
  if(huart->Instance == USART2)
      {
        HAL_UART_Transmit_IT(&huart6, rxData, sizeof(rxData)); //disable

        HAL_UART_Receive_IT(&huart2, rxData, sizeof(rxData)); //enable
      }

    if(huart->Instance == USART6)
    {
      HAL_UART_Transmit_IT(&huart2, rxData, sizeof(rxData)); //disable

      HAL_UART_Receive_IT(&huart6, rxData, sizeof(rxData)); //enable
    }
}
void Buzzer()
{
	uint16_t song[] = {Ra, Ra};
	uint16_t time[] = {wNote, wNote};

	for(int i = 0; i < sizeof(song) / sizeof(song[0]); i++)
	{
		TIM4->PSC = song[i];
		TIM4->CCR2 = 500;
	    HAL_Delay(time[i]);
	    TIM4->CCR2 = 0;
	    HAL_Delay(5);
	}
}
void StopBuzzer()
{
	TIM4->CCR2 = 0;
}
void Auto_driving()
{
	//HC_SR04();

//    if(distance_l >= 100) distance_l = 100;
//    if(distance_m >= 100) distance_m = 100;
//    if(distance_r >= 100) distance_r = 100;

		  if(distance_m <= 10) // down
		  {
			  backward();
		  }
		  else // up
		  {
			 if(distance_m <= 36)
			 {
				 if(distance_l >= distance_r + 15)
				 {
					 turn_left_oposite();
				 }
				 else if(distance_l + 15 < distance_r)
				 {
					 turn_right_oposite();
				 }
			  }
			  else //30 ^
			  {
				  forward();

				  if(distance_l > distance_r + 25)
				  {
					  turn_left();
				  }
				  else if (distance_r > distance_l + 25)
				  {
					  turn_right();
				  }
			  }
		  }
}
void Controler()
{
	HAL_UART_Receive_IT(&huart6, rxData, sizeof(rxData));

		if(rxData[0] == 'O')
		{
			Auto_driving();
		}

		else if(rxData[0] == 'F')
		{
			forward();
		}
		else if(rxData[0] == 'B')
		{
			backward();
		}
		else if(rxData[0] == 'L')
		{
			turn_left();
		}
		else if(rxData[0] == 'R')
		{
			turn_right();
		}
		else if(rxData[0] == 'S')
		{
			stop();
		}
}
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

//  uint8_t dutyValue = 0;

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_USART2_UART_Init();
  MX_USART6_UART_Init();
  MX_TIM11_Init();
  MX_TIM2_Init();
  MX_TIM3_Init();
  MX_TIM4_Init();
  /* USER CODE BEGIN 2 */

  // TIM11 - delay function
  HAL_TIM_Base_Start(&htim11);

  // TIM2 - input capture
  HAL_TIM_Base_Start(&htim2);
  HAL_TIM_IC_Start(&htim2, TIM_CHANNEL_1);
  HAL_TIM_IC_Start(&htim2, TIM_CHANNEL_2);
  HAL_TIM_IC_Start(&htim2, TIM_CHANNEL_3);

  // TIM3 - PWM
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_2);

  HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_2);

  // Data In ? INTERRUPT occurs
  HAL_UART_Receive_IT(&huart2, rxData, sizeof(rxData));
  HAL_UART_Receive_IT(&huart6, rxData, sizeof(rxData));

  /* USER CODE END 2 */

  /* Init scheduler */
  osKernelInitialize();

  /* Call init function for freertos objects (in cmsis_os2.c) */
  MX_FREERTOS_Init();

  /* Start scheduler */
  osKernelStart();

  /* We should never get here as control is now taken by the scheduler */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */



//    if(distance_m <= 30)
//    {
//      if(distance_l > distance_r)
//      {
//        turn_left();
//      }
//      else if(distance_l == distance_r)
//      {
//        forward();
//      }
//      else if(distance_l < distance_r)
//      {
//        turn_right();
//      }
//    }
//    else
//    {
//      forward();
//    }
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 100;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
