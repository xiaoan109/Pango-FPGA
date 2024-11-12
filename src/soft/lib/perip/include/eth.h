/*
 * eth.h
 *
 *  Created on: Nov 10, 2024
 *      Author: 19226
 */

#ifndef LIB_PERIP_INCLUDE_ETH_H_
#define LIB_PERIP_INCLUDE_ETH_H_
#include "system.h"

#define ETH_SLAVE_5        5
#define ETH_BASE          (ETH_SLAVE_5 * 0x20000000u)

#define ETH_DDS_WAVE_SEL        (ETH_BASE + (0x00))
#define ETH_DDS_AMP_CTL         (ETH_BASE + (0x04))
#define ETH_DDS_FREQ_CTL        (ETH_BASE + (0x08))
#define ETH_DDS_MIN_CTL         (ETH_BASE + (0x0c))
#define ETH_DDS_PHASE_CTL       (ETH_BASE + (0x10))
#define ETH_DDS_CTRL_EN         (ETH_BASE + (0x14))


#endif /* LIB_PERIP_INCLUDE_ETH_H_ */
