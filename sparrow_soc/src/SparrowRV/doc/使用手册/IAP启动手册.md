# IAP启动手册
## 简介
小麻雀处理器配有相应的的IAP程序，仅需在综合阶段将IAP程序和RTL设计一起固化在FPGA中，即可从外部的SD卡启动应用程序(APP)，无需重复综合流程，提高软件迭代效率。  

## IAP原理
小麻雀处理器只能从核内的iram程序存储器取指，不能从外部存储器启动，因此理论上程序需要在综合阶段和RTL设计一起烧进FPGA，这无疑降低了程序迭代效率。  
IAP是一段按照以上流程固化在FPGA的程序，位于程序存储器的`0x0000-0x03FF`区域，大小为1024字节。处理器上电后，从`0x0000`开始取指，即运行IAP程序。  
IAP程序通过SDRD外设访问SD卡，解析`MBR分区表`和`FAT32文件系统`，一路找到`SparrowRV_APP.bin`文件。  
由于程序存储器的`0x0000-0x03FF`被IAP程序占用，因此`SparrowRV_APP.bin`被复制到起始地址为`0x0400`的区域。内存布局如下所示：  
![IAP内存布局](/doc/图库/数据手册/IAP内存布局.svg)  
复制完成后，PC跳转到`0x0400`，开始运行APP程序。  

## 操作流程
### 固化IAP程序
为了便于使用，编译好的IAP程序位于`/bsp/SparrowRV_IAP.bin`，程序体积经过充分优化，可直接转成`inst.txt`然后参与FPGA综合，流程见[快速开始](/doc/使用手册/快速开始.md)的`FPGA实现`章节。  
在FPGA工程中，需要将`sd_xxx`引脚分配到SD卡对应的IO管脚，让SDRD外设可以正常访问SD卡。如果外部电路没有上拉电阻，需要为`sd_cmd`和`sd_dat[3:0]`设置内部上拉，否则SD卡有概率进入SPI模式，引起启动失败。  

### 重新编译APP程序
`/bsp/bsp_app/`是小麻雀处理器的APP程序工程目录。默认情况下，APP程序的起始地址是`0x0000`，但是IAP启动后APP程序的实际起始地址在`0x0400`，很明显不能正常工作，需要修改链接脚本后重新编译。  
打开`/bsp/bsp_app/link.lds`，第5行：  
```
_use_sd_iap = 0; /*使用SD IAP程序启动，改为 1 */
```
中的0改成1，就能把程序链接的实际起始地址放在`0x0400`，正常参与IAP启动。  
修改后需要重新编译、或清空工程后编译，增量编译可能会出问题。  

### 准备SD卡
IAP程序通过SDRD外设访问SD卡。SDRD外设采用SDIO 1-wire接口(clk,cmd,dat0)，支持各种广义SD卡，如`SD卡`，`TF卡(MicroSD)`，`EMMC`等。而且因为使用SDIO而不是SPI，它的兼容性非常强，支持市面上99.9%的SD卡。  
首先，需要准备一个读卡器，把SD卡连上电脑。  
在文件系统方面，由于IAP功能有限，SD卡必须使用`MBR`分区表，有且仅有一个`FAT32`分区，使用前最好先格式化。  
Win10只能将32G及以上的SD卡格式化为`exFAT`，推荐使用`diskgenius`完成这项工作。流程是：  
- 删除所有分区
- 转换分区表类型为MBR 或 重建主引导记录
- 新建分区FAT32
- 保存更改

完成以上步骤，将重新编译生成的`SparrowRV_APP.bin`复制到SD卡，然后取下，把SD卡插到FPGA上。  
可以参考视频教程[SD卡格式化和IAP启动](https://www.bilibili.com/video/BV1Pj411U7DX/)  

### 启动
IAP程序会将`UART0_TX`分配到`FPIOA[0]`，然后以`115200`波特率通过串口打印信息，可以观察到启动状态。  
首先，FPGA上电后会打印  
```
IAP Wait SD Init...
```
等待IAP启动，如果一直卡在这里就说明有问题。  
若正常启动完成，会打印  
```
IAP Wait SD Init...  Load APP Success
```
若启动后在FAT32分区的根目录找不到文件，则打印  
```
IAP Wait SD Init...  Can't Find File in SD
```


## 遇到问题怎么办？
IAP程序有DEBUG模式，可以在`/bsp/bsp_iap/app/main.c`中启用宏定义`#define IAP_DBG_MODE`，就能在IAP的每一步显示关键信息。  
修改`/bsp/bsp_iap/link.lds`的`_iram_iap_size = 1024 ;`，改到和程序存储器一样大，否则DEBUG程序塞不进1024字节。  

