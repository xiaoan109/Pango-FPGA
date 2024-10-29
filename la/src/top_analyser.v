module top_analyser(
   input               sys_clk,
   input               sys_rst_n,
   output              rstn_out,
   output              iic_tx_scl,
   inout               iic_tx_sda,
   output              led_int,
   //hdmi_out
   output              pix_clk,
   output              o_hs_wave,
   output              o_vs_wave,
   output              o_de_wave,
   output   [7:0]      r_out,
   output   [7:0]      g_out,
   output   [7:0]      b_out,
   //input and params from cpu
   input    [7:0]      data_in,
   input               trigger_en,
   input    [2:0]      chn_sel,
   input    [2:0]      mode_sel,
   input    [3:0]      freq_sel
   );

   wire     [7:0]      ad_wr_data;
   wire                ad_wr_en;
   wire     [11:0]     ad_wr_addr;
   wire                o_hs_grid;
   wire                o_vs_grid;
   wire                o_de_grid;
   wire     [23:0]     o_data_grid;
         
   wire                o_hs_hdmi;
   wire                o_vs_hdmi;
   wire                o_de_hdmi;
   wire     [7:0]      o_r_hdmi;
   wire     [7:0]      o_g_hdmi;
   wire     [7:0]      o_b_hdmi;
         
   wire                clken;

   wave_display u_wave_display (
      .rst_n      (  sys_rst_n            ), // input
      .pclk       (  pix_clk              ), // input
      .wave_color (  24'hff0000           ), // input
//    .ad_clk     (  ad_clk               ), // input
      .ad_wr_data (  ad_wr_data           ), // input
      .ad_wr_en   (  ad_wr_en             ), // input
      .ad_wr_addr (  ad_wr_addr           ), // input
      .i_hs       (  o_hs_grid            ), // input
      .i_vs       (  o_vs_grid            ), // input
      .i_de       (  o_de_grid            ), // input
      .i_data     (  o_data_grid          ), // input
      .o_hs       (  o_hs_wave            ), // output
      .o_vs       (  o_vs_wave            ), // output
      .o_de       (  o_de_wave            ), // output
      .o_data     (  {r_out,g_out,b_out}  )  // output
   );

   grid_display u_grid_display (
      .rst_n      (  sys_rst_n                     ), // input
      .pclk       (  pix_clk                       ), // input
      .i_hs       (  o_hs_hdmi                     ), // input
      .i_vs       (  o_vs_hdmi                     ), // input
      .i_de       (  o_de_hdmi                     ), // input
      .i_data     (  {o_r_hdmi,o_g_hdmi,o_b_hdmi}  ), // input
      .o_hs       (  o_hs_grid                     ), // output
      .o_vs       (  o_vs_grid                     ), // output
      .o_de       (  o_de_grid                     ), // output
      .o_data     (  o_data_grid                   )  // output
   );

   freq_div u_freq_div (
      .iSysClk    (  sys_clk   ), // input
      .iRst       (  sys_rst_n ), // input
      .freq_sel   (  freq_sel  ), // input
      .clken      (  clken     )  // output
   );

   hdmi_test u_hdmi_test (
      .sys_clk    (  sys_clk     ), // input
      .rstn_out   (  rstn_out    ), // output
      .iic_tx_scl (  iic_tx_scl  ), // output
      .iic_tx_sda (  iic_tx_sda  ), // inout
      .led_int    (  led_int     ), // output
      .pix_clk    (  pix_clk     ), // output
      .vs_out     (  o_vs_hdmi   ), // output
      .hs_out     (  o_hs_hdmi   ), // output
      .de_out     (  o_de_hdmi   ), // output
      .r_out      (  o_r_hdmi    ), // output
      .g_out      (  o_g_hdmi    ), // output
      .b_out      (  o_b_hdmi    )  // output
   );

   sample_ctrl u_sample_ctrl(
      .iSysClk    (  sys_clk     ), // input
      .iRst       (  sys_rst_n   ), // input
      .clk_en     (  clken       ), // input
      .trigger_en (  trigger_en  ), // input
      .chn_sel    (  chn_sel     ), // input
      .mode_sel   (  mode_sel    ), // input
    //.trigger_en (  1'b1        ), // input
    //.chn_sel    (  3'b100      ), // input
    //.mode_sel   (  3'd2        ), // input
      .data_in    (  data_in     ), // input
      .wr_addr    (  ad_wr_addr  ), // output
      .wr_data    (  ad_wr_data  ), // output
      .wr_en      (  ad_wr_en    )  // output
   );

   //debug_sg u_debug_sg (
   //   .sys_clk   (  sys_clk   ), // input
   //   .sys_rst_n (  sys_rst_n ), // input
   //   .test_data (  data_in   )  // output
   //);

endmodule