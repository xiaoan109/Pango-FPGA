#ifndef _PLIC_H_
#define _PLIC_H_
#include "system.h"

#define ICB_SLAVE_3        3
#define PLIC_BASE          (ICB_SLAVE_3 * 0x20000000u)

#define PLIC_PRT(PLIC_ID)  (PLIC_BASE + (PLIC_ID<<2))
#define PLIC_IP            (PLIC_BASE + (0x001000))
#define PLIC_IE            (PLIC_BASE + (0x002000))
#define PLIC_ITH           (PLIC_BASE + (0x200000))
#define PLIC_CPC           (PLIC_BASE + (0x200004))

//source_id
#define PLIC0_ID                0  //PLIC0保留
#define PLIC1_FPIOA_ELI0_ID     1  //FPIOA_ELI0中断
#define PLIC2_FPIOA_ELI1_ID     2  //FPIOA_ELI1中断
#define PLIC3_FPIOA_ELI2_ID     3  //FPIOA_ELI2中断
#define PLIC4_FPIOA_ELI3_ID     4  //FPIOA_ELI3中断
#define PLIC5_UART0_TX_ID       5  //UART0发送完成中断
#define PLIC6_UART0_RX_ID       6  //UART0接收数据中断
#define PLIC7_UART1_TX_ID       7  //UART1发送完成中断
#define PLIC8_UART1_RX_ID       8  //UART0接收数据中断
#define PLIC9_TIMER0_OF_ID      9  //定时器0溢出中断
#define PLIC10_SPI0_END_ID      10 //SPI0收发结束中断


void plic_source_priority_set(uint32_t source_id, uint32_t priority);
uint32_t plic_source_priority_read(uint32_t source_id);
uint32_t plic_source_ip_read(uint32_t source_id);
void plic_ie_set(uint32_t source_id, uint32_t sel);
uint32_t plic_ie_read(uint32_t source_id);
void plic_ith_set(uint32_t ith);
uint32_t plic_eip_id_read();


#endif
