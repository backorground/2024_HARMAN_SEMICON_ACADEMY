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
	static uint8_t rxHead = 0; //수신된 데이터의 인덱스     //정적변수로선언
	uint8_t rxData = UDR0; //수신된 데이터
	
	if(rxData == '\n'||rxData == '\r') //'\n' 개행 , '\r'리턴  이면
	{
		rxBuff[rxHead] = rxData;
		rxHead++;
		rxBuff[rxHead] = '\0'; //수신된 문자열의 마지막에 NULL(0) 추가
		
		indexMotion = rxHead;
		
		rxHead = 0;            //인덱스를 초기화 하고
		rxFlag = 1;            //문자열 수신 플래그를 set
	}
	else //그렇지 않으면 계속 문자를 받음
	{
		rxBuff [rxHead] =rxData; //버퍼에 수신된 데이터 추가
		rxHead++;                //인덱스를 증가 시킨다
	}
}

int main(void)
{
	LED_DDR =0xff;
	
	UART0_Init();
	uint8_t rxData; //데이터 수신
	stdout = &OUTPUT; //출력스트림 지정	
	sei(); //전역 인터럽트 활성화      set interrupt
	
	uint16_t count = 0;
	uint8_t buff[30];		//i2c	
	LCD_Init();				//lcd출력설정
	
	while (1)
	{
		uint8_t *rxString = rxBuff;
		if (rxFlag)
		{
			rxFlag = 0;
			printf(rxBuff); // 수신된 문자열 출력
			LCD_WriteStringXY(1,0,rxBuff);		//i2c__1,0자리에 buff출력
			_delay_ms(200);
		}
	}
	return 0;
	
	
	
}



/*
int main(void)
{
	DDRD = 0XFF;
	PORTD = 0x00;
	char i, data;
	uint8_t ledData = 0x01;
	UART0_Init();			//uart기능 초기설정 안봐도 됨
	
	uint16_t count = 0;
	uint8_t buff[30];		//i2c
	
	LCD_Init();				//lcd출력설정
	
	while (1)
	{
		data = UART0_Receive();
		UART0_Transmit(data);		//uart
		
		LCD_WriteStringXY(1,0,buff);		//i2c
		_delay_ms(200);
	}
}
*/