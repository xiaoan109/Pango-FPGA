/*** 
 * @FilePath       : \perip\include\la.h
 * @Author         : zkwang2001 1922601163@qq.com
 * @CreateDate     : 24-10-30
 * @LastEditors    : zkwang2001 1922601163@qq.com
 * @LastEditTime   : 24-11-11
 * @Version        :
 * @Description    : 
 * @                 
 * @
 * @Parameter       :
 * @                 
 * @
 * @IO Port         :
 * @                 
 * @
 * @Modification History
 * @   Date   |   Author   |   Version   |   Change Description
 * @==============================================================================
 * @ 23-08-24 |     NJU    |     0.1     | Original Version
 * @                 
 * @
 */
/*
 * la.h
 *
 *  Created on: Oct 30, 2024
 *      Author: 19226
 */

#ifndef LIB_PERIP_INCLUDE_LA_H_
#define LIB_PERIP_INCLUDE_LA_H_

#include "system.h"

#define LA_SLAVE_7        7
#define LA_BASE          (LA_SLAVE_7 * 0x20000000u)

#define LA_DATA           (LA_BASE + (0x00))
#define LA_TRGEN          (LA_BASE + (0x04))
#define LA_CHNSEL         (LA_BASE + (0x08))
#define LA_MODESEL        (LA_BASE + (0x0c))
#define LA_FREQSEL        (LA_BASE + (0x10)) 
#define LA_PRENUM         (LA_BASE + (0x14))
#define LA_UART_EN        (LA_BASE + (0x18))
#define LA_SPI_EN         (LA_BASE + (0x1c))
#define LA_INTERVAL       (LA_BASE + (0x20))


void la_set_data(uint32_t data);
void la_set_trgen(uint32_t trgen);
void la_set_chnsel(uint32_t chnsel);
void la_set_modesel(uint32_t modesel);
void la_set_freqsel(uint32_t freqsel);
void la_set_prenum(uint32_t prenum);

uint32_t la_get_data();
uint32_t la_get_trgen();
uint32_t la_get_chnsel();
uint32_t la_get_modesel();
uint32_t la_get_freqsel();
uint32_t la_get_prenum();

void la_set_uart_en(uint32_t uart_en);
void la_set_spi_en(uint32_t spi_en);
void la_set_interval(uint32_t interval);

#endif /* LIB_PERIP_INCLUDE_LA_H_ */
