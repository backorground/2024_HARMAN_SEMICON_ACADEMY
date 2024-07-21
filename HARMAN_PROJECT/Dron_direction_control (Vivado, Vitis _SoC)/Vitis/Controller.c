#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xintc.h"
#include "xiic.h"
#include "xil_exception.h"
#include "xuartlite.h"
//BTN
#define BTN_ID XPAR_AXI_GPIO_0_DEVICE_ID
#define BTN_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID
#define BTN_CHANNEL 1
//UART
#define UART_ID XPAR_AXI_UARTLITE_1_DEVICE_ID
#define UART_VEC_ID XPAR_INTC_0_UARTLITE_1_VEC_ID
//INTC
#define INTC_ID XPAR_INTC_0_DEVICE_ID
//JOYSTICK
#define JOYSTICK_ADDR XPAR_MYIP_JOYSTICK_0_S00_AXI_BASEADDR
//LCD
#define IIC_ID XPAR_AXI_IIC_0_DEVICE_ID
//UltraSonic
#define ULT_ADDR XPAR_MYIP_ULTRASONIC_0_S00_AXI_BASEADDR		//ultrasonic address
//PWM 4개
#define PWM_ADDR0 XPAR_MYIP_PWM_0_S00_AXI_BASEADDR
#define PWM_ADDR1 XPAR_MYIP_PWM_1_S00_AXI_BASEADDR
#define PWM_ADDR2 XPAR_MYIP_PWM_2_S00_AXI_BASEADDR
#define PWM_ADDR3 XPAR_MYIP_PWM_3_S00_AXI_BASEADDR
//함수 선언
void BTN_ISR(void *CallBackRef);
void Iic_LCD_write_byte(u8 tx_data, u8 rs);
void Iic_LCD_init(void);
void Iic_movecursor(u8 row, u8 col);
void LCD_write_string(char *string);
void SendHandler(void *CallBackRef, unsigned int EvetnData);
void RecvHandler(void *CallBackRef, unsigned int EvetnData);
int getZone(int x, int y);
XGpio btn_device;
XIntc intc;
XUartLite uart_device;
XIic iic_device;
//전역변수 선언
volatile unsigned int *ultrasonic;
volatile unsigned int *joystick;
volatile unsigned int *pwm0;
volatile unsigned int *pwm1;
volatile unsigned int *pwm2;
volatile unsigned int *pwm3;
//bluetooth
volatile char Tx_joystick[5] = {};
volatile char Rx[5]	= {0};
volatile char Tx_btn[5] = {};

char btn_int_flag;

#define xdata joystick[0]
#define ydata joystick[1]

#define BL 3
#define EN 2
#define RW 1
#define RS 0

#define COMMAND 0
#define DATA 1

