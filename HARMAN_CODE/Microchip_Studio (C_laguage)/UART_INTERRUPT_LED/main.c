#include <avr/io.h>
#include "uart0.h"
#include <string.h>


FILE OUTPUT = FDEV_SETUP_STREAM(USART0_Transmit, NULL, _FDEV_SETUP_WRITE);


ISR(USART0_RX_vect)
{
	USART0_ISR_Process();
}

int main(void)
{
	DDRD =0xff;
	PORTD = 0x00;
	
	char i, data;
	uint8_t ledData = 0x01;
	
	UART0_init();
	stdout = &OUTPUT;
	
	int strcmp()
	
	while (1)
	{	
		data = UART0_Receive()
		UART0_Transmit(data);
		UART0_execute();
		uint8_t *data = UART0_readRxBuff();
		
		if (*data[0] == 'L')
		{
			PORTD = 0xff;
			ledData = (ledData>>7)|(ledData<<1);
		}
		else if (*data ='E')
		{
			PORTD = 0x00;
			ledData = (ledData>>7)|(ledData<<1);
		}
		else
		{
			PORTD = 0x00;
		}
		
	}
}

