#ifndef SYSTEM_H_
#define SYSTEM_H_

//标准库 stdxx.h
#include <stdint.h>

//外设库 perip
#include "core.h"
#include "uart.h"
//#include "fpioa.h"
#include "sdrd.h"
#include "trap.h"
//驱动库 driver
#include "printf.h"


//---------------------------------
//开启仿真模式printf。不会打印串口，只通过CSR_msprint打印至终端，极大提高仿真速度
//上FPGA，必须注释掉此宏，就像这样: //#define sim_csr_printf 1
//#define sim_csr_printf 1
//---------------------------------

#define ENABLE  1u
#define DISABLE 0u

//自定义CSR
#define msprint    0x346  //仿真打印
#define mends      0x347  //仿真结束
#define minstret   0xB02  //minstret低32位
#define minstreth  0xB82  //minstret高32位
#define mtime      0xB03  //mtime低32位
#define mtimeh     0xB83  //mtime高32位
#define mtimecmp   0xB04  //mtimecmp低32位
#define mtimecmph  0xB84  //mtimecmp高32位
#define mcctr      0xB88  //系统控制
#define msip       0x345  //软件中断
//[0]:保留
//[1]:minstret使能
//[2]:mtime使能
//[3]:soft_rst写1复位
//[4]:保留

//中断相关
#define MCAUSE_INTERRUPT 0x80000000 //进入中断的原因是中断
#define MCAUSE_INTP_EX   4//外部中断
#define MCAUSE_INTP_TCMP 3//定时器中断
#define MCAUSE_INTP_SOFT 2//软件中断

//访存
#define SYS_RWMEM_W(addr) (*((volatile uint32_t *)(addr)))   //必须4字节对齐访问(低2位为0)
#define SYS_RWMEM_H(addr) (*((volatile uint16_t *)(addr)))   //半字(16bit)访问，但是部分外设不支持半字寻址写
#define SYS_RWMEM_B(addr) (*((volatile uint8_t  *)(addr)))   //允许访问4G地址空间任意字节，但是部分外设不支持字节寻址写

//FPIOA UART0
#define ICB_SLAVE_2                2
#define SYSIO_BASE                 (ICB_SLAVE_2 * 0x20000000u)
#define FPIOA_BASE                 (SYSIO_BASE + (0xF00))
#define FPIOA_OT_BASE              (FPIOA_BASE)
#define UART0_TX      7
#define UART_BASE             (SYSIO_BASE + (0x000))

//读取系统信息
uint32_t system_cpu_freq;//处理器频率
uint32_t system_cpu_freqM;//处理器频率，单位M
uint32_t system_iram_size;//指令存储器大小kb
uint32_t system_sram_size;//数据存储器大小kb
uint32_t system_vendorid;//Vendor ID

#endif
