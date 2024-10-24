### lite版本的dso示波器工程（工程的顶层是dds和dso的通路测试，这是因为方便自测不需要外部的信号发生器，集成到CPU时只例化dso_top.v即可）
### 内部IP：fifo、ram、rom和pll，应该可以直接导入的其他工程里
### 约束文件：集成可以只保留hdmi相关的接口(rgb，vs，hs，de，i2c，pix_clk，rstn_out)和ADC的接口（ad_clk和ad_data），dac相关的约束应该原先cpu+dds时就绑定了，按键同样。

### 寄存器概述：
#### 控制寄存器:
0x0 trig_level   [7:0] 触发电平 （0-255）

0x4 deci_rate   [9:0] 抽样率 （当dac产生的波形频率为100KHz时，可以设置为1，只影响显示，其余频率可以自行调整）

0x8 wave_run  [0:0] 波形显示停止（1运行0停止）

0xc trig_edge  [0:0] 触发沿（1上升0下降）

0x10 v_scale    [4:0] 垂直缩放（v_scale[4]表示放大(1)或缩小(0)，v_scale[3:0]表示倍数，最好控制为1/2/4）

0x14 fft_en      [0:0] fft开启（1开启0关闭）

#### 测量参数读取寄存器
0x18 ad_freq   [19:0] 频率

0x1c ad_vpp    [7:0]  峰峰值

0x20 ad_max   [7:0]  最大值

0x24 ad_min    [7:0]  最小值
