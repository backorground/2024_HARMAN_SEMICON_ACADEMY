#include "Button.h"


void Button_Init(Button *button, volatile uint8_t *ddr, volatile uint8_t *pin, uint8_t pinNum)
{
	button->ddr = ddr;	//void에서 포인터 변수 따로 받아서 28줄 변수에 주소 받아오고 button구조체에 집어넣어
	button->pin	= pin;
	button->btnPin = pinNum;
	button->prevState = RELEASED;			//초기화로 아무것도 안누른 상태 =1
	*button->ddr &= ~(1<< button->btnPin);	//버튼 핀을 입력으로 설정-->0은 입력이고, 자리수에 ~걸어 0 만들고 & 쓰면 원하는 핀넘버 0 돼
}

uint8_t BUTTON_getState(Button *button)//구조체 버튼에 저장된 값들을 이용
{
	uint8_t curState = *button->pin & (1<< button->btnPin);	//버튼이 눌렷는지 상태 알기위함==>누르면 0
	if((curState==PUSHED) && (button->prevState==RELEASED)) //안누른 상태에서 누르면..pused=enum에서 1//enum에서release 초기화 값가져
	{
		_delay_ms(50);
		button->prevState = PUSHED; //버튼의 상태를 누른 상태로 변환
		return ACT_PUSHED;			//버튼 눌렷음을 리턴함
	}
	else if ((curState	!= PUSHED) && (button->prevState==PUSHED))//prevstate를 처음에 release로 초기화 햇고 release는 enum으로 1로 초기회됨
	{
		_delay_ms(50);
		button->prevState = RELEASED;	//버튼을 뗀 상태로 변환
		return ACT_REALEASED;			//버튼이 떨어졋음을 반환
	}
	return NO_ACT;						//아무것도 안일어남...
}
