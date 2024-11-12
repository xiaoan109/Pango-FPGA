/*
 * @FilePath       : \perip\src\dso.c
 * @Author         : zkwang2001 1922601163@qq.com
 * @CreateDate     : 24-10-28
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
 * dso.c
 *
 *  Created on: Oct 28, 2024
 *      Author: 19226
 */
#include "dso.h"

void dso_set_trig_level(uint32_t trig_level){
  SYS_RWMEM_W(DSO_TRIG_LEVEL) = trig_level;
};

void dso_set_deci_rate(uint32_t deci_rate){
  SYS_RWMEM_W(DSO_DECI_RATE) = deci_rate;
};

void dso_set_wave_run(uint32_t wave_run){
  SYS_RWMEM_W(DSO_WAVE_RUN) = wave_run;
};

void dso_set_trig_edge(uint32_t trig_edge){
  SYS_RWMEM_W(DSO_TRIG_EDGE) = trig_edge;
};

void dso_set_v_scale(uint32_t v_scale){
  SYS_RWMEM_W(DSO_V_SCALE) = v_scale;
};

void dso_set_fft_en(uint32_t fft_en){
  SYS_RWMEM_W(DSO_FFT_EN) = fft_en;
};

uint32_t dso_get_freq(){
  return SYS_RWMEM_W(DSO_FREQ);
};

uint32_t dso_get_vpp(){
  return SYS_RWMEM_W(DSO_VPP);
};

uint32_t dso_get_max(){
  return SYS_RWMEM_W(DSO_MAX);
};

uint32_t dso_get_min(){
  return SYS_RWMEM_W(DSO_MIN);
};

void dso_set_fir_en(uint32_t fir_en){
  SYS_RWMEM_W(DSO_FIR_EN) = fir_en;
};

void dso_set_trig_line(uint32_t trig_line){
  SYS_RWMEM_W(DSO_TRIG_LINE) = trig_line;
};

