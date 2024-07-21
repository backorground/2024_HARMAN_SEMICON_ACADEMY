#include "I2C.h"

void I2C_Init()	//하드웨어 환경조성
{
	I2C_DDR |= (1<<I2C_SCL) | (1<<I2C_SDA);	//출력설정
	TWBR = 72;	//100khz
	//TWBR = 32;	//200khz
	//TWBR = 12;	//400khz
}

void I2C_Start()
{
	TWCR = (1<<TWINT) | (1<<TWSTA) | (1<<TWEN);
	/* TWINT에 1을 셋트하여 인터럽트를 발생시키는 것 같지만
	소프트웨어 적으로 1을 셋트하여 플래그를 클리어 하는 것 */
	while (!(TWCR & (1<<TWINT)));	
	//하드웨어적으로 TWINT클리어 되는지 안되는지 시점 결정
	//예전에는 인터럽트 걸리면 1로 세팅댐..
	//지금은 미리 1로 설정해 뒀다가....	
}

void I2C_Stop()
{
	TWCR = (1<<TWINT) | (1<<TWEN) | (1<<TWSTO);
}

void I2C_TxData(uint8_t data)	//1byte
{
	TWDR = data;
	TWCR = (1<<TWINT) | (1<<TWEN);
	while (!(TWCR & (1<<TWINT)));	//전송완료 대기
}

void I2C_TxByte(uint8_t devAddRW, uint8_t data)
{
	I2C_Start();
	I2C_TxData(devAddRW);
	I2C_TxData(data);;
	I2C_Stop();
}