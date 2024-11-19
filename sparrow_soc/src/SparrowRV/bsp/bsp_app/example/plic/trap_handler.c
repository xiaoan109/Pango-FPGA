#include "system.h"

/* 功能解释
__attribute__((interrupt("machine"))) 表示本函数用于中断，编译器自动为其保存上下文
interrupt("machine") 表示本函数是机器模式中断
void XXX_Handler() __attribute__((interrupt("machine"))); 表示XXX_Handler()用于机器模式中断，同时可以用同名函数覆盖
*/
//函数声明区
void PLIC1_FPIOA_ELI0_Handler() __attribute__((interrupt("machine")));
void PLIC1_FPIOA_ELI0_Handler()
{
    csr_msprint_string("PLIC1_Hdler\n");
}

void PLIC2_FPIOA_ELI1_Handler() __attribute__((interrupt("machine")));
void PLIC2_FPIOA_ELI1_Handler()
{
    csr_msprint_string("PLIC2_Hdler\n");
}

void PLIC3_FPIOA_ELI2_Handler() __attribute__((interrupt("machine")));
void PLIC3_FPIOA_ELI2_Handler()
{
    csr_msprint_string("PLIC3_Hdler\n");
}

void PLIC4_FPIOA_ELI3_Handler() __attribute__((interrupt("machine")));
void PLIC4_FPIOA_ELI3_Handler()
{
    csr_msprint_string("PLIC4_Hdler\n");
}

void PLIC5_UART0_TX_Handler()   __attribute__((interrupt("machine")));
void PLIC5_UART0_TX_Handler()
{
    csr_msprint_string("PLIC5_Hdler\n");
}

void PLIC6_UART0_RX_Handler()   __attribute__((interrupt("machine")));
void PLIC6_UART0_RX_Handler()
{
    csr_msprint_string("PLIC6_Hdler\n");
}

void PLIC7_UART1_TX_Handler()   __attribute__((interrupt("machine")));
void PLIC7_UART1_TX_Handler()
{
    csr_msprint_string("PLIC7_Hdler\n");
}

void PLIC8_UART1_RX_Handler()   __attribute__((interrupt("machine")));
void PLIC8_UART1_RX_Handler()
{
    csr_msprint_string("PLIC8_Hdler\n");
}

void PLIC9_TIMER0_OF_Handler()  __attribute__((interrupt("machine")));
void PLIC9_TIMER0_OF_Handler()
{
    csr_msprint_string("PLIC9_Hdler\n");
}

void PLIC10_SPI0_END_Handler()  __attribute__((interrupt("machine")));
void PLIC10_SPI0_END_Handler()
{
    csr_msprint_string("PLIC10_Hdler\n");
}





/*
//定时器中断服务程序
void SysTick_Handler() __attribute__((interrupt("machine")));
void SysTick_Handler()
{
    //printf("interrupt tcmp in original function\n");
}
*/
/*
//软件中断服务程序
void SW_Handler() __attribute__((interrupt("machine")));
void SW_Handler()
{
    //printf("interrupt soft in original function\n");
}
*/
/*
//硬件错误引发异常
void HardFault_Handler() __attribute__((interrupt("machine")));
void HardFault_Handler()
{
    while(1);
}
*/

