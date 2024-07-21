#define F_CPU 16000000UL
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include "UART.h"

int main(void)
{
	UART0_Init();
	
    while (1) 
    {
		//char data;
		//data= UART0_Receive();
		//_delay_ms(100);
		UART0_Transmit(UART0_Receive());
    }
}

