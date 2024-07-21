#include "uart0.h"
uint8_t uart0RxBuff [100];
uint8_t uart0RxCFlag;

void UART0_init()
{	
	UCSR0B |= (1 << RXEN0) | (1 << TXEN0); // Enable Rx and Rx
	UCSR0A |= (1 << U2X0); // Double the speed of internal clock
	UBRR0L = 207; // 16: 115200bps, 207: 9600 bps
	UCSR0B |= (1 << RXCIE0); // Enable Receiver interrupt
	sei();				
}

uint8_t UART0_getRxFlag()
{
	return uart0RxCFlag;
}

void UART0_clearRxFlag()
{
	uart0RxCFlag = 0;
}

void UART0_setReadyRxFlag()
{
	uart0RxCFlag = 1;
}

uint8_t *UART0_readRxBuff() //맨 아래 호출
{
	return uart0RxBuff;
}

void USART0_Transmit( unsigned char data )
{	 	
	while ( !( UCSR0A & (1 << UDRE0)));	
	UDR0 = data;
}

unsigned char USART0_Receive( void )
{	 
	while ( !(UCSR0A & (1 << RXC0)));
	return UDR0;
}

void UART0_print(char *str)	
{
	for (int i = 0; str[i]; i++)
	{
		USART0_Transmit(str[i]);
	}
	USART0_Transmit('\n');
}

uint8_t UART0_Avail()//RX데이터 들어올때까지 기달리는 함수
{
	// If there is RxData, return 0. Otherwise, return 1.
	if ( !(UCSR0A & (1 << RXC0)) )
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

void USART0_ISR_Process()
{
	uint8_t rx0Data = UDR0;
	static uint8_t uart0RxTail = 0;		
	// Insert null (\0) at the end of corresponding string and initialize a tail to 0 when \n detected
	if (rx0Data == '\n')		//입력된게 엔터면 //만약 A가 들어온다면 ELSE 실행
	{
		uart0RxBuff[uart0RxTail] = rx0Data;		//배열의 0번 인덱스에다가 RX0DATA집어 넣어
		uart0RxTail++;								//인덱스 1증가 시키고
		uart0RxBuff[uart0RxTail] = '\0';	//배열에서 문자열의 끝을 알림	//그 다음인덱스를 0으로 초기화
		uart0RxTail = 0;
		UART0_setReadyRxFlag();		//플래그 1이면 문자열이 있다
	}
	else
	{
		uart0RxBuff[uart0RxTail] = rx0Data;
		uart0RxTail++;
	}
}

void UART0_execute()
{	   
	if (UART0_getRxFlag())
	{
		UART0_clearRxFlag();	//문자열잇다는 플래그 클리어해서 문자열 지워 CLEAR=0으로
		uint8_t *rxString = UART0_readRxBuff();	//포인터 변수(uint8_t *rxString)						
		printf(rxString);
	}
	_delay_ms(300);
}