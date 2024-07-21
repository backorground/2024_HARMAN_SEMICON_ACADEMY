#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
    DDRB = (1<<PORTB5);	//0b0010000
	TCCR1A |= (1<<COM1A1)|(1<<WGM11);
	TCCR1B |= (1<<WGM13)|(1<<WGM12) |(1<<CS12)|(0<<CS11)|(0<<CS12);
    
		//duty비
	ICR1 = 1249; //top값
	
	while (1) 
    {
		OCR1A =30;//duty 비 
		_delay_ms(1000);
		OCR1A =150;
		_delay_ms(1000)	;	
	
		
    }
}
