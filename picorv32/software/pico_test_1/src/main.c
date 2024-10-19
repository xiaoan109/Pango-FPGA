#include "uart.h"
#include "spi.h"

#define led_address 			(*(volatile uint32_t*)0x00008020)
#define gpio_address 			(*(volatile uint32_t*)0x00008030)
#define gpio_point   			(volatile uint32_t*)0x00008030

// #define SYSTEM_CNT_M			125										//系统时钟单位：MHz
#define SYSTEM_CNT_M			100										//系统时钟单位：MHz
#define SYSTEM_CLOCK			SYSTEM_CNT_M*1000000UL
#define BAUND_9600				((SYSTEM_CLOCK)/9600)
#define BAUND_115200			(SYSTEM_CLOCK/115200)
#define GPIO_DATA				0xaa55
#define LED_DELAY				5000000UL
// #define LED_DELAY				5000UL

int temp_data = 0;
void led_blink(void);

/********************************************************************
 ** 函数名称：led_blink
 ** 函数功能：led blin测试（采用计数器的方式）
 ** 输入参数：无
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void led_blink(void)
{
	int cnt = 0;
	temp_data = *gpio_point;
	if(GPIO_DATA == temp_data)
	{
		printk("gpio success\n");
	}
	else
	{
		printk("gpio failed\n");
	}

	led_address = 0xff;
	while(1)
	{
		cnt++;
		if(cnt == LED_DELAY / 2)
		{
			led_address = 0x00;
		}
		else if(cnt == LED_DELAY)
		{
			cnt = 0;
			led_address = 0xff;
			printk("led_blink ok\n");
		}
	}
}

int main(void)
{
	reg_uart_clkdiv = BAUND_9600;

	printk("Hello Risc-V Pango 2019\n");
	printk("test data = %d,%f,%s,0x = %x\n", 100,33.456,"2019",100);
	printk("simple compute : 50*10 = %d,100/3 = %f,100%3 = %d\n", 50*10,(double)100/3,(int)100%3);
	led_blink();
	// uint8_t data = 0;
	// SPI_CS_Enable();
	// SPI_WriteData(0xAA);
	// data = SPI_ReadData();
	// led_address = data;
	// SPI_WriteData(0x55);
	// data = SPI_ReadData();
	// led_address = data;
	// SPI_CS_Disable();
	return 0;
}






