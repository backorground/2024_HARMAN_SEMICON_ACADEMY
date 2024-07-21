#define F_CPU 16000000UL
#include <util/delay.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include "UART_LED.h"

int main(void)
{
	DDRD = 0XFF;
	PORTD = 0x00;
	
	char i, data;
	uint8_t ledData = 0x01;	
	
	UART0_Init();
	
	while (1)
	{
		data = UART0_Receive();		
		UART0_Transmit(data);
			
		if(data =='a')	//a누르면 꺼짐
		{
			PORTD = 0xff;
			ledData = (ledData>>7)|(ledData<<1);						
		} 	
		else if ((data =='b'))	//b누르면 켜짐
		{
			PORTD = 0x00;
			ledData = (ledData>>7)|(ledData<<1);		
		}		
		else if ((data =='c'))	//다 켜진상태에서 하나씩 꺼짐
		{
			for(i=0; i<8; i++)
			{
				PORTD |= 1 <<i;
				_delay_ms(100);
				PORTD = 0x00;
			}			
		}		
		else 
		{
			PORTD = 0x00;			
		}
	}
}

