#include <stdint.h>
#include <stdbool.h>
#include "uart.h"
/********************************************************************
 ** 函数名称：print_num
 ** 函数功能：打印成十进制数
 ** 输入参数：num:需要打印的数字信息
 ** 		base：数据类型（十进制、十六进制、8进制等）
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void print_num(uint32_t num, int base)
{
	if(num == 0)
	{
		return;
	}
	print_num(num/base, base);
	put_char("0123456789abcdef"[num%base]);							//逆序打印结果
}

/********************************************************************
 ** 函数名称：put_char
 ** 函数功能：打印单个字符
 ** 输入参数：c:需要打印的字符信息
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void put_char(char c)
{
	if (c == '\n')
		put_char('\r');
	reg_uart_data = c;
}

/********************************************************************
 ** 函数名称：print_str
 ** 函数功能：打印字符串
 ** 输入参数：*p:需要打印的字符串信息
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void print_str(const char *p)
{
	while (*p)
		put_char(*(p++));
}

/********************************************************************
 ** 函数名称：print_hex
 ** 函数功能：十进制转换为16进制
 ** 输入参数：v:需要转换的十进制数据
 ** 		digits：数据类型（十进制、十六进制、八进制）
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void print_hex(uint32_t v, int digits)
{
	for (int i = 7; i >= 0; i--)
	{
		char c = "0123456789abcdef"[(v >> (4*i)) & 15];
		if (c == '0' && i >= digits)
			continue;
		put_char(c);
		digits = i;
	}
}

/********************************************************************
 ** 函数名称：print_hex2
 ** 函数功能：十进制转换为16进制
 ** 输入参数：hex:需要转换的十进制数据
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void print_hex2(uint32_t hex)
{
	if(0 == hex)
	{
		put_char('0');
		return;
	}
	else
	{
		print_num(hex, 16);											//打印十六进制数
	}
}
/********************************************************************
 ** 函数名称：print_dec
 ** 函数功能：转换成十进制打印输出
 ** 输入参数：v:打印的十进制数
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void print_dec(uint32_t v)
{
	if(0 == v)
	{
		put_char('0');
		return;
	}
	else
	{
		print_num(v, 10);											//打印十进制数
	}
}

/********************************************************************
 ** 函数名称：print_flt
 ** 函数功能：打印浮点型数据（最多显示小数点后6）
 ** 输入参数：flt:打印的浮点数
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void print_flt(double flt)
{
	uint32_t icnt = 0;
	uint32_t tmpint = 0;

	tmpint = (int)(flt);
	print_dec(tmpint);
	put_char('.');
	flt = flt - tmpint;
	tmpint = (int)(flt * 1000000);
	print_dec(tmpint);
}

/********************************************************************
 ** 函数名称：printk
 ** 函数功能：自定义打印函数
 ** 输入参数：fmt：打印的字符串内容
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void printk(char *fmt, ...)
{
	char *pfmt = NULL;
	va_list vp;

	va_start(vp, fmt);
	pfmt = fmt;

	while(*pfmt)
	{
		switch(*pfmt)
		{
			case '%':
			{
				switch(*(pfmt + 1))
				{
					case 'c':
						put_char(va_arg(vp, int));
						pfmt++;
						break;
					case 'd':
					case 'D':
					case 'i':
						print_dec(va_arg(vp, int));
						pfmt++;
						break;

					case 'f':
						print_flt(va_arg(vp, double));
						pfmt++;
						break;

					case 's':
					case 'S':
						print_str(va_arg(vp, char*));
						pfmt++;
						break;

					case 'x':
					case 'X':
						print_hex2(va_arg(vp, int));
						pfmt++;
						break;
					case '%':
						put_char('%');
						break;

					default:
						put_char(*pfmt);
						break;
				}
				break;
			}
			case '\n':
				put_char('\n');
				break;
			case '\t':
				put_char('\t');
				break;
			default:
				put_char(*pfmt);
				break;
		}
		pfmt++;
	}
	va_end(vp);
}

/********************************************************************
 ** 函数名称：getchar_prompt
 ** 函数功能：
 ** 输入参数：
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
char getchar_prompt(char *prompt)
{
	int32_t c = -1;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	if (prompt)
		print_str(prompt);

	while (c == -1)
	{
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000)
		{
			if (prompt)
			{
				print_str(prompt);
			}
			cycles_begin = cycles_now;
		}
		c = reg_uart_data;
	}

	return c;
}

/********************************************************************
 ** 函数名称：get_char
 ** 函数功能：串口获取一个字符
 ** 输入参数：无
 ** 输出参数：无
 ** 返回参数：输出的字符
 ********************************************************************/
char get_char()
{
//	return getchar_prompt(0);
	put_char(getchar_prompt(0));
}
