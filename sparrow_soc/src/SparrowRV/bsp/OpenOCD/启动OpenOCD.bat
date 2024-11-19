@chcp 65001
:cmsl
@echo ===============================
@echo 输入编号并回车，选择相应的调试器并启动OpenOCD
@echo 0: 调试器支持列表
@echo 1: CMSISI DAP v1
@echo 2: CMSISI DAP v2
@echo 3: CH347
@echo 4: J-Link(未测试)
@echo 5: 保留
@echo ===============================

@set /p cmchc=输入命令编号： 

@if %cmchc% == 0 (openocd.exe -f openocd.cfg)^
else if %cmchc% == 1 (openocd.exe -f SparrowRV_cmsis-dap-v1.cfg)^
else if %cmchc% == 2 (openocd.exe -f SparrowRV_cmsis-dap-v2.cfg)^
else if %cmchc% == 3 (openocd.exe -f SparrowRV_ch347.cfg)^
else if %cmchc% == 4 (openocd.exe -f SparrowRV_jlink.cfg)^
else if %cmchc% == 5 (goto cmsl)^
else (echo Err 0: 命令未找到)
goto cmsl

pause