

#include "Button.h"

//버튼 ddr과 pin의 주소를 받기 위해 

int main(void)
{
    LED_DDR = 0xff;
	Button btnOn;
	Button btnOff;
	Button btnToggle;
	
	Button_Init(&btnOn, &BUTTON_DDR, &BUTTON_PIN, BUTTON_ON);
	Button_Init(&btnOff, &BUTTON_DDR, &BUTTON_PIN, BUTTON_OFF);
	Button_Init(&btnToggle, &BUTTON_DDR, &BUTTON_PIN, BUTTON_TOGGLE);
	
	
    while (1) //누르고 있는 상태는 아래 어느것에도 만족 안해서 while안에서 계속 돌고있어--> 띄면 결정돼
				// 누르고 잇고, 떼고의 상태는 getstate함수 봐pushed랑 연관잇어
    {
		if(BUTTON_getState(&btnOn)==ACT_REALEASED)
		{
			LED_PORT =0xff;
		}
		if(BUTTON_getState(&btnOff)==ACT_REALEASED)		//눌럿다 떼야 release반환 (getstate함수에 if는 눌럿을때, else는 뗏을때 )
		{
			LED_PORT = 0x00;
		}
		if(BUTTON_getState(&btnToggle)==ACT_REALEASED)		//&btntoggle은 버튼값
		{
			LED_PORT ^= 0xff;
		}
    }
}

//현재상태와 과거상태를 비교하고 그 결과를 내놓고 현재값을 과거로 바꿔줘