# OpenOCD常见操作

### 启动OpenOCD
进入`OpenOCD/bin/`文件夹  
双击`启动XXX调试.bat`，实际上执行了一条命令  
```
openocd.exe -f SparrowRV_XXX.cfg
```
OpenOCD使用相应的调试器连接小麻雀处理器  

启动后若显示如下信息，表明连接成功  
```
Info : JTAG tap: riscv.cpu tap/device found: 0x1e200a6f (mfg: 0x537 (Wuhan Xun Zhan Electronic Technology), part: 0xe200, ver: 0x1)
Info : [riscv.cpu] datacount=3 progbufsize=1
Error: [riscv.cpu] Hart is not halted!
Info : [riscv.cpu] Examined RISC-V core; found 2 harts
Info : [riscv.cpu]  XLEN=32, misa=0x0
[riscv.cpu] Target successfully examined.
Info : starting gdb server for riscv.cpu on 3333
Info : Listening on port 3333 for gdb connections
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
```

若包含如下错误信息，可能是config.h中没有启用JTAG，或者JTAG引脚分配错误、连线错误  
```
Error: JTAG scan chain interrogation failed: all ones
Error: Check JTAG interface, timings, target power, etc.
Error: Trying to use configured scan chain anyway...
Error: riscv.cpu: IR capture error; saw 0x1f not 0x01
Warn : Bypassing JTAG setup events due to errors
Error: [riscv.cpu] Unsupported DTM version: 15
```

### 进入命令交互界面
打开CMD，执行`telnet localhost 4444`  

### 常见命令
`halt`停住内核  
`reset`复位  
`mdw 地址 [长度]`从指定地址读取32bit数据，可指定读取长度  
`load_image 文件名 起始地址 文件类型(bin,ihex,elf,s19) 最小地址 最大长度`加载镜像  
`verify_image 文件名 起始地址`校验镜像  
