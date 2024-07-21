#include "UART.h"

void UART0_Init()	// uart 초기화
{
	// speed	9600bps
	UBRR0H = 0x00;
	UBRR0L = 207;
	// 비동기, 8비트, 패리티없음, 1비트stop
	UCSR0A |= (1<<U2X0);	// 2배속 모드
	
	UCSR0B |= (1<<RXEN0);	//  수신 가능
	UCSR0B |= (1<<TXEN0);	// 송신 가능
	
	//UCSR0C |= (1<<UCSZ01) | (1<<UCSZ00); // =0x06;	
	
    UCSR0B |= (1 << RXCIE0); // Enable Receiver interrupt
}

void UART0_Transmit(char data)
{
	while(!(UCSR0A & (1<<UDRE0))); //UDR이 비어 있는지?
	UDR0 = data;	
}

unsigned char UART0_Receve()
{
	while(!(UCSR0A & (1<<RXC0))); // 수신대기
	return UDR0;		
}

void USART0_ISR_Process_byGT()
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