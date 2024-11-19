/*
 * @FilePath       : \perip\src\la.c
 * @Author         : zkwang2001 1922601163@qq.com
 * @CreateDate     : 24-10-30
 * @LastEditors    : zkwang2001 1922601163@qq.com
 * @LastEditTime   : 24-11-11
 * Version        :
 * @Description    : 
 *                  
 * 
 * Parameter       :
 *                  
 * 
 * IO Port         :
 *                  
 * 
 * Modification History
 *    Date   |   Author   |   Version   |   Change Description
 * ==============================================================================
 *  23-08-24 |     NJU    |     0.1     | Original Version
 *                  
 * 
 */
/*
 * la.c
 *
 *  Created on: Oct 30, 2024
 *      Author: 19226
 */
#include "la.h"

void la_set_data(uint32_t data){
  SYS_RWMEM_W(LA_DATA) = data;
};

void la_set_trgen(uint32_t trgen){
  SYS_RWMEM_W(LA_TRGEN) = trgen;
};

void la_set_chnsel(uint32_t chnsel){
  SYS_RWMEM_W(LA_CHNSEL) = chnsel;
};

void la_set_modesel(uint32_t modesel){
  SYS_RWMEM_W(LA_MODESEL) = modesel;
};

void la_set_freqsel(uint32_t freqsel){
  SYS_RWMEM_W(LA_FREQSEL) = freqsel;
};

void la_set_prenum(uint32_t prenum){
  SYS_RWMEM_W(LA_PRENUM) = prenum;
};

uint32_t la_get_data(){
  return SYS_RWMEM_W(LA_DATA);
};

uint32_t la_get_trgen(){
  return SYS_RWMEM_W(LA_TRGEN);
};

uint32_t la_get_chnsel(){
  return SYS_RWMEM_W(LA_CHNSEL);
};

uint32_t la_get_modesel(){
  return SYS_RWMEM_W(LA_MODESEL);
};

uint32_t la_get_freqsel(){
  return SYS_RWMEM_W(LA_FREQSEL);
};

uint32_t la_get_prenum(){
  return SYS_RWMEM_W(LA_PRENUM);
};

void la_set_uart_en(uint32_t uart_en){
  SYS_RWMEM_W(LA_UART_EN) = uart_en;
};

void la_set_spi_en(uint32_t spi_en){
  SYS_RWMEM_W(LA_SPI_EN) = spi_en;
};

void la_set_interval(uint32_t interval){
  SYS_RWMEM_W(LA_INTERVAL) = interval;
};