int main()
{
	XGpio_Config *cfg_ptr;
	ultrasonic = (volatile unsigned int*)ULT_ADDR;
	joystick = (volatile unsigned int*)JOYSTICK_ADDR;
	pwm0 = (volatile unsigned int*)PWM_ADDR0;
	pwm1 = (volatile unsigned int*)PWM_ADDR1;
	pwm2 = (volatile unsigned int*)PWM_ADDR2;
	pwm3 = (volatile unsigned int*)PWM_ADDR3;

    init_platform();

    print("START!!\n\r");

    XUartLite_Initialize(&uart_device, UART_ID);

    XIic_Initialize(&iic_device, IIC_ID);
	Iic_LCD_init();

    //GPIO 초기화
    cfg_ptr = XGpio_LookupConfig(BTN_ID);
	XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr->BaseAddress);
	XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);

	XIntc_Initialize(&intc, INTC_ID);
	XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);

	XIntc_Enable(&intc, BTN_VEC_ID);
	XIntc_Start(&intc, XIN_REAL_MODE);

	XGpio_InterruptEnable(&btn_device, BTN_CHANNEL); //개별
	XGpio_InterruptGlobalEnable(&btn_device);		//글로벌

	Xil_ExceptionInit(); // Microblaze enable 해준거 설정
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc);
	Xil_ExceptionEnable();

	XUartLite_SetRecvHandler(&uart_device, RecvHandler, &uart_device);
	XUartLite_SetSendHandler(&uart_device, SendHandler, &uart_device);
	XUartLite_EnableInterrupt(&uart_device);

	LCD_write_string("distance :   cm");
	Iic_movecursor(1, 0);
    while(1){
    	if(Rx){
			RecvHandler(&uart_device, Rx);
		}
		u32 distance;
		memcpy((void *)&distance, (void *)Rx, sizeof(distance));
		distance = atoi(Rx);

		Iic_movecursor(0, 10);
		Iic_LCD_write_byte('0' + distance/100%10, DATA);
		Iic_LCD_write_byte('0' + distance/10%10, DATA);
		Iic_LCD_write_byte('0' + distance%10, DATA);
		xil_printf("distance : %d cm \n\r", distance);

    	int zone = getZone(xdata, ydata);
    	sprintf(Tx_joystick, "%d", zone);
    	xil_printf("%d, %d \n\r", xdata, ydata);
    	SendHandler(&uart_device, Tx_joystick);

    		if(btn_int_flag){
    			MB_Sleep(1);
    		    XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);

    		    //상
    		    if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL) & 0b0001){
    		    	char btn_value = 'a';
    		    	sprintf(Tx_btn, "%c", btn_value);
    		    	SendHandler(&uart_device, Tx_btn);
    		    	xil_printf("result = %s\n\r", Tx_btn);
    		    	sprintf(Tx_btn, "%c", 0);
    		    }

    		    	    //하
    		    else if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL) & 0b1000){
    		    	char btn_value = 'b';
    		    	sprintf(Tx_btn, "%c", btn_value);
    		    	SendHandler(&uart_device, Tx_btn);
    		    	xil_printf("result = %s\n\r", Tx_btn);
    		    	sprintf(Tx_btn, "%c", 0);
    		    }
    		}

    }
    cleanup_platform();
    return 0;
}
void SendHandler(void *CallBackRef, unsigned int EventData){
	XUartLite_Send(&uart_device, (u8 *)Tx_joystick, sizeof(Tx_joystick));
	XUartLite_Send(&uart_device, (u8 *)Tx_btn, sizeof(Tx_btn));
}
void RecvHandler(void *CallBackRef, unsigned int EventData){
    XUartLite_Recv(&uart_device, (u8 *)Rx, sizeof(Rx));

}
void BTN_ISR(void *CallBackRef){
	//XGpio *Gpio_ptr = (XGpio *)CallBackRef;
	btn_int_flag =1;
	XGpio_InterruptClear(&btn_device, BTN_CHANNEL);
	XGpio_InterruptDisable(&btn_device, BTN_CHANNEL);
	return;
}
void Iic_LCD_write_byte(u8 tx_data, u8 rs){ //d7 d6 d5 d4 BL EN RW RS
	u8 data_t[4] = {0,};
	data_t[0] = (tx_data & 0xf0) | (1 << BL) | (rs & 1) | (1 << EN);	//상위 en = 1
	data_t[1] = (tx_data & 0xf0) | (1 << BL) | (rs & 1); //상위 en = 0
	data_t[2] = (tx_data << 4) | (1 << BL) | (rs & 1) | (1 << EN); //하위 en = 1
	data_t[3] = (tx_data << 4) | (1 << BL) | (rs & 1); //하위 en = 0
	XIic_Send(iic_device.BaseAddress, 0x27, &data_t, 4, XIIC_STOP);
}
void Iic_LCD_init(void){
	MB_Sleep(15);
	Iic_LCD_write_byte(0x33, COMMAND);
	Iic_LCD_write_byte(0x32, COMMAND);
	Iic_LCD_write_byte(0x28, COMMAND);
	Iic_LCD_write_byte(0x0c, COMMAND);
	Iic_LCD_write_byte(0x01, COMMAND);
	Iic_LCD_write_byte(0x06, COMMAND);
	MB_Sleep(10);
	return;
}
void Iic_movecursor(u8 row, u8 col){
	row %= 2;
	col %= 40;
	Iic_LCD_write_byte(0x80 | (row << 6) | col, COMMAND);
	return;
}
void LCD_write_string(char *string){
	for (int i = 0; string[i]; i++){
		Iic_LCD_write_byte(string[i], DATA);
	}
	return;
}


int getZone(int x, int y) {
    if (x < 20 && y < 20) return 1;
    if (20 <= x && x < 41 && 20 <= y && y < 41) return 2;
    if (41 <= x && x < 62 && 41 <= y && y < 62) return 3;
    if (62 < x && x < 70 && y < 20) return 4;
    if (62 < x && x < 70 && 20 <= y && y < 41) return 5;
    if (62 < x && x < 70 && 41 <= y && y < 62) return 6;
    if (107 < x && y < 20) return 7;
    if (88 <= x && x <= 107 && 20 <= y && y < 41) return 8;
    if (70 <= x && x <= 88 && 41 <= y && y < 62) return 9;
    if (x < 20 && 62 < y && y < 70) return 10;
    if (20 <= x && x < 41 && 62 < y && y < 70) return 11;
    if (41 <= x && x < 62 && 62 < y && y < 70) return 12;
    if (70 < x && x < 88 && 62 < y && y < 70) return 13;
    if (88 <= x && x < 107 && 62 < y && y < 70) return 14;
    if (107 <= x && 62 < y && y < 70) return 15;
    if (x < 20 && 107 < y) return 16;
    if (20 <= x && x < 41 && 88 < y && y <= 107) return 17;
    if (41 <= x && x < 62 && 70 < y && y < 88) return 18;
    if (62 < x && x < 70 && 107 < y) return 19;
    if (62 < x && x < 70 && 88 < y && y <= 107) return 20;
    if (62 < x && x < 70 && 70 < y && y <= 88) return 21;
    if (107 < x && 107 < y) return 22;
    if (88 < x && x <= 107 && 88 < y && y <= 107) return 23;
    if (70 < x && x <= 88 && 70 < y && y <= 88) return 24;
    return 0; // Neutral zone
}
