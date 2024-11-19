/***
 * @FilePath       : \perip\include\dso.h
 * @Author         : zkwang2001 1922601163@qq.com
 * @CreateDate     : 24-10-27
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
 * dso.h
 *
 *  Created on: Oct 27, 2024
 *      Author: 19226
 */

#ifndef LIB_PERIP_INCLUDE_DSO_H_
#define LIB_PERIP_INCLUDE_DSO_H_
#include "system.h"

#define DSO_SLAVE_6        6
#define DSO_BASE          (DSO_SLAVE_6 * 0x20000000u)

#define DSO_TRIG_LEVEL       (DSO_BASE + (0x00))
#define DSO_DECI_RATE        (DSO_BASE + (0x04))
#define DSO_WAVE_RUN         (DSO_BASE + (0x08))
#define DSO_TRIG_EDGE        (DSO_BASE + (0x0c))
#define DSO_V_SCALE          (DSO_BASE + (0x10))
#define DSO_FFT_EN           (DSO_BASE + (0x14))  

#define DSO_FREQ             (DSO_BASE + (0x18))
#define DSO_VPP              (DSO_BASE + (0x1c))
#define DSO_MAX              (DSO_BASE + (0x20))
#define DSO_MIN              (DSO_BASE + (0x24))

#define DSO_FIR_EN           (DSO_BASE + (0x28))
#define DSO_TRIG_LINE        (DSO_BASE + (0x2c))

void dso_set_trig_level(uint32_t trig_level); // 触发电平
void dso_set_deci_rate(uint32_t deci_rate); // 降采样率
void dso_set_wave_run(uint32_t wave_run); // 波形运行
void dso_set_trig_edge(uint32_t trig_edge); // 触发边沿
void dso_set_v_scale(uint32_t v_scale); // 电压刻度
void dso_set_fft_en(uint32_t fft_en); // FFT使能

uint32_t dso_get_freq(); // 获取频率
uint32_t dso_get_vpp(); // 获取峰峰值
uint32_t dso_get_max(); // 获取最大值
uint32_t dso_get_min(); // 获取最小值

void dso_set_fir_en(uint32_t fir_en);
void dso_set_trig_line(uint32_t trig_line);



#endif /* LIB_PERIP_INCLUDE_DSO_H_ */
