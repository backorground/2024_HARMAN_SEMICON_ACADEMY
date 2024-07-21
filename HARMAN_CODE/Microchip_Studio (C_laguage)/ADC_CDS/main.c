#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include "UART.h"


FILE OUTPUT = FDEV_SETUP_STREAM(UART0_Transmit, NULL, _FDEV_SETUP_WRITE);

void ADC_Init()
{
	ADMUX |= (1<<REFS0);	//기준전압설정
	ADCSRA |= (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0); //128분주
	//ADCSRA |= (1<<ADSC);	//단일모드 스타트
	ADCSRA |= (1<<ADEN);	//enable
	ADCSRA |= (1<<ADFR);	//러닝모드
}

int read_ADC(uint8_t channel)
{
	ADMUX = ((ADMUX & 0xf0) | channel & 0x0f); //단일 입력 채널 선택
	ADCSRA |= (1<<ADSC);	//변환시작
	while(!(ADCSRA & (1<<ADIF)));	//변환종료 대기
	
	return ADC;
}

int main(void)
{
	
	DDRD = 0XFF;
	PORTD = 0x00;
	
	char i;
	uint8_t ledData = 0x01;
	
	
    int read;
	ADC_Init();
	UART0_Init();
	stdout = &OUTPUT;
	
    while (1) 
    {
		read = read_ADC(0);
		printf("channel 0 : %d\n", read);
		_delay_ms(100);		
		
		
		if(250>=read)	//a누르면 꺼짐
		{
			PORTD = 0xff;
			ledData = (ledData>>7)|(ledData<<1);
		}
		else if ((500>=read))	//b누르면 켜짐
		{
			PORTD = 0x00;
			ledData = (ledData>>7)|(ledData<<1);
		}
		else if ((750>=read))	//다 켜진상태에서 하나씩 꺼짐
		{
			for(i=0; i<8; i++)
			{
				PORTD |= 1 <<i;
				_delay_ms(100);
				PORTD = 0x00;
			}
		}
	
    }
}

