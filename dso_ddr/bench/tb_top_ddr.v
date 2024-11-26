`timescale 1ps / 1ps
module tb_top_ddr ();

`include "mem/ddr3_parameters.vh"



  parameter real CLKIN_FREQ  = 50.0;
  
  
  parameter PLL_REFCLK_IN_PERIOD = 1000000 / CLKIN_FREQ;
  
  
  parameter MEM_ADDR_WIDTH = 15;
  
  parameter MEM_BADDR_WIDTH = 3;
  
  parameter MEM_DQ_WIDTH = 32;
  
  
  parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8;
  parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8;
  parameter MEM_NUM              = MEM_DQ_WIDTH/16;

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
  
  
  reg                           pll_refclk_in    ;
  reg                           free_clk         ;
  reg                           ddr_rstn         ;
  wire                          mem_rst_n        ; 
  wire                          mem_ck           ;
  wire                          mem_ck_n         ;
  wire                          mem_cke          ;
  wire                          mem_cs_n         ;
  wire                          mem_ras_n        ;
  wire                          mem_cas_n        ;
  wire                          mem_we_n         ;
  wire                          mem_odt          ;
  wire [ MEM_ADDR_WIDTH-1:0]    mem_a            ;  
  wire [MEM_BADDR_WIDTH-1:0]    mem_ba           ;  
  wire [  MEM_DQS_WIDTH-1:0]    mem_dqs          ;  
  wire [  MEM_DQS_WIDTH-1:0]    mem_dqs_n        ;  
  wire [   MEM_DQ_WIDTH-1:0]    mem_dq           ;  
  wire [   MEM_DM_WIDTH-1:0]    mem_dm           ;
  wire [      ADDR_BITS-1:0]    mem_addr         ; 
  wire                          dfi_init_complete;



  initial begin
    sys_clk = 1'b0;
    sys_rst_n = 1'b1;
    key = 4'b0000;

    //reset the bu_top
    #10000 sys_rst_n = 1'b0;
    #50000 sys_rst_n = 1'b1;
	$display("%t keyboard reset sequence finished!", $time);
    key = 4'b1110;
	@ (posedge dfi_init_complete);
    $display("%t dfi_init_complete is high now!", $time);
	#100000000;
    $finish;
  end

  // always #10 sys_clk = ~sys_clk;
  always #(PLL_REFCLK_IN_PERIOD / 2)  sys_clk = ~sys_clk;
  
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
    .da_data(da_data),  //输入DAC模块波形数据
	
    .pll_lock        (                ),
    .ddr_init_done   (dfi_init_complete),
    .mem_rst_n       (mem_rst_n       ),
    .mem_ck          (mem_ck          ),
    .mem_ck_n        (mem_ck_n        ),
    .mem_cke         (mem_cke         ),
    .mem_cs_n        (mem_cs_n        ),
    .mem_ras_n       (mem_ras_n       ),
    .mem_cas_n       (mem_cas_n       ),
    .mem_we_n        (mem_we_n        ),
    .mem_odt         (mem_odt         ),
    .mem_a           (mem_a           ),
    .mem_ba          (mem_ba          ),
    .mem_dqs         (mem_dqs         ),
    .mem_dqs_n       (mem_dqs_n       ),
    .mem_dq          (mem_dq          ),
    .mem_dm          (mem_dm          ),
    .heart_beat_led  (),
    .err_flag_led    ()
  );


  reg  [MEM_NUM:0]              mem_ck_dly;
  reg  [MEM_NUM:0]              mem_ck_n_dly;
  
  always @ (*)
  begin
      mem_ck_dly[0]   <=  mem_ck;
      mem_ck_n_dly[0] <=  mem_ck_n;
  end
  
  assign mem_addr = {{(ADDR_BITS-MEM_ADDR_WIDTH){1'b0}},{mem_a}};
  
  genvar gen_mem;                                                    
  generate                                                         
    for(gen_mem=0; gen_mem<MEM_NUM; gen_mem=gen_mem+1) begin   : i_mem 
    
      always @ (*)
        begin
        mem_ck_dly[gen_mem+1] <= #50 mem_ck_dly[gen_mem];
        mem_ck_n_dly[gen_mem+1] <= #50 mem_ck_n_dly[gen_mem];
        end
 
      ddr3      mem_core (
    
        .rst_n             (mem_rst_n                        ),
        .ck                (mem_ck_dly[gen_mem+1]            ),
        .ck_n              (mem_ck_n_dly[gen_mem+1]          ),
	    
        .cs_n              (mem_cs_n                         ),
	    
        .addr              (mem_addr                         ),
        .dq                (mem_dq[16*gen_mem+15:16*gen_mem] ),
        .dqs               (mem_dqs[2*gen_mem+1:2*gen_mem]   ),
        .dqs_n             (mem_dqs_n[2*gen_mem+1:2*gen_mem] ),
        .dm_tdqs           (mem_dm[2*gen_mem+1:2*gen_mem]    ),
        .tdqs_n            (                                 ),
        .cke               (mem_cke                          ),
        .odt               (mem_odt                          ),
        .ras_n             (mem_ras_n                        ),
        .cas_n             (mem_cas_n                        ),
        .we_n              (mem_we_n                         ),
        .ba                (mem_ba                           )
      );
    end     
  endgenerate

  GTP_GRS GRS_INST (.GRS_N(1'b1));
endmodule
