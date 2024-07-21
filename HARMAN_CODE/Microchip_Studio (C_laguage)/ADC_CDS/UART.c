#include "UART.h"

void UART0_Init()	//uart 초기화
{
	//speed		9600bps
	UBRR0H = 0x00;
	UBRR0L =207;
	//비동기, 8비트, 패리티비트 없음
	UCSR0A |= (1<<U2X0);	//2배속모드
	UCSR0C |= (1<<UCSZ01) | (1<<UCSZ00);
	UCSR0B |= (1<<RXEN0); //수신가능
	UCSR0B |= (1<<TXEN0); //송신가능
}

void UART0_Transmit(char data)
{
	while(!(UCSR0A& (1<<UDRE0))); //udr이 비어잇는지
	//송신준비가 되면 r0a가 1이 될거, re0를 1주면==> &연산자로 1되고 !로 0 되어서 while문 빠져나와 char데이터를 아래 udr0=data에 넣어줄수 잇어?
	UDR0 =data;	
}

unsigned char UART0_Receive(void)
{
	while(!(UCSR0A&(1<<RXC0))); //수신대기에 문자가 잇으면 flag돼
	return UDR0;	//udr0는 아트메가 칩에 잇고,
	//뭔가 들어오면 보낼거고 받앗으면
}