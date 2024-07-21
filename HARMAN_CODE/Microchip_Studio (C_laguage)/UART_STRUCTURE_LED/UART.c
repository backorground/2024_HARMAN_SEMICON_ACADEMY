/*
 * UART.c
 *
 * Created: 2024-04-08 오후 8:16:17
 *  Author: user
 */ 
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

