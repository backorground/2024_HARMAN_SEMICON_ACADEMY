typedef unsigned char INT8;
typedef unsigned int INT16;

#define F_CPU 8000000
#define BAUD 9600
#define U2X_S 2
#define MYUBRR ((F_CPU*U2X_S)/(16L*BAUD)-1)

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "USART_ch0.h"

int main(void)
{
	//INT8 i=0x03;
	USART0_Init(MYUBRR);
	
	USART0_Transmit_NewLine();		//USART0_Transmit 단어 한글자 보내는 것
	USART0_Transmit('M'); USART0_Transmit('A');
	USART0_Transmit('S'); USART0_Transmit('T');
	USART0_Transmit('E'); USART0_Transmit('R');
	
	while(1)
	{
		USART0_Transmit_NewLine();
		USART0_Transmit('K'); //띄우고 싶은거 담아서 보내면 터미널에 뜬다
		_delay_ms(500);
	}
	
}