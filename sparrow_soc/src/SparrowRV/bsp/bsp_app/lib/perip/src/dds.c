/*
 * @FilePath       : \bsp\bsp_app\lib\perip\src\dds.c
 * @Author         : zkwang2001 1922601163@qq.com
 * @CreateDate     : 24-10-24
 * @LastEditors    : zkwang2001 1922601163@qq.com
 * @LastEditTime   : 24-10-24
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
 * dds.c
 *
 *  Created on: Oct 24, 2024
 *      Author: 19226
 */
#include "dds.h"

void dds_set_amp(uint32_t amp){
  SYS_RWMEM_W(DDS_AMP) = amp;
};

void dds_set_freq(uint32_t freq){
  SYS_RWMEM_W(DDS_FREQ) = freq;
};

void dds_set_min(uint32_t min){
  SYS_RWMEM_W(DDS_MIN) = min;
};

void dds_set_phase(uint32_t phase){
  SYS_RWMEM_W(DDS_PHASE) = phase;
};

void dds_wavetype(uint32_t type){
  SYS_RWMEM_W(DDS_TYPE) = type;
};

void dds_get_state(uint32_t *amp, uint32_t *freq, uint32_t *min, uint32_t *phase, uint32_t *type){
  *amp = SYS_RWMEM_W(DDS_AMP);
  *freq = SYS_RWMEM_W(DDS_FREQ);
  *min = SYS_RWMEM_W(DDS_MIN);
  *phase = SYS_RWMEM_W(DDS_PHASE);
  *type = SYS_RWMEM_W(DDS_TYPE);
};
