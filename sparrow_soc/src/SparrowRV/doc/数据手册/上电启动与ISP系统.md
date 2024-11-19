# 上电启动与ISP系统

## 指令存储器设计
小麻雀处理器的`iram`指令存储器划分为2个空间：`bootrom`  `appram`  
它们共享同一块物理存储器，起始地址0x0000_0000  
`bootrom`位于低地址，通过AXI接口向`bootrom`的任何写操作都无效，存储不可修改的在系统可编程(In-System Programmability, ISP)程序，无需专用编程器，即可通过串口下载用户程序。  
`appram`位于高地址，可以自由读写，存储用户程序。    

## 上电启动方式选择
小麻雀处理器上电后访问固化了ISP程序的`bootrom`区域，通过BOOT0、BOOT1引脚选择小麻雀处理器上电的启动方式。  

|启动方式|BOOT1|BOOT0|
|-|-|-|
|直接启动|0|0|
|读取Flash后启动|0|1|
|串口烧写appram|1|0|
|串口烧写Flash|1|1|

引脚定义如下  
|FPIOA[]|外设|功能|方向|
|-|-|-|-|
|0|UART0_RX|烧录串口UART0 Rx|高阻输入|
|1|UART0_TX|烧录串口UART0 Tx|推挽输出|
|2|GPI0|BOOT0引脚|高阻输入|
|3|GPI1|BOOT1引脚|高阻输入|
|4|SPI0_MISO|对接25Flash DO|高阻输入|
|5|SPI0_MOSI|对接25Flash DI|推挽输出|
|6|SPI0_SCK|对接25Flash CLK|推挽输出|
|7|SPI0_CS|对接25Flash /CS|推挽输出|

![流程图](/sparrow_soc/src/SparrowRV/doc/图库/数据手册/上电isp流程.svg)  

### 直接启动
`bootrom`不进行任何操作  
跳转进入`appram`并启动  

### 读取Flash后启动
读取Flash存储器，并对比SM3杂凑值  
如果SM3杂凑值正确，数据写入`appram`后跳转进入`appram`并启动  
如果SM3杂凑值错误，数据写入`appram`后死循环   

### 串口烧写appram
通过串口向`appram`写入数据  
写入结束后，跳转进入`appram`  

### 串口烧写Flash
通过串口向`appram`写入数据  
写入结束后，若BOOT配置为`2'b11`，将指令和SM3杂凑值写入Flash  
死循环    






