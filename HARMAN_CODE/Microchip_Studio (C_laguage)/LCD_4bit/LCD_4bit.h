#ifndef LCD_4BIT_H_
#define LCD_4BIT_H_

#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/delay.h>

#define LCD_DATA_DDR	DDRD
#define LCD_DATA_PORT	PORTD
#define LCD_DATA_PIN	PIND
#define LCD_RS_DDR		DDRE
#define LCD_RW_DDR		DDRE
#define LCD_E_DDR		DDRE
#define LCD_RS_PORT		PORTE
#define LCD_RW_PORT		PORTE
#define LCD_E_PORT		PORTE
#define LCD_RS			5
#define LCD_RW			6
#define LCD_E			7

#define COMMAND_DISPLAY_CLEAR	0X01
#define COMMAND_DISPLAY_ON		0X0C
#define COMMAND_DISPLAY_OFF		0X08
#define COMMAND_8_BIT_MODE		0X38
#define COMMAND_4_BIT_MODE		0X28
#define COMMAND_ENTRY_MODE		0X06


void LCD_Data(uint8_t data);
void LCD_Data4bit(uint8_t data);
void LCD_WriteMode();
void LCD_ReadPin();
void LCD_EnablePin();
void LCD_WriteCommand(uint8_t commadData);
void LCD_WriteData(uint8_t charData);
void LCD_GotoXY(uint8_t row, uint8_t col);
void LCD_WriteString(char *string);
void LCD_WriteStringXY(uint8_t row, uint8_t col, char *string);
void LCD_Init();

#endif