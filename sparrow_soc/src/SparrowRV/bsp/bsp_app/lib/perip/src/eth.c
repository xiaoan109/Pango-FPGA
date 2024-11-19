/*
 * @FilePath       : \perip\src\eth.c
 * @Author         : zkwang2001 1922601163@qq.com
 * @CreateDate     : 24-11-10
 * @LastEditors    : zkwang2001 1922601163@qq.com
 * @LastEditTime   : 24-11-10
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
 * eth.c
 *
 *  Created on: Nov 10, 2024
 *      Author: 19226
 */

#include "eth.h"

void eth_dds_set_wave(uint32_t data_in){
  SYS_RWMEM_W(ETH_DDS_WAVE_SEL) = data_in;
};

void eth_dds_set_amp(uint32_t data_in){
  SYS_RWMEM_W(ETH_DDS_AMP_CTL) = data_in;
};

void eth_dds_set_freq(uint32_t data_in){
  SYS_RWMEM_W(ETH_DDS_FREQ_CTL) = data_in;
};

void eth_dds_set_min(uint32_t data_in){
  SYS_RWMEM_W(ETH_DDS_MIN_CTL) = data_in;
};

void eth_dds_set_phsae(uint32_t data_in){
  SYS_RWMEM_W(ETH_DDS_PHASE_CTL) = data_in;
};

void eth_dds_en(uint32_t data_in){
  SYS_RWMEM_W(ETH_DDS_CTRL_EN) = data_in;
};


uint32_t eth_dds_get_wave(){
  return SYS_RWMEM_W(ETH_DDS_WAVE_SEL);
};

uint32_t eth_dds_get_amp(){
  return SYS_RWMEM_W(ETH_DDS_AMP_CTL);
};

uint32_t eth_dds_get_freq(){
  return SYS_RWMEM_W(ETH_DDS_FREQ_CTL);
};

uint32_t eth_dds_get_min(){
  return SYS_RWMEM_W(ETH_DDS_MIN_CTL);
};

uint32_t eth_dds_get_phsae(){
  return SYS_RWMEM_W(ETH_DDS_PHASE_CTL);
};

uint32_t eth_dds_get_en(){
  return SYS_RWMEM_W(ETH_DDS_CTRL_EN);
};

