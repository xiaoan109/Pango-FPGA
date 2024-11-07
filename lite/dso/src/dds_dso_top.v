module dds_dso_top (
  input  wire       sys_clk,     // input system clock 50MHz
  input  wire       sys_rst_n,
  output wire       rstn_out,
  output wire       iic_tx_scl,
  inout  wire       iic_tx_sda,
  output wire       led_int,
  //hdmi_out
  output wire       pix_clk,     //pixclk
  output wire       vs_out,
  output wire       hs_out,
  output wire       de_out,
  output wire [7:0] r_out,
  output wire [7:0] g_out,
  output wire [7:0] b_out,

  output wire       ad_clk,
  input  wire [7:0] ad_data,

  input wire [3:0] key,  //输入4位按键

  output wire       da_clk,  //输入DAC模块时钟
  output wire [7:0] da_data  //输入DAC模块波形数据
);

  parameter FREQ_CTRL = 32'd3615292;  //相位累加器单次累加值, 100KHz
  parameter PHASE_CTRL = 12'd0;  //相位偏移量
  parameter CNT_MAX = 20'd999_999;  //计数器计数最大值

  wire [ 3:0] wave_select;
  wire        key_flag;
  wire        locked;

  wire [ 7:0] trig_level;  //触发电平
  wire [ 9:0] deci_rate;  //抽样率
  wire        wave_run;
  wire        trig_edge;
  wire [ 4:0] v_scale;
  wire        fft_en;
  wire        fir_en;
  wire [11:0] trig_line;

  wire [19:0] ad_freq;  //AD脉冲信号的频率 
  wire [ 7:0] ad_vpp;  //AD输入信号峰峰值  
  wire [ 7:0] ad_max;  //AD输入信号最大值  
  wire [ 7:0] ad_min;  //AD输入信号最小值  

  pll u_pll (
    .clkin1  (sys_clk),  //50MHz
    .clkout0 (da_clk),   //118.8MHz
    .clkout1 (ad_clk),   //29.7MHz
    .pll_lock(locked)
  );

  key_control u_key_control (
    .sys_clk  (sys_clk),    //系统时钟,50MHz
    .sys_rst_n(sys_rst_n),  //复位信号,低电平有效
    .key      (key),        //输入4位按键

    .wave_select(wave_select)  //输出波形选择
  );

  dds_top #(
    .FREQ_CTRL (FREQ_CTRL),
    .PHASE_CTRL(PHASE_CTRL)
  ) u_dds_top (
    .sys_clk    (sys_clk),     //系统时钟,50MHz
    .dac_clk    (da_clk),
    .sys_rst_n  (sys_rst_n),   //复位信号,低电平有效
    .wave_select(wave_select), //输出波形选择

    .dac_data(da_data)  //输入DAC模块波形数据
  );


  assign trig_level = 8'd127;
  assign deci_rate = 10'd1;
  assign trig_edge = 1'b1;
  assign v_scale = {1'b1, 4'd2};
  assign wave_run = 1'b1;
  assign fft_en = 1'b0;
  assign fir_en = 1'b0;
  assign trig_line = 12'd512;

  dso_top u_dso_top (
    .sys_clk   (sys_clk),     // input system clock 50MHz
    .sys_rst_n (sys_rst_n),
    .rstn_out  (rstn_out),
    .iic_tx_scl(iic_tx_scl),
    .iic_tx_sda(iic_tx_sda),
    .led_int   (led_int),

    .pix_clk(pix_clk),  //pixclk
    .vs_out (vs_out),
    .hs_out (hs_out),
    .de_out (de_out),
    .r_out  (r_out),
    .g_out  (g_out),
    .b_out  (b_out),

    .ad_clk    (ad_clk),
    .ad_data   (ad_data),
    //ctrl regs
    .trig_level(trig_level),  //触发电平
    .deci_rate (deci_rate),   //抽样率
    .wave_run  (wave_run),
    .trig_edge (trig_edge),
    .v_scale   (v_scale),
    .fft_en    (fft_en),
    .fir_en    (fir_en),
    .trig_line (trig_line),
    //measure regs
    .ad_freq   (ad_freq),     //AD脉冲信号的频率 
    .ad_vpp    (ad_vpp),      //AD输入信号峰峰值  
    .ad_max    (ad_max),      //AD输入信号最大值  
    .ad_min    (ad_min)       //AD输入信号最小值  

  );
endmodule
