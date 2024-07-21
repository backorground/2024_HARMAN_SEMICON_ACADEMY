#include <stdint.h>


void delay_count(unsigned int timeCount)
{
	for( ;timeCount >0; timeCount--);
}

int main()
{
	//volatile unsigned int *ptr;
	//ptr = 0x40023830;
	//*ptr |= 0x01;

	//setting gpio's clk
	(*(volatile unsigned *)0x40023830) |= 0x01;
	//setting gpio's mode = output
	(*(volatile unsigned *)0x40020000) &= ~(0x3<<10);
	(*(volatile unsigned *)0x40020000) |= (0x1<<10);


	while(1)
	{
		//gpio 5 ON
		(*(volatile unsigned *)0x40020014) |= (1<<5);
		//delay
		delay_count(0xffff);
		//fof
		(*(volatile unsigned *)0x40020014) &= ~(1<<5);
		delay_count(0xffff);
	}
}

