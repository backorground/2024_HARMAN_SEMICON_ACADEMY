#define    F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRA = 0xff;    // LED연결  출력

	//DDRC = 0x00;    // DDRC 레지스터 전체를 버튼 입력으로 설정    // 1번째

	//DDRC &= ~(1 << PINC0);    // 0번핀만 입력 설정           // 2번째 방법
	//DDRC &= ~(1 << PINC1);    // 1번핀만 입력 설정           // 2번째 방법
	//DDRC &= ~(1 << PINC2);    // 2번핀만 입력 설정           // 2번째 방법

	// DDRC 의 0,1,2 번 핀만... 입력 설정을 연산자를 이용함        // 3번째 통합 방법
	DDRC &= (~(1 << PINC0) | ~(1 << PINC1) | ~(1 << PINC2));
	//DDRC &= (~(1 << 0) | ~(1 << 1) | ~(1 << 2));       // 위에넘과 같은 것

	uint8_t ledData = 0x01;
	uint8_t buttonData;    // 버튼 입력을 받을 변수 설정
	int flag = 0;    // ATmega128에서 int형은 2byte임
	PORTA = 0x00;    // LED 꺼진 상태로 출발


	while (1)
	{
		buttonData = PINC;
		if ((buttonData & (1<<0)) == 0)
		{
			PORTA = ledData;
			ledData = (ledData >> 7) | (ledData << 1);
			_delay_ms(300);
		}
		if ((buttonData & (1<<1)) == 0)
		{
			PORTA = ledData;
			ledData = (ledData >> 1) | (ledData << 7);
			_delay_ms(300);
		}
		if (flag == 0)
		{
			if ((buttonData & (1<<2)) == 0) // 버튼이 눌렸다면.. 참
			{
				flag = 1;
			}
			else    // 그렇지 않다면
			{
				flag = 0;
			}
		}
		if (flag == 1)
		{
			for (uint8_t i = 0; i < 3; i++)
			{
				PORTA = 0xff;
				_delay_ms(500);
				PORTA = 0x00;
				_delay_ms(500);
			}
			flag = 0;
		}
	}
}
