#define  F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include "I2C_LCD.h"
#include <stdio.h>

int main(void)
{
    uint16_t count = 0;
	uint8_t buff[30];
	
	LCD_Init();
	LCD_WriteStringXY(0,0,"hello");
	
	while (1) 
    {
		
		LCD_WriteStringXY(1,0,buff);
		_delay_ms(200);
    }
}

