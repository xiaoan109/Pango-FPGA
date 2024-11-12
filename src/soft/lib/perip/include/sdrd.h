#ifndef _SDRD_H_
#define _SDRD_H_

#include "system.h"

#define ICB_SLAVE_4        4
#define SDRD_BASE          (ICB_SLAVE_4 * 0x20000000u)

uint8_t sdrd_init_state_read();
uint8_t sdrd_busy_chk();
uint8_t sdrd_buffer_read(uint32_t addr);
void sdrd_sector_set(uint32_t sector_number);

#endif
