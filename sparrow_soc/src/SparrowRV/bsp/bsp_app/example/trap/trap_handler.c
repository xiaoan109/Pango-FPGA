#include "system.h"

/* 功能解释
__attribute__((interrupt("machine"))) 表示本函数用于中断，编译器自动为其保存上下文
interrupt("machine") 表示本函数是机器模式中断
void XXX_Handler() __attribute__((interrupt("machine"))); 表示XXX_Handler()用于机器模式中断，同时可以用同名函数覆盖
*/
//函数声明区
/*
//定时器中断服务程序
void SysTick_Handler() __attribute__((interrupt("machine")));
void SysTick_Handler()
{
    //printf("interrupt tcmp in original function\n");
}
*/

//软件中断服务程序
void SW_Handler() __attribute__((interrupt("machine")));
void SW_Handler()
{
    printf("interrupt soft in original function\n");
}

/*
//硬件错误引发异常
void HardFault_Handler() __attribute__((interrupt("machine")));
void HardFault_Handler()
{
    while(1);
}
*/

