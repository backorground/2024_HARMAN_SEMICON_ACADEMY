#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRB = 0x10;   // 0b0001000 (OC0)PB4 출력 설정
	TCCR0 = 0x1d;   // 0b00011101 data regiseter값
	OCR0 = 249;      // 비교값
	while (1)
	{
		while((TIFR & 0x02) == 0);   // 0인지 아닌지 체크
		TIFR = 0x02;            // 다음 비교일치를 위해 해당비트를 클리어 OCF0핀
		OCR0 = 249;               // 새로 다시 시작하는거니까 재 셋팅
	}
}
//임의의 주파수 khz만들엇음
//주파수 출력은 pbo 
//내부레지스터와 연결된 ocr0이랑 같이 연결되었기 때문에
//계단식 그림(TCNTn) max가 8비트라 최대 255임.., ocr0을 124로 주어져서 계단식 그림(TCNTn)에서 한 지점을 정해줬고
// 그 지점에 도달하면 OCn이 토글됨
// 
