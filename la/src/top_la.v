module top_la(
   input               sys_clk,
   input               sys_rst_n,
   output              rstn_out      ,
   output              iic_tx_scl    ,
   inout               iic_tx_sda    ,
   output              led_int       ,
   input               key0,
   input               key1,

   // input [2:0] spi_data, 
   //hdmi_out
   output              pix_clk,
   output              o_hs_wave,
   output              o_vs_wave,
   output              o_de_wave,
   output   [7:0]      r_out,
   output   [7:0]      g_out,
   output   [7:0]      b_out,
   //params from cpu
   input    [7:0]      data_in,
   input               trigger_en,
   input    [5:0]      interval,
   input    [9:0]      pre_num,
   // output wire         finished ,
  
   input    [2:0]      cpu_chn_sel,
   input    [2:0]      cpu_mode_sel,
   input    [3:0]      freq_sel,
   input               uart_en,
   input               spi_en
   //protocol analysis outs
   //  output   [7:0]      uart_data
   );
   
   wire            hdmi_hs;
   wire            hdmi_vs;
   wire            hdmi_de;
   wire [7:0]      hdmi_r_out    ;
   wire [7:0]      hdmi_g_out    ;
   wire [7:0]      hdmi_b_out    ;
   
   
   
   
   
hdmi_top u_hdmi_top(
    .sys_clk   (sys_clk   )    ,// input system clock 50MHz    
    .rstn_out  (rstn_out  )    ,
    .iic_tx_scl(iic_tx_scl)    ,
    .iic_tx_sda(iic_tx_sda)    ,
    .led_int   (led_int   )    ,
//hdmi_out 
    .pix_clk(pix_clk)       ,//pixclk                           
    .vs_out (hdmi_vs)       , 
    .hs_out (hdmi_hs)       , 
    .de_out (hdmi_de)       ,
    .r_out  (hdmi_r_out)       , 
    .g_out  (hdmi_g_out)       , 
    .b_out  (hdmi_b_out)       
);
	
	
 top_analyser u_top_analyser (
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.key0(key0),
	.key1(key1),
	.spi_data(3'b0), 
    .i_vs_hdmi(hdmi_vs) ,
    .i_hs_hdmi(hdmi_hs) ,
    .i_de_hdmi(hdmi_de) ,
    .i_r_hdmi(hdmi_r_out)  ,
    .i_g_hdmi(hdmi_g_out)  ,
    .i_b_hdmi(hdmi_b_out)  ,
	.pix_clk(pix_clk),
	.o_hs_wave(o_hs_wave),
	.o_vs_wave(o_vs_wave),
	.o_de_wave(o_de_wave),
	.r_out(r_out),
	.g_out(g_out),
	.b_out(b_out),
	.data_in(8'b0),
    .trigger_en(1'b0),
    .interval(6'b1),
    .pre_num(10'd512),
    .finished() ,
    
    .cpu_chn_sel(3'b0),
    .cpu_mode_sel(3'b0),
    .freq_sel(4'b0),
    .uart_en(1'b0),
    .spi_en(1'b0)
);


endmodule