module dso_top (
  input  wire       sys_clk,     // input system clock 50MHz
  input  wire       sys_rst_n,
  output wire       rstn_out,
  output wire       iic_tx_scl,
  inout  wire       iic_tx_sda,
  output wire       led_int,
  //hdmi_out

  input i_vs_hdmi ,
  input i_hs_hdmi ,
  input i_de_hdmi ,
  input [7:0] i_r_hdmi  ,
  input [7:0] i_g_hdmi  ,
  input [7:0] i_b_hdmi  ,

  input wire       pix_clk,     //pixclk
  output wire       vs_out,
  output wire       hs_out,
  output wire       de_out,
  output wire [7:0] r_out,
  output wire [7:0] g_out,
  output wire [7:0] b_out,

  input wire       ad_clk,
  input wire [7:0] ad_data,

  //ctrl regs
  input wire [7:0] trig_level,  //触发电平
  input wire [9:0] deci_rate,  //抽样率
  input wire wave_run,
  input wire trig_edge,
  input wire [4:0] v_scale,
  input wire fft_en,
  input wire fir_en,
  input wire [11:0] trig_line,
  //measure regs
  output wire [19:0] ad_freq  /* synthesis PAP_MARK_DEBUG="true" */,  //AD脉冲信号的频率 
  output wire [7:0] ad_vpp  /* synthesis PAP_MARK_DEBUG="true" */,  //AD输入信号峰峰值  
  output wire [7:0] ad_max  /* synthesis PAP_MARK_DEBUG="true" */,  //AD输入信号最大值  
  output wire [7:0] ad_min  /* synthesis PAP_MARK_DEBUG="true" */  //AD输入信号最小值  
);


  //parameter define
  parameter CLK_FS = 26'd50_000_000;  // 基准时钟频率值
  parameter DEBUG_EN = 1'b0;

  wire [23:0] pixel_data;

  // wire [ 7:0] trig_level;  //触发电平
  // wire [ 9:0] deci_rate;  //抽样率
  // wire        wave_run;
  // wire        trig_edge;
  // wire [ 4:0] v_scale;
  // wire         fft_en;
 

  // wire [19:0] ad_freq  /* synthesis PAP_MARK_DEBUG="true" */;  //AD脉冲信号的频率 
  // wire [ 7:0] ad_vpp  /* synthesis PAP_MARK_DEBUG="true" */;  //AD输入信号峰峰值  
  // wire [ 7:0] ad_max  /* synthesis PAP_MARK_DEBUG="true" */;  //AD输入信号最大值  
  // wire [ 7:0] ad_min  /* synthesis PAP_MARK_DEBUG="true" */;  //AD输入信号最小值  
  wire        ad_pulse  /* synthesis PAP_MARK_DEBUG="true" */;
  wire        debug_clk;
  wire        deci_valid;

  wire [ 7:0] hdmi_r_out;
  wire [ 7:0] hdmi_g_out;
  wire [ 7:0] hdmi_b_out;
  wire        hdmi_vs_out;
  wire        hdmi_hs_out;
  wire        hdmi_de_out;

  wire [23:0] osd_data_out;
  wire        osd_vs_out;
  wire        osd_hs_out;
  wire        osd_de_out;

  wire [23:0] grid_data_out;
  wire        grid_vs_out;
  wire        grid_hs_out;
  wire        grid_de_out;

  wire [11:0] wave_rd_addr;
  wire        ad_buf_wr;
  wire [11:0] ad_buf_wr_addr;
  wire [ 7:0] ad_buf_data;
  wire [11:0] ad_buf_rd_addr;
  wire        wr_over;
  wire        wr_over_cdc;
  wire        cdc_busy;

  wire [11:0] ram_rd_data;

  wire [ 7:0] ad_filter_data;

  // assign trig_level = 8'd127;
  // assign deci_rate = 10'd1;
  // assign trig_edge = 1'b1;
  // assign v_scale = {1'b1, 4'd2};
  // assign wave_run = 1'b1;
  // assign fft_en = 1'b1;

  // clk_test #(
  //   .DIV_N(26'd500)  //100KHz
  // ) u_clk_test (
  //   .clk_in(sys_clk),   // 输入时钟
  //   .rst_n (sys_rst_n), // 复位信号

  //   .clk_out(debug_clk)  // 输出时钟
  // );
  assign  hdmi_hs_out = i_hs_hdmi;
  assign  hdmi_vs_out = i_vs_hdmi;
  assign  hdmi_de_out = i_de_hdmi;
  assign  hdmi_r_out = i_r_hdmi;
  assign  hdmi_g_out = i_g_hdmi;
  assign  hdmi_b_out = i_b_hdmi;



  fir_wrapper u_fir_wrapper (
    .ad_clk     (ad_clk),
    .rst_n      (sys_rst_n),
    .ad_data    (ad_data),
    .fir_en     (fir_en),
    .ad_data_out(ad_filter_data)
  );



  //参数测量模块，测量输入波形峰峰值和频率    
  param_measure #(
    .CLK_FS  (CLK_FS),   // 系统时钟频率值
    .DEBUG_EN(DEBUG_EN)
  ) u_param_measure (
    .clk  (sys_clk),
    .rst_n(sys_rst_n),

    .trig_level(trig_level),  //trig_level

    .ad_clk   (ad_clk),
    .ad_data  (ad_filter_data),
    .ad_pulse (ad_pulse),
    .ad_freq  (ad_freq),   // 频率
    .ad_vpp   (ad_vpp),    // 峰峰值
    .ad_max   (ad_max),
    .ad_min   (ad_min),
    .debug_clk(debug_clk)
  );

  //抽样控制模块
  decimator u_decimator (
    .ad_clk    (ad_clk),
    .rst_n     (sys_rst_n),
    .deci_rate (deci_rate),
    .deci_valid(deci_valid)
  );


  // //output color bar
  // hdmi_top u_hdmi_top (
  //   .sys_clk   (sys_clk),      // input system clock 50MHz
  //   .rstn_out  (rstn_out),
  //   .iic_tx_scl(iic_tx_scl),
  //   .iic_tx_sda(iic_tx_sda),
  //   .led_int   (led_int),
  //   //hdmi_out
  //   .pix_clk   (pix_clk),      //pixclk
  //   .vs_out    (hdmi_vs_out),
  //   .hs_out    (hdmi_hs_out),
  //   .de_out    (hdmi_de_out),
  //   .r_out     (hdmi_r_out),
  //   .g_out     (hdmi_g_out),
  //   .b_out     (hdmi_b_out)
  // );

  //output osd

  ui_display u_ui_display (
    .rst_n     (sys_rst_n),
    .pclk      (pix_clk),
    .ad_clk    (ad_clk),
    .sys_clk   (sys_clk),
    .i_hs      (hdmi_hs_out),
    .i_vs      (hdmi_vs_out),
    .i_de      (hdmi_de_out),
    .i_data    ({hdmi_r_out, hdmi_g_out, hdmi_b_out}),
    .ad_freq   (ad_freq),
    .ad_vpp    (ad_vpp),
    .ad_max    (ad_max),
    .ad_min    (ad_min),
    .trig_level(trig_level),
    .trig_edge (trig_edge),
    .fft_en    (fft_en),
    .deci_rate (deci_rate),
    .fir_en    (fir_en),
    .o_hs      (osd_hs_out),
    .o_vs      (osd_vs_out),
    .o_de      (osd_de_out),
    .o_data    (osd_data_out)
  );


  //output grid
  grid_display u_grid_display (
    .rst_n (sys_rst_n),
    .pclk  (pix_clk),
    .i_hs  (osd_hs_out),
    .i_vs  (osd_vs_out),
    .i_de  (osd_de_out),
    .i_data(osd_data_out),
    .o_hs  (grid_hs_out),
    .o_vs  (grid_vs_out),
    .o_de  (grid_de_out),
    .o_data(grid_data_out)
  );

  //output hdmi wave
  wav_display u_wav_display (
    .rst_n         (sys_rst_n),
    .pclk          (pix_clk),
    .wave_color    (24'hff0000),
    .ad_clk        (ad_clk),
    .ad_buf_wr     (ad_buf_wr),
    .ad_buf_wr_addr(ad_buf_wr_addr),
    .ad_buf_data   (ad_buf_data),
    .wave_rd_addr  (wave_rd_addr),
    .ad_buf_rd_addr(ad_buf_rd_addr),
    .fft_en        (fft_en),
    .ram_rd_data   (ram_rd_data),
    .i_hs          (grid_hs_out),
    .i_vs          (grid_vs_out),
    .i_de          (grid_de_out),
    .i_data        (grid_data_out),
    .o_hs          (hs_out),
    .o_vs          (vs_out),
    .o_de          (de_out),
    .o_data        ({r_out, g_out, b_out}),
    .wr_over       (wr_over),
    .v_scale       (v_scale),
    .trig_line     (trig_line)
  );

  cdc u_cdc (
    .clk1  (pix_clk),
    .rst1_n(sys_rst_n),

    .clk2  (ad_clk),
    .rst2_n(sys_rst_n),

    .a(wr_over),

    .b_r (wr_over_cdc),
    .busy(cdc_busy)
  );

  ad9280_sample u_ad9280_sample (
    .ad_clk        (ad_clk),
    .rst_n         (sys_rst_n),
    .ad_data       (ad_filter_data),
    .deci_valid    (deci_valid),
    .wave_run      (wave_run),
    .trig_level    (trig_level),
    .trig_edge     (trig_edge),
    .wave_rd_addr  (wave_rd_addr),
    .wr_over       (wr_over_cdc),
    .ad_buf_wr     (ad_buf_wr),
    .ad_buf_wr_addr(ad_buf_wr_addr),
    .ad_buf_data   (ad_buf_data),
    .ad_buf_rd_addr(ad_buf_rd_addr)
  );


  fft_adc_top u_fft_adc_top (
    .sys_clk  (ad_clk),
    .sys_rst_n(sys_rst_n),

    .ad_data    (ad_filter_data),
    .deci_valid (deci_valid),
    .fft_en     (fft_en),
    .rd_clk     (pix_clk),
    .rd_addr    (wave_rd_addr),
    .ram_rd_data(ram_rd_data)
  );

endmodule
