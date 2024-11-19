################################################################################
# MRS Version: 1.9.2
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include lib/startup/subdir.mk
-include lib/perip/src/subdir.mk
-include lib/driver/src/subdir.mk
-include app/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ASM_UPPER_DEPS)),)
-include $(ASM_UPPER_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_FLASH += \
SparrowRV_APP.bin \

SECONDARY_LIST += \
SparrowRV_APP.lst \

SECONDARY_SIZE += \
SparrowRV_APP.siz \


# All Target
all: SparrowRV_APP.elf secondary-outputs

# Tool invocations
SparrowRV_APP.elf: $(OBJS) $(USER_OBJS)
	@	@	riscv-none-embed-gcc -march=rv32em -mabi=ilp32e -msmall-data-limit=8 -mno-save-restore -O1 -fmessage-length=0 -ffunction-sections -fdata-sections -Wunused -Wuninitialized  -g -T "D:\Files\Pango\Pango-FPGA\sparrow_soc\src\SparrowRV\bsp\bsp_app\link.lds" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"SparrowRV_APP.map" --specs=nano.specs --specs=nosys.specs -o "SparrowRV_APP.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@	@
SparrowRV_APP.bin: SparrowRV_APP.elf
	@	riscv-none-embed-objcopy -O binary "SparrowRV_APP.elf"  "SparrowRV_APP.bin"
	@	@
SparrowRV_APP.lst: SparrowRV_APP.elf
	@	riscv-none-embed-objdump --source --all-headers --demangle --line-numbers --wide "SparrowRV_APP.elf" > "SparrowRV_APP.lst"
	@	@
SparrowRV_APP.siz: SparrowRV_APP.elf
	@	riscv-none-embed-size --format=berkeley "SparrowRV_APP.elf"
	@	@
# Other Targets
clean:
	-$(RM) $(ASM_UPPER_DEPS)$(OBJS)$(SECONDARY_FLASH)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_DEPS)$(S_UPPER_DEPS)$(C_DEPS) SparrowRV_APP.elf
	-@
secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

.PHONY: all clean dependents

-include ../makefile.targets
