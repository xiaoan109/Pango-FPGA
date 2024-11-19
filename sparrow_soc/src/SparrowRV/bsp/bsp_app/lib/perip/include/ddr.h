/*
 * ddr.h
 *
 *  Created on: Sep 25, 2023
 *      Author: qingchen
 */

#ifndef LIB_PERIP_INCLUDE_DDR_H_
#define LIB_PERIP_INCLUDE_DDR_H_

#include <stdint.h>
#define ICB_SLAVE_5        5
#define DDR_BASE          (ICB_SLAVE_5 * 0x20000000u)

#define DDR_CTRL_READ   0b01
#define DDR_CTRL_WRITE  0b10
#define DDR_STATE_RDONE 0b01
#define DDR_STATE_WDONE 0b10
typedef struct {
    volatile uint32_t ctrl;
    volatile uint32_t state;
    volatile uint32_t wdata[8];
    volatile uint32_t waddr;
    volatile uint32_t rdata[8];
    volatile uint32_t raddr;

}DDR;

extern volatile DDR *ddr;


void ddr_read_line();
void ddr_write_line();
void ddr_read_write_line();
#endif /* LIB_PERIP_INCLUDE_DDR_H_ */
