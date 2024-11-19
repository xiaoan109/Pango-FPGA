# FPGA综合手册
小麻雀处理器是一个可综合的开源处理器，RTL设计符合Verilog-2001标准，具备良好的可移植性。小麻雀SoC的典型配置大约消耗8k逻辑资源，最小配置可以塞进高云GW1N-LV9，逻辑资源20k以上的FPGA将非常宽裕。  
想要在FPGA上跑，需要在相应厂商的FPGA工程中妥善安排Verilog源代码、Verilog头文件、约束文件。以下章节将分析各个文件的功能，给出建立FPGA工程的指导性建议与关键操作。若有自建FPGA工程或修改示例工程的需求，请仔细阅读本手册。  
理论上，小麻雀处理器可以在任意ASIC/FPGA平台上综合。但是，由于部分综合器的功能不够完备，可能会发生奇奇怪怪的错误，最后一章将解答一些常见问题。  

## Verilog源码
小麻雀处理器的RTL设计源码都在`/rtl/`文件夹中，包含了Verilog源代码和头文件。  

### Verilog源代码
源代码目录结构及模块功能如下所示  
```
rtl
├── config.v   头文件，参数配置文件
├── defines.v   头文件，全局宏定义文件
├── core   处理器内核
│   ├── core.v   内核顶层
│   ├── csr.v   CSR相关
│   ├── div.v   除法器
│   ├── dpram.v   程序存储器建模
│   ├── idex.v   指令译码和执行
│   ├── iram.v   程序存储器iram顶层
│   ├── regs.v   GPR通用寄存器组
│   ├── sctr.v   内核状态集中控制
│   └── trap.v   陷阱(异常+中断)相关
├── jtag   JTAG调试
│   ├── jtag_top.v   JTAG顶层
│   ├── jtag_driver.v   JTAG调试传输模块DTM
│   ├── jtag_dm.v   JTAG调试模块DM
│   ├── full_handshake_tx.v   JTAG跨时钟域
│   └── full_handshake_rx.v   JTAG跨时钟域
└── soc   SoC系统
    ├── sparrow_soc.v   小麻雀SoC顶层文件
    ├── icb_2m8s.v   2主8从ICB总线
    ├── plic.v   PLIC平台级中断控制器
    ├── rstc.v   复位控制
    ├── sram.v   数据存储器sram
    ├── sdrd   SD读卡器
    │   ├── sdcmd_ctrl.v   控制器
    │   ├── sdrd.v   顶层总线交互
    │   └── sd_reader.v   读扇区
    └── sys_perip   系统外设
        ├── fpioa.v   现场可编程IO阵列
        ├── spi.v   SPI
        ├── sys_perip.v   系统外设顶层
        ├── timer.v   定时器
        └── uart.v   串口
```
#### 顶层文件
其中，`sparrow_soc.v`是小麻雀SoC的顶层文件，即`sparrow_soc`是小麻雀SoC的顶层模块。    
顶层接口说明如下：  
|接口|方向|位宽|功能|
|-|-|-|-|
|clk|输入|1|时钟输入|
|hard_rst_n|输入|1|低电平复位引脚|
|core_active|输出|1|活动状态指示，建议接LED|
|JTAG_XXX|-|4|JTAG接口，与调试器的同名接口相连|
|sd_clk|输出|1|SD卡的clk|
|sd_cmd|双向|1|SD卡的cmd|
|sd_dat|输入|4|SD卡的数据线|
|fpioa|双向|可变|现场可编程IO阵列|

其中，`config.v`的`CPU_CLOCK_HZ`必须修改为`clk`引脚的输入时钟频率。`sd_dat`的位宽为4，实际上仅sd_dat[0]有效。  

#### 读入程序
`/rtl/core/dpram.v`的最下面  
```
initial begin
    $readmemh (`PROG_FPGA_PATH, BRAM);
