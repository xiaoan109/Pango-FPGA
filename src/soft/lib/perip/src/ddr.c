/*
 * ddr.c
 *
 *  Created on: Sep 25, 2023
 *      Author: qingchen
 */

#include "ddr.h"
#include "system.h"
volatile DDR *ddr = (DDR *)DDR_BASE;

void ddr_read_line() {
    printf("Try to read data at %p\r\n",ddr->waddr);

    ddr->state = 0;
    ddr->ctrl = DDR_CTRL_READ;
    while((ddr->state&DDR_STATE_RDONE) == 0);
    ddr->ctrl = 0;

    printf("Read data:  ");
    for (int i = 0; i < 8; ++i) {
        printf("0x%08x ",ddr->wdata[i]);
    } printf("\r\n");
}
void ddr_write_line() {
    printf("Try to write data at %p\r\n",ddr->waddr);
    printf("Write data: ");
    for (int i = 0; i < 8; ++i) {
        printf("0x%08x ",ddr->wdata[i]);
    } printf("\r\n");

    ddr->state = 0;
    ddr->ctrl = DDR_CTRL_WRITE;
    while((ddr->state&DDR_STATE_WDONE) == 0);
    ddr->ctrl = 0;
}

void ddr_read_write_line() {

    printf("Try to write data at %p\r\n",ddr->waddr);
    printf("Write data: ");
    for (int i = 0; i < 8; ++i) {
        printf("0x%08x ",ddr->wdata[i]);
    } printf("\r\n");
    printf("Try to read data at %p\r\n",ddr->waddr);

    ddr->state = 0;
    ddr->ctrl = DDR_CTRL_READ|DDR_CTRL_WRITE;
    while((ddr->state) == 0);
    ddr->ctrl = 0;

    printf("Read data:  ");
    for (int i = 0; i < 8; ++i) {
        printf("0x%08x ",ddr->wdata[i]);
    } printf("\r\n");
}
