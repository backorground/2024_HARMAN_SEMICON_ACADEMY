#ifndef UART_H_
#define UART_H_

#include <avr/io.h>

void UART0_Init();
void UART0_Transmit(char data);

void USART0_ISR_Process_byGT();
unsigned char UART0_Receve();

#endif /* UART_H_ */