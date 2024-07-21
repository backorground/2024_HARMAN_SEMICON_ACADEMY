#define  F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include "UART.h"

//출력 스트림 설정 <stdio.h> 에 잇는 표준 입출력
FILE OUTPUT = FDEV_SETUP_STREAM(UART0_Transmit, NULL, _FDEV_SETUP_WRITE);

char rxBuff[100] {0};	//수신 버퍼 설정, 0으로 초기화
uint8_t rxFlag = 0;		//수신 완료 플래그 설정

ISR(USART0_RX_vect)		//uart 수신 인터럽트 핸들러
{
	static uint8_t rxHead = 0;	//수신된 데이터의 인덱스
	uint8_t rxData = UDR0;		//수신된 데이터
	
	if (rxData == '\n'||rxData == '\r')// '\n'개행, '\r'리턴, 이면
	{//abc치고 엔터를 입력하면 else로 가?
		rxBuff[rxHead] = '\0';	//수신된 문자열의 마지막에 NULL(0) 추가
		rxHead = 0;				//인덱스를 초기화 하고
		rxFlag = 1;				//문자열 수신 플래그를 set
	}
	else						// 그렇지 않으면 문자를 계속 받음
	{
		rxBuff [rxHead] = rxData;	//버퍼에 수신된 데이터 추가
		rxHead++;					//인덱스 증가 시킨다
	}
}

int main(void)
{
    UART0_Init();
	uint8_t rxData;		//데이터 수신
	stdout = &OUTPUT;	//출력스트림 지정
	
	sei();				//전역 인터럽트 활성화
	//cli();			//전역 인터럽트 비활성화
	
    while (1) 
    {
		if(rxFlag==1)		//문자열 수신이 완료된 경우
		{
			rxFlag=0;
			printf(rxBuff);	//수신된 문자열 출력
		}
    }
return 0;
}

