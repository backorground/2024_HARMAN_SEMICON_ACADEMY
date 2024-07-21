#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRB = (1<<PORTB4); //0b00010000//0x10==>4번포트 활성화
	//TCCR0 = 0x6d;
	
	TCCR0 |= (1<<WGM00) | (1<<WGM01);	//Past PWM
	TCCR0 |= (1<<COM01) | (0<<COM00);	//비반전
	TCCR0 |= (1<<CS02) | (1<<CS01)| (0<<CS00);	//256분주
	OCR0 = 64;
	
   
    while (1) 
    {
		for(int i=0; i<= 255; i++)
		{
			OCR0 = i;
			_delay_ms(15);
		}
    }
}

