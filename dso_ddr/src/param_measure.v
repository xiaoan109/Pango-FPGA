module param_measure (
  input wire clk,   //!系统时钟50MHz
  input wire rst_n, //!系统复位，低电平有效

  input wire [7:0] trig_level,  //!触发电平

  input wire       ad_clk,  //!ADC时钟
  input wire [7:0] ad_data, //!ADC输入数据

  output wire ad_pulse,  //!pulse_gen模块输出的脉冲信号,仅用于调试

  output wire [19:0] ad_freq,   //!被测时钟频率输出
  output wire [ 7:0] ad_vpp,    //!ADC峰峰值
  output wire [ 7:0] ad_max,    //!ADC最大值
  output wire [ 7:0] ad_min     //!ADC最小值
);

  //parameter define
  parameter CLK_FS = 26'd50_000_000;  // 基准时钟频率值
	
	
  //wire define
  wire clk_fx_buf;
  GTP_CLKBUFR u_GTP_CLKBUFR(
  	.CLKOUT(clk_fx_buf),
  	.CLKIN(ad_pulse)
  );
  //脉冲生成模块
  ad_pulse_gen u_ad_pulse_gen (
    .rst_n(rst_n),  //系统复位，低电平有效

    .trig_level(trig_level),  // 触发电平
    .ad_clk    (ad_clk),      //AD9280驱动时钟
    .ad_data   (ad_data),     //AD输入数据

    .ad_pulse(ad_pulse)  //输出的脉冲信号
  );

  //等精度频率计模块
  freq_measure #(
    .CLK_FS(CLK_FS)  // 基准时钟频率值
  ) u_freq_measure (
    .clk_fs(clk),
    .rst_n (rst_n),

    .clk_fx(clk_fx_buf),  // 被测时钟信号
    .data_fx(ad_freq)  // 被测时钟频率输出
  );

  //计算峰峰值
  vpp_measure u_vpp_measure (
    .rst_n(rst_n),

    .ad_clk  (ad_clk),
    .ad_data (ad_data),
    .ad_pulse(ad_pulse),
    .ad_vpp  (ad_vpp),
    .ad_max  (ad_max),
    .ad_min  (ad_min)
  );

endmodule
