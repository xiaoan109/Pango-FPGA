`timescale 1ns / 1ns
module tb_top ();

  reg sys_clk;
  reg sys_rst_n;
  reg [3:0] key;

  wire rstn_out;
  wire iic_tx_scl;
  wire iic_tx_sda;
  wire led_int;

  wire pix_clk;
  wire vs_out;
  wire hs_out;
  wire de_out;
  wire [7:0] r_out;
  wire [7:0] g_out;
  wire [7:0] b_out;

  wire ad_clk;
  reg [7:0] ad_data;

  wire da_clk;
  wire [7:0] da_data;

  //defparam  define
  defparam u_dds_dso_top.u_key_control.CNT_MAX = 24;
  //   defparam top_dds_inst.dds_inst.FREQ_CTRL = 32'd42949672;


  initial begin
    sys_clk = 1'b0;
    sys_rst_n <= 1'b0;
    key <= 4'b0000;

    #200;
    sys_rst_n <= 1'b1;
    key <= 4'b1110;
  end

  always #10 sys_clk = ~sys_clk;

  always @(posedge ad_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0) ad_data <= 8'b0;
    else ad_data <= da_data;


  dds_dso_top u_dds_dso_top (
    .sys_clk(sys_clk),     // input system clock 50MHz
    .sys_rst_n(sys_rst_n),
    .rstn_out(rstn_out),
    .iic_tx_scl(iic_tx_scl),
    .iic_tx_sda(iic_tx_sda),
    .led_int(led_int),

    .pix_clk(pix_clk),  //pixclk
    .vs_out (vs_out),
    .hs_out (hs_out),
    .de_out (de_out),
    .r_out  (r_out),
    .g_out  (g_out),
    .b_out  (b_out),

    .ad_clk (ad_clk),
    .ad_data(ad_data),

    .key(key),  //输入4位按键

    .da_clk (da_clk),  //输入DAC模块时钟
    .da_data(da_data)  //输入DAC模块波形数据
  );

  GTP_GRS GRS_INST (.GRS_N(1'b1));
endmodule
