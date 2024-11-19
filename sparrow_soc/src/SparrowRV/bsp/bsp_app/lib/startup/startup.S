    .section .init; /*声明此处段名为.init*/
    .globl _start; /*声明_start是全局的*/
    .global trap_vector_tab /*声明trap_vector_tab是全局的，初始化阶段配置mtvec*/
    .type _start,@function  /*声明_start是函数*/

_start:
.option push /*保存编译设置*/
.option norelax /*禁用相对寻址*/
.option norvc
    nop /*空操作*/
    la gp, __global_pointer$ /*设置gp全局指针，__global_pointer$来源于链接脚本，与data段关联，指向全局变量*/
.option pop
    la sp, _sp /*设置sp堆栈指针，_sp来源于链接脚本，指向普通的局部变量*/

    /*加载data段，存储需要初始化的全局变量和静态变量*/
    la a0, _data_lma /*程序存储器的data段起始地址 加载至 a0*/
    la a1, _data     /*数据存储器的data段起始地址 加载至 a1*/
    la a2, _edata    /*数据存储器的data段结束地址 加载至 a2*/
    bgeu a1, a2, 2f  /*a1大于等于a2，跳转至往下第一个2标签；否则向下执行*/
1:
    lw t0, (a0)      /*a0指向的地址 写入 t0*/
    sw t0, (a1)      /*t0的数据 写入 a1指向的地址 */
    addi a0, a0, 4   /*a0+4*/
    addi a1, a1, 4   /*a1+4*/
    bltu a1, a2, 1b  /*a1小于a2，跳转至往上第一个1标签；否则向下执行*/
    /*加载data段*/
2:

    /*清空bss段，存储不用初始化的全局变量和静态变量*/
    la a0, __bss_start /*bss段起始地址 加载至 a0*/
    la a1, _end        /*bss段结束地址 加载至 a1*/
    bgeu a0, a1, 2f    /*a0大于等于a1，跳转至往下第一个2标签；否则向下执行*/
1:
    sw zero, (a0)      /*a0指向的地址 写入 0*/
    addi a0, a0, 4     /*a0+4*/
    bltu a0, a1, 1b    /*a0小于a1，跳转至往上第一个1标签；否则向下执行*/
    /*清空bss段*/
2:

    call sparrowrv_system_init  /*初始化函数*/
    call main   /*main函数*/

    csrwi 0x347,1  /*仿真专用，退出仿真*/
loop:  /*无限循环*/
    j loop


/*----中断向量表----
入口基地址(trap_vector_tab)可以放在程序存储器的任何地方，但必须32bit对齐，初始化阶段需要写入CSR_mtvec。
每个异常和中断都有独立的trap编码，每个trap编码对应中断向量表的一个32bit表项，每个表项必须按照trap编码在内存上连续分布
发生中断后，跳转至中断向量表的对应表项，即PC = 入口基地址 + trap编码*4
每个表项存放了一条跳转指令，可以跳转至相应的中断服务程序。也可以放一条其他指令，但必须是RV32I指令。 */
trap_vector_tab: 
    j   _start                      /*trap编码 0，保留，软件复位*/
    j   HardFault_Handler           /*trap编码 1，硬件错误异常*/
    j   SW_Handler                  /*trap编码 2，软件中断*/
    j   SysTick_Handler             /*trap编码 3，核内64bit定时器中断*/
    j   PLIC0_Handler               /*trap编码 4，PLIC0保留*/
    j   PLIC1_FPIOA_ELI0_Handler    /*trap编码 5，FPIOA_ELI0中断*/
    j   PLIC2_FPIOA_ELI1_Handler    /*trap编码 6，FPIOA_ELI1中断*/
    j   PLIC3_FPIOA_ELI2_Handler    /*trap编码 7，FPIOA_ELI2中断*/
    j   PLIC4_FPIOA_ELI3_Handler    /*trap编码 8，FPIOA_ELI3中断*/
    j   PLIC5_UART0_TX_Handler      /*trap编码 9，UART0发送完成中断*/
    j   PLIC6_UART0_RX_Handler      /*trap编码10，UART0接收数据中断*/
    j   PLIC7_UART1_TX_Handler      /*trap编码11，UART1发送完成中断*/
    j   PLIC8_UART1_RX_Handler      /*trap编码12，UART0接收数据中断*/
    j   PLIC9_TIMER0_OF_Handler     /*trap编码13，定时器0溢出中断*/
    j   PLIC10_SPI0_END_Handler     /*trap编码14，SPI0收发结束中断*/
	.word   0


/*.weak弱定义了每个中断服务程序，可使用同名函数取代，具体见trap_handler.c*/
.section  .text
    .weak   HardFault_Handler
    .weak   SW_Handler
    .weak   SysTick_Handler
    .weak   PLIC0_Handler
    .weak   PLIC1_FPIOA_ELI0_Handler
    .weak   PLIC2_FPIOA_ELI1_Handler
    .weak   PLIC3_FPIOA_ELI2_Handler
    .weak   PLIC4_FPIOA_ELI3_Handler
    .weak   PLIC5_UART0_TX_Handler
    .weak   PLIC6_UART0_RX_Handler
    .weak   PLIC7_UART1_TX_Handler
    .weak   PLIC8_UART1_RX_Handler
    .weak   PLIC9_TIMER0_OF_Handler
    .weak   PLIC10_SPI0_END_Handler
HardFault_Handler:          1: j 1b
SW_Handler:                 1: j 1b
SysTick_Handler:            1: j 1b
PLIC0_Handler:              1: j 1b
PLIC1_FPIOA_ELI0_Handler:   1: j 1b
PLIC2_FPIOA_ELI1_Handler:   1: j 1b
PLIC3_FPIOA_ELI2_Handler:   1: j 1b
PLIC4_FPIOA_ELI3_Handler:   1: j 1b
PLIC5_UART0_TX_Handler:     1: j 1b
PLIC6_UART0_RX_Handler:     1: j 1b
PLIC7_UART1_TX_Handler:     1: j 1b
PLIC8_UART1_RX_Handler:     1: j 1b
PLIC9_TIMER0_OF_Handler:    1: j 1b
PLIC10_SPI0_END_Handler:    1: j 1b

/*
八百标兵奔北坡
北坡炮兵并排跑
炮兵怕把标兵碰
标兵怕碰炮兵炮
*/