end
```
用于读入程序。  
`PROG_FPGA_PATH`在`config.h`中指定为`inst.txt`的路径，在FPGA逻辑综合阶段读入。烧录比特流文件后，FPGA中对应的程序存储器RAM会初始化为`inst.txt`的数据。  

### Verilog头文件
在RTL设计中，头文件`config.v`、`defines.v`分别有不同的功能。  
**config.v**用于参数化配置小麻雀处理器的各项功能，实现弹性化设计，具体内容见[系统配置选项](/doc/使用手册/系统配置选项.md)。  
**defines.v**向全局Verilog源码提供通用的宏定义，并且内部`include`了`config.v`，不建议修改其内容。  

## 约束文件
小麻雀处理器存在2个时钟域  
1. 系统主时钟域`clk`  
2. JTAG模块时钟域`jtag_clk`  
`clk`和`jtag_clk`是异步的，以下约束信息必不可少：  
```
create_clock -period 30 -name clk [get_ports {clk}]
create_clock -period 100 -name jtag_clk [get_ports {JTAG_TCK}]
set_clock_groups -asynchronous -group [get_clocks {clk}] -group [get_clocks {jtag_clk}]
```
第1行，`-period 30`中，`20`指的是系统主时钟的周期，请根据具体硬件平台作出调整。  
第2行，`-period 100`中，`100`指的是JTAG接口`TCK`的时钟周期，一般不会超过10MHz。  
第3行，创建时钟组，声明`clk`和`jtag_clk`是异步的，不进行跨时钟域分析。  
时钟周期是频率的倒数  

若系统主时钟来源于PLL，时钟约束方式请自行探索。  

对于AMD 7系列 FPGA，如果`TCK`连接于普通IO管脚，需要加入以下布局约束：  
```
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets JTAG_TCK_IBUF]
```
强制忽略`JTAG_TCK`的布线错误，并变为警告。  

## FPGA综合流程
这里提供的是一般的FPGA工作流，具体操作方式见具体平台的使用手册  
1. 建立工程  
首先，需要新建一个FPGA工程  

2. 添加源文件  
将`/rtl/`及其子文件夹内所有`*.v`文件加入工程  

3. 设置include路径  
在FPGA工程的设置中，一般会有一个verilog include路径选项，`include`的文件都会从这里查找。在这个选项中添加`/rtl/`文件夹的路径。  

4. 修改config.v  
具体内容请参阅[系统配置选项](/doc/使用手册/系统配置选项.md)    
`CPU_CLOCK_HZ`必须修改为处理器运行的频率  
如果自建工程，需将`/rtl/config.h`的`PROG_FPGA_PATH`宏定义内容改为`inst.txt`的文件路径，通过`readmemh`将程序写进FPGA。  

5. 添加时钟约束文件  
新建一个空白的约束文件，然后写3条约束，具体内容查看章节[约束文件](##约束文件)  

6. IO约束  
根据你的硬件，合理分配IO管脚布局。  

7. FPGA工作流
逻辑综合(Synthesize)，布局(Place)，布线(Route)，生成比特流文件(Gen bitstream)，烧录  

## 板级调试
`core_active`建议接到LED灯上，只要在闪就表明程序在运行。  
默认情况下，C语言的printf通过`fpioa[0]`以`115200`波特率的串口形式输出。通过`CH343`等USB转串口工具可以读取。  
同时引出了JTAG接口，支持`CH347` `DAPLink`等调试器。  
`fpioa`可以接各种各样的外围电路。  

## 常见问题
**为什么LUT消耗得太多，FPGA资源不够报错？**  
正常情况下，小麻雀处理器需要消耗不大于10k的LUT资源，如果超得太多，可能是程序存储器综合失败了，主要原因如下：  
为了提高可移植性，程序存储器使用Verilog行为级建模，由综合器推断出等效的RAM硬核，而不是手动调用。但是，由于程序存储器需要有双端口和字节写使能，反而导致部分综合器不支持这种操作，内部的RAM硬核即使功能支持也用不上，强行将程序存储器综合成LUTRAM，消耗巨量的逻辑资源。  
本人测试了部分FPGA厂商的兼容性，欢迎大家补充。      
|厂商|软件|版本|支持情况|
|---|---|---|---|
|高云|Gowin|V1.9.8.09教育版|完美支持|
|AMD|Vivado|2019.2|完美支持|
|智多晶|HqFPGA|3.0.0|理论上支持|
|紫光同创|Pango Design Suite|2021.4-SP1.2|综合出双倍数量的伪双端RAM|
|安路|TD|5.6.1|不支持RAM，支持ROM配置|
|Lattice|Diamond|3.12|综合器崩溃，真的太逊了|
|Intel|Quartus|18.1|完美支持|

不支持或存在问题不代表不能用，而是需要手动建立IP核，通过初始化文件导入程序，具体配置方式见`/rtl/core/dpram.v`  

**为什么综合器报错找不到define.v/config.v？**  
`/rtl/defien.v`和`/rtl/config.v`是头文件，通过`include`导入，需要独立设置，仅仅加入工程文件是不行的。一般来说，在FPGA工程设置中，会有一个include路径选项，在这里添加`rtl`文件夹的路径就行了。  

**我使用Vivado，在impl阶段报错了？**  
或许是因为`JTAG_TCK`没有分配在时钟专用管脚上，Vivado不许这样做。加入约束：  
```
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets JTAG_TCK_IBUF]
```
强制忽略此错误，并变为警告。  

**我怎么知道程序有没有在运行？**  
建议将`core_active`管脚接到外置LED灯。如果程序正常运行，LED将以肉眼可见的频率闪烁。  

