module dds_dso_top #(
  parameter MEM_ROW_ADDR_WIDTH   = 15,

  parameter MEM_COL_ADDR_WIDTH   = 10,

  parameter MEM_BADDR_WIDTH      = 3,

  parameter MEM_DQ_WIDTH         =  32,

  parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8,
  parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8,
  parameter CTRL_ADDR_WIDTH      = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH,

  parameter USER_DATA_WIDTH      = 8
  )(
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
  output wire [7:0] da_data,  //输入DAC模块波形数据
  //DDR3
  output                                 pll_lock        ,
  output                                 ddr_init_done   ,


  output                                 mem_rst_n       ,
  output                                 mem_ck          ,
  output                                 mem_ck_n        ,
  output                                 mem_cke         ,

  output                                 mem_cs_n        ,

  output                                 mem_ras_n       ,
  output                                 mem_cas_n       ,
  output                                 mem_we_n        ,
  output                                 mem_odt         ,
  output     [MEM_ROW_ADDR_WIDTH-1:0]    mem_a           ,
  output     [MEM_BADDR_WIDTH-1:0]       mem_ba          ,
  inout      [MEM_DQS_WIDTH-1:0]         mem_dqs         ,
  inout      [MEM_DQS_WIDTH-1:0]         mem_dqs_n       ,
  inout      [MEM_DQ_WIDTH-1:0]          mem_dq          ,
  output     [MEM_DM_WIDTH-1:0]          mem_dm          ,
  output                                 heart_beat_led  ,
  output                                 err_flag_led
);

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

  // wire [19:0] ad_freq;  //AD脉冲信号的频率
  // wire [ 7:0] ad_vpp;  //AD输入信号峰峰值
  // wire [ 7:0] ad_max;  //AD输入信号最大值
  // wire [ 7:0] ad_min;  //AD输入信号最小值

  wire vs_hdmi;
  wire hs_hdmi;
  wire de_hdmi;
  wire [7:0] r_hdmi;
  wire [7:0] g_hdmi;
  wire [7:0] b_hdmi;

  wire    [8:0]   amp_ctl  ;
  wire    [31:0]  freq_ctl ;
  wire    [31:0]  min_ctl  ;
  wire    [11:0]  phase_ctl;

  pll u_pll (
    .clkin1  (sys_clk),  //50MHz
    .clkout0 (da_clk),   //120MHz
    .clkout1 (ad_clk),   //30MHz
    .pll_lock(locked)
  );

  key_control u_key_control (
    .sys_clk  (sys_clk),    //系统时钟,50MHz
    .sys_rst_n(sys_rst_n),  //复位信号,低电平有效
    .key      (key),        //输入4位按键

    .wave_select(wave_select)  //输出波形选择
  );

  assign  amp_ctl   = 9'd256;
  // assign  freq_ctl  = 32'd35791394;
  assign  freq_ctl  = 32'd3579139;
  assign  min_ctl   = 32'd0;
  assign  phase_ctl = 12'd0;

  dds_top u_dds_top (
    .sys_clk    (da_clk),     //DAC CLK
    .sys_rst_n  (sys_rst_n),   //复位信号,低电平有效
    .wave_select(wave_select), //输出波形选择
    .amp_ctl   (amp_ctl  )           ,   //幅值
    .freq_ctl  (freq_ctl )           ,   //频率
    .min_ctl   (min_ctl  )           ,   //最小分辨率
    .phase_ctl (phase_ctl)           ,   //相位
    .data_out  (da_data)  //输入DAC模块波形数据
  );

  hdmi_top u_hdmi_top (
	.sys_clk   (sys_clk),     // input system clock 50MHz
	.rstn_out  (rstn_out),
	.iic_tx_scl(iic_tx_scl),
	.iic_tx_sda(iic_tx_sda),
    .led_int   (led_int),
    //hdmi_out
    .pix_clk   (pix_clk),     //pixclk
    .vs_out    (vs_hdmi),
    .hs_out    (hs_hdmi),
    .de_out    (de_hdmi),
    .r_out     (r_hdmi ),
    .g_out     (g_hdmi ),
    .b_out     (b_hdmi)

);


  assign trig_level = 8'd127;
  assign deci_rate = 10'd1;
  assign trig_edge = 1'b1;
  assign v_scale = {1'b1, 4'd2};
  assign wave_run = 1'b1;
  assign fft_en = 1'b0;
  assign fir_en = 1'b1;
  assign trig_line = 12'd512;

  dso_top u_dso_top (
    .sys_clk   (sys_clk),     // input system clock 50MHz
    .sys_rst_n (sys_rst_n),

	.i_vs_hdmi(vs_hdmi),
	.i_hs_hdmi(hs_hdmi),
	.i_de_hdmi(de_hdmi),
	.i_r_hdmi(r_hdmi),
	.i_g_hdmi(g_hdmi),
	.i_b_hdmi(b_hdmi),
	.rstn_out(rstn_out),

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
    .ad_freq   (),     //AD脉冲信号的频率
    .ad_vpp    (),      //AD输入信号峰峰值
    .ad_max    (),      //AD输入信号最大值
    .ad_min    (),      //AD输入信号最小值
	.pll_lock      (pll_lock       ), 
	.ddr_init_done (ddr_init_done  ), 
	.mem_rst_n     (mem_rst_n      ), 
	.mem_ck        (mem_ck         ), 
	.mem_ck_n      (mem_ck_n       ), 
	.mem_cke       (mem_cke        ), 
	.mem_cs_n      (mem_cs_n       ), 
	.mem_ras_n     (mem_ras_n      ), 
	.mem_cas_n     (mem_cas_n      ), 
	.mem_we_n      (mem_we_n       ), 
	.mem_odt       (mem_odt        ), 
	.mem_a         (mem_a          ), 
	.mem_ba        (mem_ba         ), 
	.mem_dqs       (mem_dqs        ), 
	.mem_dqs_n     (mem_dqs_n      ), 
	.mem_dq        (mem_dq         ), 
	.mem_dm        (mem_dm         ), 
	.heart_beat_led(heart_beat_led ), 
	.err_flag_led  (err_flag_led   )
  );
endmodule
