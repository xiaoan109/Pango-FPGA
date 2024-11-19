# 小麻雀处理器
[![rvlogo](/doc/图库/Readme/rvlogo.bmp)RISC-V官网收录](https://riscv.org/exchange/?_sf_s=sparrowrv)  
[![teelogo](/doc/图库/Readme/giteetj.bmp)Gitee推荐项目](https://gitee.com/explore/risc-v)  
[![book](/doc/图库/Readme/book.png)处理器文档导航页](/doc/文档导航.md)  


## 简介
小麻雀处理器(SparrowRV)是一个开源处理器项目，包含了RISC-V处理器内核及SoC设计，用于C语言开发的板级支持包BSP，易上手的软硬件联合仿真环境等内容。  
小麻雀处理器面向于低功耗、小面积的应用场景，对标Cortex-M系列内核。它使用可综合的Verilog语言完成SoC的RTL设计，代码注释完备，提供了详细的说明文档，可以快速移植到任意FPGA平台进行工程开发，适合用于研究和学习。  

**设计指标：**  
- 顺序两级流水线结构(IF -> ID+EX+MEM+WB)  
- 支持可配置的RV32I/E/M/Zicsr指令集组合及机器模式  
- 向量中断系统，PLIC接管外部中断  
- 哈佛结构，指令存储器映射至存储器空间  
- 支持C语言开发，配有BSP及相关例程  
- 配有SoC实现方案，包含ICB总线和常用外设  
- 支持JTAG接口，实现了RISC-V调试规范0.13.2的子集  
- 参数化配置，设计具备极强的伸缩性  

**系统功能框图**  
![soc架构](/doc/图库/Readme/soc架构.svg)  

详细内容及使用教程请参阅[**处理器文档导航页**](/doc/文档导航.md)  

## 工程组织框架
小麻雀处理器包含了RTL、软件、硬件设计。  
![组织框架](/doc/图库/Readme/工程结构.svg)  
- SoC RTL设计由硬件描述语言HDL完成，实现了小麻雀内核及配套的总线系统和常用外设。  
- 软件设计包含了BSP、相关例程及IAP程序，实现了C语言开发，使用固件库封装了底层硬件操作。  
- 硬件设计包含了FPGA例程和参考设计，指导使用者将小麻雀处理器放在FPGA上运行。  
- 脚本工具贯穿了小麻雀处理器的每一处细节，实现了逻辑仿真、数据转换、自测试等功能。  


**主要工具**  
- 处理器的RTL设计采用Verilog-2001的可综合子集。此版本代码密度更高，可读性更强，并且受到综合器的广泛支持。  
- 处理器的TestBench采用System Verilog-2005。此版本充分满足仿真需求，并且受到仿真器的广泛支持。  
- 逻辑仿真采用iverilog/Modelsim。可根据使用平台与具体需求选择合适工具。  
- 脚本采用 批处理(Win)/Makefile(跨平台) + Python3。发挥各种脚本语言的优势，最大程度地简化操作。  
- BSP采用MRS(MounRiver Studio)图形化集成开发环境，开箱即用。  
- 所有文本采用UTF-8编码，具备良好的多语言和跨平台支持。  

**目录结构说明**  
```
SparrowRV根目录
  ├─bsp  板级支持包
  |  ├─bsp_app  编写程序所需的BSP
  |  ├─bsp_iap  实现SD卡IAP启动的工程
  |  ├─OpenOCD  OpenOCD上位机
  |  ├─readme.md  说明文件
  |  └─SparrowRV_IAP.bin  SD卡IAP程序的二进制文件
  ├─doc  所有文档都在这里
  ├─fpga  FPGA示例工程
  ├─rtl  RTL设计
  └─tb  各种工具、仿真脚本、仿真激励
```

## 致谢
本项目借鉴了[tinyriscv](https://gitee.com/liangkangnan/tinyriscv)的RTL设计和Python脚本。tinyriscv使用[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)协议。  
本项目使用了[printf](https://github.com/mpaland/printf)的轻量化printf实现。printf使用MIT协议。  
本项目使用了[蜂鸟E203](https://gitee.com/riscv-mcu/e203_hbirdv2)的ICB总线。蜂鸟E203使用[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)协议。  
本项目使用了[FPGA-SDcard-Reader](https://github.com/WangXuan95/FPGA-SDcard-Reader)的SD卡按扇区读取功能。  
感谢先驱者为我们提供的灵感  
感谢李轻水@a1579472700帮助我发现了致命错误  
感谢众多开源软件提供的好用的工具  
感谢MRS开发工具提供的便利   
感谢导师对我学习方向的支持和理解  
大家的支持是我前进的动力  

有任何的意见、建议、疑问，可以在issue中提出，我会尽快回复  
