#ifndef _SPI_H_
#define _SPI_H_
#include "system.h"

#define ICB_SLAVE_2          2
#define SYSIO_BASE           (ICB_SLAVE_2 * 0x20000000u)
#define SPI_BASE             (SYSIO_BASE + (0x200))
#define SPI0_BASE            (SPI_BASE  + (0x000))

#define SPI_CTRL(SPIx)       (SPIx + (0x00))
#define SPI_DATA(SPIx)       (SPIx + (0x04))
#define SPI_STATUS(SPIx)     (SPIx + (0x08))

#define SPI_CP_MODEL_0 0b0000u //CPOL = 0, CPHA = 0
#define SPI_CP_MODEL_1 0b0100u //CPOL = 0, CPHA = 1
#define SPI_CP_MODEL_2 0b0010u //CPOL = 1, CPHA = 0
#define SPI_CP_MODEL_3 0b0110u //CPOL = 1, CPHA = 1

#define SPI0 SPI0_BASE


void spi_cp_model(uint32_t SPIx, uint8_t spi_cpmodel);//SPI相位控制
void spi_sclk_div(uint32_t SPIx, uint32_t spi_div);//SPI SCLK分频器配置
void spi_set_cs(uint32_t SPIx, uint32_t spi_cs);//SPI CS片选信号控制
void spi_send_byte(uint32_t SPIx, uint32_t data);//SPI发送字节，发完不管
uint8_t spi_sdrv_byte(uint32_t SPIx, uint32_t data);//SPI发送1字节接收1字节
uint32_t spi_busy_chk(uint32_t SPIx);//SPI状态检查
void spi_send_bytes(uint32_t SPIx, uint8_t data[], uint32_t len);
void spi_read_bytes(uint32_t SPIx, uint8_t data[], uint32_t len);
void spi_irq_ctrl(uint32_t SPIx, uint32_t spi_irq_en);

#endif
