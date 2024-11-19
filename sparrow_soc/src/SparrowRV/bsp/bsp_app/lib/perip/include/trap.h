#ifndef _TRAP_H_
#define _TRAP_H_
#include "system.h"

#define TRAP_GLBL 0 //全局中断
#define TRAP_SOFT 3 //软件中断
#define TRAP_TCMP 7 //定时器中断
#define TRAP_EXTI 11 //外部中断

uint8_t trap_global_ctrl(uint8_t en);
uint8_t trap_en_ctrl(uint8_t sel, uint8_t en);
uint32_t trap_mip_state(uint8_t sel);

#endif
