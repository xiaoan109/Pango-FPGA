#ifndef _UART_H_
#define _UART_H_

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stddef.h>
#include <stdarg.h>


// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.

#define reg_uart_clkdiv (*(volatile uint32_t*)0x00008000)
#define reg_uart_data   (*(volatile uint32_t*)0x00008010)



void put_char(char c);
void print_num(uint32_t num, int base);
void print_str(const char *p);
void print_hex(uint32_t v, int digits);
void print_hex2(uint32_t hex);
void print_dec(uint32_t v);
void print_flt(double flt);
void printk(char *fmt, ...);
char getchar_prompt(char *prompt);
char get_char();


#endif
