#include <stdint.h>
#include <stdbool.h>
#include "spi.h"

void SPI_CS_Enable() {
	reg_spi_cs = 0;
}
void SPI_CS_Disable() {
	reg_spi_cs = 1;
}
void SPI_WriteData(uint8_t data) {
	reg_spi_tx = data;
}
uint8_t SPI_ReadData(){
	return (uint8_t)reg_spi_rx;
}
uint8_t SPI_ReadWrite(uint8_t Txdata){
	uint8_t Rxdata;
	SPI_WriteData(Txdata);
	Rxdata = SPI_ReadData();
	return Rxdata;
}
