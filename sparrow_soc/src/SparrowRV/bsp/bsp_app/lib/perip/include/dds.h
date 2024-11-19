#ifndef _DDS_H_
#define _DDS_H_

#include "system.h"

#define DDS_SLAVE_4        4
#define DDS_BASE          (DDS_SLAVE_4 * 0x20000000u)

#define DDS_AMP       (DDS_BASE + (0x00))
#define DDS_FREQ      (DDS_BASE + (0x04))
#define DDS_MIN       (DDS_BASE + (0x08))
#define DDS_PHASE     (DDS_BASE + (0x0c))
#define DDS_TYPE      (DDS_BASE + (0x10))

void dds_set_amp(uint32_t amp); // 幅值
void dds_set_freq(uint32_t freq); // 频率
void dds_set_min(uint32_t min); // 最小分辨率
void dds_set_phase(uint32_t phase); // 相位
void dds_get_state(uint32_t *amp, uint32_t *freq, uint32_t *min, uint32_t *phase, uint32_t *type); // 获取状态
void dds_wavetype(uint32_t type);
#endif
