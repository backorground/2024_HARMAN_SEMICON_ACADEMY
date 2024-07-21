//#include <avr/io.h>
#include "LCD_4bit.h"
#include <stdio.h>

int main(void)
{
   char buff[30];
   LCD_Init();
   sprintf(buff, "hello avry");//"헬로"를 buff에 넣어
   LCD_WriteStringXY(0,0,buff);
   int count = 0;
   
   while (1)
   {
	   sprintf(buff, "count : %d", count++); //"count를" buff에 넣는데 %d는 count++에 영향받아
	   LCD_WriteStringXY(1,0,buff);
	   _delay_ms(100);
   }
}
