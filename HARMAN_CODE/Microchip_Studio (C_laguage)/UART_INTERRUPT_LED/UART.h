/*
 * UART.h
 *
 * Created: 2024-04-08 오후 8:17:09
 *  Author: user
 */ 


#ifndef UART_H_
#define UART_H_

#include <avr/io.h>

void UART0_Init();
void UART0_Transmit(char data);
unsigned char UART0_Receve();

#endif /* UART_H_ */