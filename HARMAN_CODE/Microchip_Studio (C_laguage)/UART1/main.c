#include <avr/io.h>
#include "uart0.h"


FILE OUTPUT = FDEV_SETUP_STREAM(USART0_Transmit, NULL, _FDEV_SETUP_WRITE);


ISR(USART0_RX_vect)
{
	USART0_ISR_Process();
}

int main(void)
{
   UART0_init();
	stdout = &OUTPUT;
    while (1)
    {
		UART0_execute();
    }
}

