module dso_top (
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
  input  wire [7:0] ad_data
  //   input  wire [ 7:0] trig_level,  //触发电平
  //   input  wire [ 7:0] trig_line,   //触发线位置
  //   input  wire        trig_edge,   //触发边沿
  //   input  wire [ 9:0] deci_rate,   //抽样率
  //   input  wire        wave_run,    //波形采集运行/停止
  //   input  wire [ 9:0] h_shift,     //波形水平偏移量
  //   input  wire [ 9:0] v_shift,     //波形竖直偏移量
  //   input  wire [ 4:0] v_scale,     //波形竖直缩放比例
  //   input  wire [ 8:0] pixel_xpos,     //像素点横坐标
  //   input  wire [ 8:0] pixel_ypos,     //像素点纵坐标
  //   input  wire [23:0] ui_pixel_data,
  //   output wire [19:0] ad_freq,     //AD脉冲信号的频率
  //   output wire [ 7:0] ad_vpp,      //AD输入信号峰峰值
  //   output wire [ 7:0] ad_max,      //AD输入信号最大值
  //   output wire [ 7:0] ad_min       //AD输入信号最小值
  //   output wire [23:0] pixel_data
);

  parameter X_WIDTH = 4'd12;
  parameter Y_WIDTH = 4'd12;

  wire               locked;
  wire [X_WIDTH-1:0] act_x  /*synthesis PAP_MARK_DEBUG="true"*/;
  wire [Y_WIDTH-1:0] act_y  /*synthesis PAP_MARK_DEBUG="true"*/;
  wire [       23:0] ui_pixel_data;
  wire [       23:0] pixel_data;

  wire [        7:0] trig_level;  //触发电平
  wire [        7:0] trig_line;  //触发线位置
  wire               trig_edge;  //触发边沿
  wire [        9:0] deci_rate;  //抽样率
  wire               wave_run;  //波形采集运行/停止
  wire [        9:0] h_shift;  //波形水平偏移量
  wire [        9:0] v_shift;  //波形竖直偏移量
  wire [        4:0] v_scale;  //波形竖直缩放比例

  wire [       19:0] ad_freq  /*synthesis PAP_MARK_DEBUG="true"*/;  //AD脉冲信号的频率 
  wire [        7:0] ad_vpp  /*synthesis PAP_MARK_DEBUG="true"*/;  //AD输入信号峰峰值  
  wire [        7:0] ad_max  /*synthesis PAP_MARK_DEBUG="true"*/;  //AD输入信号最大值  
  wire [        7:0] ad_min  /*synthesis PAP_MARK_DEBUG="true"*/;  //AD输入信号最小值  

  assign ui_pixel_data = 24'h000000;
  assign trig_level = 8'd128;
  assign trig_line = 8'd100;
  assign trig_edge = 1'b1;
  assign deci_rate = 10'd1;
  assign wave_run = 1'b1;
  assign h_shift = 10'd0;
  assign v_shift = {1'b1, 9'd200};
  assign v_scale = {1'b1, 4'd2};

  pll u_pll (
    .clkin1  (sys_clk),  //50MHz
    .clkout0 (ad_clk),   //35MHz
    .pll_lock(locked)
  );

  wave_top u_wave_top (
    .clk_50m      (sys_clk),
    .hdmi_pclk    (pix_clk),
    .ad_clk       (ad_clk),
    .rst_n        (sys_rst_n),
    .ad_data      (ad_data),
    .trig_level   (trig_level),     //触发电平
    .trig_line    (trig_line),      //触发线位置
    .trig_edge    (trig_edge),      //触发边沿
    .deci_rate    (deci_rate),      //抽样率
    .wave_run     (wave_run),       //波形采集运行/停止
    .h_shift      (h_shift),        //波形水平偏移量
    .v_shift      (v_shift),        //波形竖直偏移量
    .v_scale      (v_scale),        //波形竖直缩放比例
    .pixel_xpos   (act_x),          //像素点横坐标
    .pixel_ypos   (act_y),          //像素点纵坐标
    .ui_pixel_data(ui_pixel_data),
    .ad_freq      (ad_freq),        //AD脉冲信号的频率
    .ad_vpp       (ad_vpp),         //AD输入信号峰峰值
    .ad_max       (ad_max),         //AD输入信号最大值
    .ad_min       (ad_min),         //AD输入信号最小值
    .pixel_data   (pixel_data)
  );



  hdmi_top u_hdmi_top (
    .sys_clk   (sys_clk),     // input system clock 50MHz
    .rstn_out  (rstn_out),
    .iic_tx_scl(iic_tx_scl),
    .iic_tx_sda(iic_tx_sda),
    .led_int   (led_int),
    .pixel_data(pixel_data),
    //hdmi_out
    .pix_clk   (pix_clk),     //pixclk
    .act_x     (act_x),
    .act_y     (act_y),
    .vs_out    (vs_out),
    .hs_out    (hs_out),
    .de_out    (de_out),
    .r_out     (r_out),
    .g_out     (g_out),
    .b_out     (b_out)

  );
endmodule
