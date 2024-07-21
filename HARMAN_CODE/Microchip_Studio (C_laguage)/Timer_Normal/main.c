//CTC모드와 같은 의미 인데 
//출력을 OCn의 핀으로 출력하는 것이 아니라
//내가 지정할 수 있다

#define  F_CPU 16000000
#include <avr/io.h>

int main(void)
{
	DDRD = 0xff;
	PORTD = 0x00;	//low로 시작해서 top 만나면 토글
	
	//TCCR0 |= 0b00000101;
	/*
	  TCCR0 |= (1<<CS02);	//(1<<2)	TCCR0주소,
	  TCCR0 |= (1<<CS00);	//(1<<0)	CS00==1,CS02==0
	*/
	TCCR0 |= ((1<<CS02)|(1<<CS00));  
	
    while (1) 
    {
    }
}

