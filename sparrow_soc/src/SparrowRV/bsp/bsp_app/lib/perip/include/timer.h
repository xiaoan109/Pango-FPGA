#ifndef _TIMER_H_
#define _TIMER_H_
#include "system.h"

#define ICB_SLAVE_2          2
#define SYSIO_BASE           (ICB_SLAVE_2 * 0x20000000u)
#define TIMER0_BASE          (SYSIO_BASE + (0x300))

#define TIMER_CTRL           (TIMER0_BASE + (0x00))
#define TIMER_CMPO           (TIMER0_BASE + (0x04))
#define TIMER_CAPI           (TIMER0_BASE + (0x08))
#define TIMER_TCOF           (TIMER0_BASE + (0x0c))

//触发后自动清零
#define TIMER_TRIG_Z      0b00u //不触发
#define TIMER_TRIG_P      0b01u //上升沿触发
#define TIMER_TRIG_N      0b10u //下降沿触发
#define TIMER_TRIG_D      0b11u //双边沿触发

#define TIMER_OF_IRQ    6  //定时器触发比较值0中断

void timer_en_ctrl(uint32_t timer_state);
void timer_cmpol_ctrl(uint32_t cmpol);
void timer_div_set(uint32_t diver);
void timer_overflow_set(uint32_t overflow);
void timer_cmpval_set(uint32_t cmp0val, uint32_t cmp1val);
uint32_t timer_cnt_val_read();
void timer_capi_trig_set(uint32_t capi_sel, uint32_t trig_mode);
uint32_t timer_capi_trig_read(uint32_t capi_sel);
uint32_t timer_cap_val_read();
void timer_of_irq_ctrl(uint32_t timer_of_irq_en);

#endif
