#ifndef UART_H_
#define UART_H_
#include <avr/io.h>
void UART0_Init();
void UART0_Transmit(char data);
unsigned char UART0_Receive(void);

#endif /* UART_H_ */
