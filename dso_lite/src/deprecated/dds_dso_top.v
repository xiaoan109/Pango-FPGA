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

  parameter FREQ_CTRL = 32'd8589934,  //相位累加器单次累加值
  PHASE_CTRL = 12'd0;  //相位偏移量

  dds_top #(
    .FREQ_CTRL (FREQ_CTRL),
    .PHASE_CTRL(PHASE_CTRL)
  ) u_dds_top (
    .sys_clk  (sys_clk),    //系统时钟,50MHz
    .sys_rst_n(sys_rst_n),  //复位信号,低电平有效
    .key      (key),        //输入4位按键

    .dac_clk (da_clk),  //输入DAC模块时钟
    .dac_data(da_data)  //输入DAC模块波形数据
  );

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

    .ad_clk (ad_clk),
    .ad_data(ad_data)
  );
endmodule
