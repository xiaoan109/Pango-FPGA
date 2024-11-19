################################################################################
# MRS Version: 1.9.2
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../lib/startup/init.c 

S_UPPER_SRCS += \
../lib/startup/startup.S 

OBJS += \
./lib/startup/init.o \
./lib/startup/startup.o 

S_UPPER_DEPS += \
./lib/startup/startup.d 

C_DEPS += \
./lib/startup/init.d 


# Each subdirectory must supply rules for building sources it contributes
lib/startup/%.o: ../lib/startup/%.c
	@	@	riscv-none-embed-gcc -march=rv32em -mabi=ilp32e -msmall-data-limit=8 -mno-save-restore -O1 -fmessage-length=0 -ffunction-sections -fdata-sections -Wunused -Wuninitialized  -g -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\app" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib\perip\include" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib\driver\include" -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\example\coremark" -std=gnu99 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@	@
lib/startup/%.o: ../lib/startup/%.S
	@	@	riscv-none-embed-gcc -march=rv32em -mabi=ilp32e -msmall-data-limit=8 -mno-save-restore -O1 -fmessage-length=0 -ffunction-sections -fdata-sections -Wunused -Wuninitialized  -g -x assembler-with-cpp -I"D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\lib\startup" -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o "$@" "$<"
	@	@

