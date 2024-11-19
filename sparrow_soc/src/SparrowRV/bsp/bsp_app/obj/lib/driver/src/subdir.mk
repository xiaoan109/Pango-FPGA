################################################################################
# MRS Version: 1.9.2
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../lib/driver/src/nor25_flash.c \
../lib/driver/src/printf.c 

OBJS += \
./lib/driver/src/nor25_flash.o \
./lib/driver/src/printf.o 

C_DEPS += \
./lib/driver/src/nor25_flash.d \
./lib/driver/src/printf.d 


# Each subdirectory must supply rules for building sources it contributes
lib/driver/src/%.o: ../lib/driver/src/%.c
	@	@	riscv-none-embed-gcc -march=rv32em -mabi=ilp32e -msmall-data-limit=8 -mno-save-restore -O1 -fmessage-length=0 -ffunction-sections -fdata-sections -Wunused -Wuninitialized  -g -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\app" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib\perip\include" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib\driver\include" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\example\coremark" -std=gnu99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@	@

