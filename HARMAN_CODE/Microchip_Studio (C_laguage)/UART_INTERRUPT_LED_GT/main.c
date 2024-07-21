#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include "UART.h"

#define LED_DDR DDRA     //LED 제어를 위한 포트의 방향 레지스터
#define LED_PORT PORTA   //LED를 켜고 끄기위한 포트

//출력 스트림 설정 <stdio.h> 에 있는 표준 입출력
FILE OUTPUT = FDEV_SETUP_STREAM(UART0_Transmit,NULL,_FDEV_SETUP_WRITE);

char rxBuff[100] ; //수신 버퍼 설정 , 0으로 초기화
uint8_t rxFlag = 0; //수신 완료 플래그 설정

uint8_t indexMotion;

ISR(USART0_RX_vect) //UART 수신 인터럽트 핸들러 
{
	USART0_ISR_Process_byGT();
}

int main(void)
{
	LED_DDR =0xff;
	
	const char *str1 = "LED_ON\n";
	const char *str2 = "LED_OFF\n";
	const char *str3 = "LED_RIGHT\n";
	const char *str4 = "LED_LEFT\n";
	
    UART0_Init();
	uint8_t rxData; //데이터 수신
	stdout = &OUTPUT; //출력스트림 지정
	
	sei(); //전역 인터럽트 활성화      set interrupt
	//cli() //전역 인터럽트 비활성화   clear interrupt
	
   while (1)
   {
	   uint8_t *rxString = rxBuff;
	   if (rxFlag)
	   {
		   rxFlag = 0;
		   printf(rxBuff); // 수신된 문자열 출력
		   if (indexMotion != '\0') // 수신된 문자열의 길이가 0이 아닐 경우
		   {
			   if (strcmp(rxString, str1) == 0)
			   {
				   LED_PORT = 0xff;
			   }
			   else if (strcmp(rxString, str2) == 0)
			   {
				   LED_PORT = 0x00;
			   }
			   else if (strcmp(rxString, str3) == 0)
			   {
				   for (int i = 7; i >= 0; i--)
				   {
					   LED_PORT = (1 << i); // LED를 오른쪽으로 이동
					   _delay_ms(500);
				   }
			   }
			   else if (strcmp(rxString, str4) == 0)
			   {
				   for (uint8_t i = 0; i < 8; i++)
				   {
					   LED_PORT = (1 << i); // LED를 왼쪽으로 이동
					   _delay_ms(500);
				   }
			   }
		   }
	   }
   }
   return 0;
   }
