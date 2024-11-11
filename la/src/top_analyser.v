module top_analyser(
   input               sys_clk,
   input               sys_rst_n,
   output              rstn_out,
   output              iic_tx_scl,
   inout               iic_tx_sda,
  //  output              led_int,

  input i_vs_hdmi ,
  input i_hs_hdmi ,
  input i_de_hdmi ,
  input [7:0] i_r_hdmi  ,
  input [7:0] i_g_hdmi  ,
  input [7:0] i_b_hdmi  ,
   //hdmi_out
   input              pix_clk,
   output              o_hs_wave,
   output              o_vs_wave,
   output              o_de_wave,
   output   [7:0]      r_out,
   output   [7:0]      g_out,
   output   [7:0]      b_out,
   input               right_shift,
   input               left_shift,
   //params from cpu
   input    [7:0]      data_in,
   input               trigger_en,
   input    [5:0]      interval,
   input    [9:0]      pre_num,
   output wire         finished ,
  
   input    [2:0]      chn_sel,
   input    [2:0]      mode_sel,
   input    [3:0]      freq_sel
   // input               uart_en
   //protocol analysis outs
  //  output   [7:0]      uart_data
   );

   wire     [7:0]      wr_data;
   wire                wr_en;
   wire     [9:0]      wr_addr;
   wire     [9:0]      rd_addr;
   wire     [9:0]      start_addr;
   wire                o_hs_grid;
   wire                o_vs_grid;
   wire                o_de_grid;
   wire     [23:0]     o_data_grid;
   wire                wr_over;
   wire     [9:0]      rdaddress;
         
   wire                o_hs_hdmi;
   wire                o_vs_hdmi;
   wire                o_de_hdmi;
   wire     [7:0]      o_r_hdmi;
   wire     [7:0]      o_g_hdmi;
   wire     [7:0]      o_b_hdmi;
         
   wire                clken;


assign o_hs_hdmi = i_vs_hdmi ;
assign o_vs_hdmi = i_hs_hdmi ;
assign o_de_hdmi = i_de_hdmi ;
assign o_r_hdmi  = i_r_hdmi  ;
assign o_g_hdmi  = i_g_hdmi  ;
assign o_b_hdmi  = i_b_hdmi  ;


   la_wave_display u_wave_display (
      .rst_n      (  sys_rst_n            ), // input
      .pclk       (  pix_clk              ), // input
      .wave_color (  24'hff0000           ), // input
      .wr_data    (  wr_data              ), // input
      .wr_en      (  wr_en                ), // input
      .wr_addr    (  wr_addr              ), // input
      .start_addr (  start_addr           ), // input
      .i_hs       (  o_hs_grid            ), // input
      .i_vs       (  o_vs_grid            ), // input
      .i_de       (  o_de_grid            ), // input
      .i_data     (  o_data_grid          ), // input
      .trigger_en (  trigger_en           ), // input
      .right_shift(  0                    ), // input
      .left_shift (  0                    ), // input
      .interval   (  16                   ), // input
      .pre_num    (  1                  ), // input
      .o_hs       (  o_hs_wave            ), // output
      .o_vs       (  o_vs_wave            ), // output
      .o_de       (  o_de_wave            ), // output
      .o_data     (  {r_out,g_out,b_out}  )  // output
   );

   
   sample_ctrl u_sample_ctrl(
      .iSysClk    (  sys_clk     ),   // input
      .iRst       (  sys_rst_n   ),   // input
      .clk_en     (  clken       ),   // input
      .trigger_en (  trigger_en  ), // input
      .chn_sel    (  chn_sel     ), // input
      .mode_sel   (  mode_sel    ), // input
      // .trigger_en (  trigger_en  ),   // input
      // .chn_sel    (  3'b100      ),   // input
      // .mode_sel   (  3'd2        ),   // input
      .data_in    (  data_in     ),   // input
      .wr_addr    (  wr_addr     ),   // output
      .wr_data    (  wr_data     ),   // output
      .wr_en      (  wr_en       ),
      .start_addr (  start_addr  ),
      .finished   (  finished    ),
      .pre_num    (  pre_num         )    // output
   );

   la_grid_display u_grid_display (
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

//   pulse_gen u_pulse_gen (
//      .sys_clk   (  sys_clk     ), // input
//      .sys_rst_n (  sys_rst_n   ), // input
//      .finished  (  finished    ), // input
//      .pulse     (  trigger_en  )  // output
//   );

   //debug_sg u_debug_sg (
   //   .sys_clk   (  sys_clk   ), // input
   //   .sys_rst_n (  sys_rst_n ), // input
   //   .test_data (  data_in   )  // output
   //);

   freq_div u_freq_div (
      .iSysClk    (  sys_clk   ), // input
      .iRst       (  sys_rst_n ), // input
      .freq_sel   (  4'h8      ), // input
      .clken      (  clken     )  // output
   );

  //  hdmi_test u_hdmi_test (
  //     .sys_clk    (  sys_clk     ), // input
  //     .rstn_out   (  rstn_out    ), // output
  //     .iic_tx_scl (  iic_tx_scl  ), // output
  //     .iic_tx_sda (  iic_tx_sda  ), // inout
  //     .led_int    (  led_int     ), // output
  //     .pix_clk    (  pix_clk     ), // output
  //     .vs_out     (  o_vs_hdmi   ), // output
  //     .hs_out     (  o_hs_hdmi   ), // output
  //     .de_out     (  o_de_hdmi   ), // output
  //     .r_out      (  o_r_hdmi    ), // output
  //     .g_out      (  o_g_hdmi    ), // output
  //     .b_out      (  o_b_hdmi    )  // output
  //  );

  //  lfsr u_lfsr (
  //     .sys_clk   (  sys_clk   ), // input
  //     .sys_rst_n (  sys_rst_n ), // input
  //     .test_data (  data_in   )  // output
  //  );

   //uart_tx u_uart_tx (
   //   .sys_clk   (  sys_clk   ), // input
   //   .sys_rst_n (  sys_rst_n ), // input
   //   .test_data (  data_in   )  // output
   //);

  //  uart_tx u_uart_tx (
  //     .sys_clk   (  sys_clk       ), // input
  //     .sys_rst_n (  sys_rst_n     ), // input
  //     .pi_data   (  8'b10000010   ), // input
  //     .pi_flag   (  1'b1          ), // input
  //     .tx        (  tx_data       )  // output
  //  );  

   //uart_detect u_uart_detect (
   //   .sys_clk   (  sys_clk   ), // input
   //   .sys_rst_n (  sys_rst_n ), // input
   //   .tx_data   (  tx_data   ), // input
   //   .wr_en     (  ad_wr_en  ), // input
   //   .uart_en   (  uart_en   ), // input
   //   .uart_data (  uart_data )  // output
   //);

endmodule