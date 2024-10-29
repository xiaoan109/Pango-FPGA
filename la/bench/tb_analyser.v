`timescale 1ns/1ps
`define clk_period 20

module tb_analyser(

   );

   reg        sys_clk;
   reg        sys_rst_n;
   wire       rstn_out;
   wire       iic_tx_scl;
   wire       iic_tx_sda;
   wire       led_int;
   wire       pix_clk;
   wire       o_hs_wave;
   wire       o_vs_wave;
   wire       o_de_wave;
   wire [7:0] r_out;
   wire [7:0] g_out;
   wire [7:0] b_out;

   always #(`clk_period/2) sys_clk = ~sys_clk;

   initial begin
      sys_clk = 0;
      sys_rst_n = 1;
      #(`clk_period*10);
      sys_rst_n = 0;
      #(`clk_period*1);
      sys_rst_n = 1;
   end

   top_analyser u_top_analyser (
      .sys_clk(sys_clk),
      .sys_rst_n(sys_rst_n),
      .rstn_out(rstn_out),
      .iic_tx_scl(iic_tx_scl),
      .iic_tx_sda(iic_tx_sda),
      .led_int(led_int),
      .pix_clk(pix_clk),
      .o_hs_wave(o_hs_wave),
      .o_vs_wave(o_vs_wave),
      .o_de_wave(o_de_wave),
      .r_out(r_out),
      .g_out(g_out),
      .b_out(b_out)
   );

    GTP_GRS GRS_INST(.GRS_N(1'b1));
endmodule