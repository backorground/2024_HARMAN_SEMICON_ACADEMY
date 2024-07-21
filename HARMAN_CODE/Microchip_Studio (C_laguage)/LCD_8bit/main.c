//#define F_CPU 16000000UL
//#include <avr/io.h>
//#include <avr/delay.h>
#include <stdio.h>
#include "LCD.h"

int main(void)
{
    /*
	LCD_Init();
	LCD_GotoXY(0,0);
	LCD_WriteString("hello lcd");
	LCD_GotoXY(1,0);
	LCD_WriteString("hello avr");
	*/	
	char buff[30];
	LCD_Init();
	sprintf(buff, "hello avr");//"헬로"를 buff에 넣어
	LCD_WriteStringXY(0,0,buff);
	int count = 0;
	
	while (1) 
    {
		sprintf(buff, "count : %d", count++); 
			//"count를" buff에 넣는데 %d는 count++에 영향받아
		LCD_WriteStringXY(1,0,buff);
		_delay_ms(100);
    }
}

