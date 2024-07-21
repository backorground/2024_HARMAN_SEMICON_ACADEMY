#ifndef BUTTON_H_
#define BUTTON_H_

#define F_CPU 16000000UL
#include <util/delay.h>
#include <avr/io.h>

#include <stdio.h>
#define LED_DDR			DDRA
#define LED_PORT		PORTA
#define BUTTON_DDR		DDRC

#define BUTTON_PIN		PINC
#define BUTTON_ON		0
#define BUTTON_OFF		1
#define BUTTON_TOGGLE	2

enum{PUSHED, RELEASED};	//enum 안에 있는 변수들은 나열순 대로 정수 부여받아
//pushed=0, released=1
enum{NO_ACT, ACT_PUSHED, ACT_REALEASED};


typedef struct _button
{
	volatile uint8_t *ddr;	//
	volatile uint8_t *pin;	//
	uint8_t btnPin;			//핀번호
	uint8_t prevState;		//이전상태
	
}Button;

void Button_Init(Button *button, volatile uint8_t *ddr, volatile uint8_t *pin, uint8_t pinNum);
uint8_t BUTTON_getState(Button *button);


#endif /* BUTTON_H_ */