#ifndef _SPI_H_
#define _SPI_H_

#include <stdint.h>
#include <stdio.h>


// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.

#define reg_spi_cs   (*(volatile uint32_t*)0x00008040)
#define reg_spi_tx   (*(volatile uint32_t*)0x00008044)
#define reg_spi_rx   (*(volatile uint32_t*)0x00008048)


void SPI_CS_Enable();
void SPI_CS_Disable();
void SPI_WriteData(uint8_t data);
uint8_t SPI_ReadData();
uint8_t SPI_ReadWrite(uint8_t Txdata);

#endif
