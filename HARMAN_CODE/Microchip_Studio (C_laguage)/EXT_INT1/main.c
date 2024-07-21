#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>   // 인터럽트를 위한 헤더파일

ISR(INT4_vect)   // 외부 인터럽트가 들어와서 발생하면 INT4_vect을 쓸거임.
{
	PORTA = 0xff;
}
ISR(INT5_vect)
{
	PORTA = 0x00;
}

int main(void)
{
	//외부 인터럽트 INT4(PE4), INT5(PE5) 사용
	// EICRB의 ISC41, ISC40 | ISC43, ISC42임.
	// falling edge사용 --> 10
	
	// INT4 EICRa,b falling일 때 -> 10
	EICRB |= (1<<ISC41) | (0<<ISC40);
	// INT5 EICRb rising일 때 -> 11
	EICRB |= (1<<ISC51) | (1<<ISC50);
	EIMSK |= (1<<INT5) | (1<<INT4);
	
	DDRE &= (~(1<<DDRE4) | ~(1<<DDRE5));   // 버튼 0번핀, 1번핀
	DDRA = 0xff;   // LED출력
	sei();
	
	while (1)
	{
	}
}

