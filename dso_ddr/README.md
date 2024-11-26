## DDR相关
### 1. 重点关注src/dso_top.v里面对DDR的操作
相关模块在src/ddr/wr_driver, src/ddr/ddr3_wr_ctrl, src/ddr/rd_driver和src/ddr/ddr3_rd_ctrl，其他文件按需要添加即可。这四个是核心的读写模块，其中ddr3_wr(rd)_ctrl基本无需修改（burst长度可以改），两个模块内部分别有fifo和ram。用户重点操作wr_driver的输入data和valid，以及rd_driver的ram读地址和数据即可。两个模块之间有一个传递触发地址的逻辑，在dso_top里可以看到（CDC+边缘检测），不过这个地址可能并不完全准确。

### 2. 使用注意添加所需的ipcore（在pnr/ipcore下，可以复制）

### 3. DDR相关端口说明
用户逻辑->AXI4->DDR native接口->开发板约束引脚
如果多个模块要使用ddr，可以只暴露到AXI4而不是像我所示的native接口（后面AXI再做MUX），如果只有一个模块使用DDR则可以类似dso_top那样操作。