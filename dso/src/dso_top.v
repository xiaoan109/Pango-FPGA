// `define PDS_LITE
module dso_top (
  input wire sys_clk,   //!系统时钟50MHz
  input wire sys_rst_n, //!系统复位，低电平有效

  //hdmi_in
  input wire       i_vs_hdmi,  //!HDMI输入场同步信号
  input wire       i_hs_hdmi,  //!HDMI输入行同步信号
  input wire       i_de_hdmi,  //!HDMI输入数据有效信号
  input wire [7:0] i_r_hdmi,   //!HDMI输入数据R通道
  input wire [7:0] i_g_hdmi,   //!HDMI输入数据G通道
  input wire [7:0] i_b_hdmi,   //!HDMI输入数据B通道
  //hdmi_out
  input  wire       pix_clk,  //!HDMI像素时钟
  output wire       vs_out,   //!HDMI输出场同步信号
  output wire       hs_out,   //!HDMI输出行同步信号
  output wire       de_out,   //!HDMI输出数据有效信号
  output wire [7:0] r_out,    //!HDMI输出数据R通道
  output wire [7:0] g_out,    //!HDMI输出数据G通道
  output wire [7:0] b_out,    //!HDMI输出数据B通道

  input wire       ad_clk,  //!ADC采样时钟
  input wire [7:0] ad_data, //!ADC采样数据

  //ctrl regs
  input wire [7:0] trig_level,  //!示波器触发电平(0-255对应-5~5V)
  input wire [9:0] deci_rate,  //!示波器抽样率
  input wire wave_run,  //!示波器RUN/STOP
  input wire trig_edge,  //!示波器触发类型(上升/下降)
  input wire [4:0] v_scale,  //!示波器垂直缩放倍数(1/2/4倍)
  input wire fft_en,  //!FFT频域显示开关
  input wire fir_en,  //!FIR低通滤波开关
  input wire [11:0] trig_line,  //!触发电平绘制像素点
  //measure regs
  output wire [19:0] ad_freq ,    //!ADC信号的频率
  output wire [7:0] ad_vpp   ,    //!ADC信号峰峰值
  output wire [7:0] ad_max   ,    //!ADC信号最大值
  output wire [7:0] ad_min        //!ADC信号最小值
);


  //parameter define
  parameter CLK_FS = 26'd50_000_000;  // 基准时钟频率值

  wire [23:0] pixel_data;

  wire        ad_pulse;
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

  assign hdmi_hs_out = i_hs_hdmi;
  assign hdmi_vs_out = i_vs_hdmi;
  assign hdmi_de_out = i_de_hdmi;
  assign hdmi_r_out  = i_r_hdmi;
  assign hdmi_g_out  = i_g_hdmi;
  assign hdmi_b_out  = i_b_hdmi;



  fir_wrapper u_fir_wrapper (
    .ad_clk     (ad_clk),
    .rst_n      (sys_rst_n),
    .ad_data    (ad_data),
    .fir_en     (fir_en),
    .ad_data_out(ad_filter_data)
  );



  //参数测量模块，测量输入波形峰峰值和频率
  param_measure #(
    .CLK_FS  (CLK_FS)   // 系统时钟频率值
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
    .ad_min   (ad_min)
  );

  //抽样控制模块
  decimator u_decimator (
    .ad_clk    (ad_clk),
    .rst_n     (sys_rst_n),
    .deci_rate (deci_rate),
    .deci_valid(deci_valid)
  );

  //output osd

  dso_ui_display u_dso_ui_display (
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
    .v_scale   (v_scale),
    .o_hs      (osd_hs_out),
    .o_vs      (osd_vs_out),
    .o_de      (osd_de_out),
    .o_data    (osd_data_out)
  );


  //output grid
  dso_grid_display u_dso_grid_display (
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
  dso_wave_display u_dso_wave_display (
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

`ifdef PDS_LITE
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
`else
  assign ram_rd_data = 12'b0;
`endif

endmodule
