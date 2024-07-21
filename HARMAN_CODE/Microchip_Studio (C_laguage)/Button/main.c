#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRA = 0xff;	//포트A를 출력 설정
	DDRD = DDRD && ~(1<<1);//	0000_0001	//입력을 받기우해 1번핀 설정
					//&~0000_0010
					//	1111_1101
					//ddrd na/na/na/na_na/na/0/na
    while (1) 
    {
							// pin1의 입력
		if (PIND & (1<<1))//풀업저항 형식으로 평소엔 pind는 1이 입력
							//버튼이 안눌리면
		{
			PORTA = 0x00; 
		}
		else
		{
			PORTA |=(1<<4) ;
		}
    }
}

