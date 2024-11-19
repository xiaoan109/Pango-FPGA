################################################################################
# MRS Version: 1.9.2
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../lib/perip/src/core.c \
../lib/perip/src/ddr.c \
../lib/perip/src/dds.c \
../lib/perip/src/dso.c \
../lib/perip/src/eth.c \
../lib/perip/src/fpioa.c \
../lib/perip/src/la.c \
../lib/perip/src/plic.c \
../lib/perip/src/sdrd.c \
../lib/perip/src/spi.c \
../lib/perip/src/timer.c \
../lib/perip/src/trap.c \
../lib/perip/src/uart.c 

OBJS += \
./lib/perip/src/core.o \
./lib/perip/src/ddr.o \
./lib/perip/src/dds.o \
./lib/perip/src/dso.o \
./lib/perip/src/eth.o \
./lib/perip/src/fpioa.o \
./lib/perip/src/la.o \
./lib/perip/src/plic.o \
./lib/perip/src/sdrd.o \
./lib/perip/src/spi.o \
./lib/perip/src/timer.o \
./lib/perip/src/trap.o \
./lib/perip/src/uart.o 

C_DEPS += \
./lib/perip/src/core.d \
./lib/perip/src/ddr.d \
./lib/perip/src/dds.d \
./lib/perip/src/dso.d \
./lib/perip/src/eth.d \
./lib/perip/src/fpioa.d \
./lib/perip/src/la.d \
./lib/perip/src/plic.d \
./lib/perip/src/sdrd.d \
./lib/perip/src/spi.d \
./lib/perip/src/timer.d \
./lib/perip/src/trap.d \
./lib/perip/src/uart.d 


# Each subdirectory must supply rules for building sources it contributes
lib/perip/src/%.o: ../lib/perip/src/%.c
	@	@	riscv-none-embed-gcc -march=rv32em -mabi=ilp32e -msmall-data-limit=8 -mno-save-restore -O1 -fmessage-length=0 -ffunction-sections -fdata-sections -Wunused -Wuninitialized  -g -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\app" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib\perip\include" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib\driver\include" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\example\coremark" -std=gnu99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@	@

