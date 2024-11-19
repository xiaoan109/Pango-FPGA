module wave_top (
  input  wire        clk_50m,
  input  wire        hdmi_pclk,
  input  wire        ad_clk,
  input  wire        rst_n,
  input  wire [ 7:0] ad_data,
  input  wire [ 7:0] trig_level,     //触发电平
  input  wire [ 7:0] trig_line,      //触发线位置
  input  wire        trig_edge,      //触发边沿
  input  wire [ 9:0] deci_rate,      //抽样率
  input  wire        wave_run,       //波形采集运行/停止
  input  wire [ 9:0] h_shift,        //波形水平偏移量
  input  wire [ 9:0] v_shift,        //波形竖直偏移量
  input  wire [ 4:0] v_scale,        //波形竖直缩放比例
  input  wire [11:0] pixel_xpos,     //像素点横坐标
  input  wire [11:0] pixel_ypos,     //像素点纵坐标
  input  wire [23:0] ui_pixel_data,
  output wire [19:0] ad_freq,        //AD脉冲信号的频率
  output wire [ 7:0] ad_vpp,         //AD输入信号峰峰值
  output wire [ 7:0] ad_max,         //AD输入信号最大值
  output wire [ 7:0] ad_min,         //AD输入信号最小值
  output wire [23:0] pixel_data

);


  //parameter define
  parameter CLK_FS = 26'd50_000_000;  // 基准时钟频率值

  //wire define
  wire        deci_valid  /*synthesis PAP_MARK_DEBUG="true"*/;  //抽样有效信号
  wire        wave_data_req  /*synthesis PAP_MARK_DEBUG="true"*/;  //波形(AD数据)请求信号 
  wire [ 7:0] wave_rd_data  /*synthesis PAP_MARK_DEBUG="true"*/;  //请求到的波形(AD数据)
  wire [11:0] wave_rd_addr  /*synthesis PAP_MARK_DEBUG="true"*/;  //波形(AD数据)请求地址
  wire        outrange  /*synthesis PAP_MARK_DEBUG="true"*/;  //水平偏移超出范围
  wire        hdmi_wr_over  /*synthesis PAP_MARK_DEBUG="true"*/;  //hdmi波形绘制完成信号

  //参数测量模块，测量输入波形峰峰值和频率    
  param_measure #(
    .CLK_FS(CLK_FS)  // 系统时钟频率值
  ) u_param_measure (
    .clk  (clk_50m),
    .rst_n(rst_n),

    .trig_level(trig_level),  //trig_level

    .ad_clk  (ad_clk),
    .ad_data (ad_data),
    .ad_pulse(),
    .ad_freq (ad_freq),  // 频率
    .ad_vpp  (ad_vpp),   // 峰峰值
    .ad_max  (ad_max),
    .ad_min  (ad_min)
  );

  //数据抽样模块
  decimator u_decimator (
    .ad_clk(ad_clk),
    .rst_n (rst_n),

    .deci_rate (deci_rate),
    .deci_valid(deci_valid)
  );


  //波形数据存储模块  
  data_store u_data_store (
    .rst_n(rst_n),

    .trig_level(trig_level),
    .trig_edge (trig_edge),
    .wave_run  (wave_run),

    .ad_clk    (ad_clk),
    .ad_data   (ad_data),
    .deci_valid(deci_valid),
    .h_shift   (h_shift),

    .hdmi_pclk    (hdmi_pclk),
    .hdmi_wr_over (hdmi_wr_over),
    .wave_data_req(wave_data_req),
    .wave_rd_data (wave_rd_data),
    .wave_rd_addr (wave_rd_addr),
    .outrange     (outrange)
  );

  wave_display u_wave_display (
    .hdmi_pclk(hdmi_pclk),  //hdmi驱动时钟
    .rst_n    (rst_n),      //复位信号

    .pixel_xpos(pixel_xpos),  //像素点横坐标
    .pixel_ypos(pixel_ypos),  //像素点纵坐标

    .ui_pixel_data(ui_pixel_data),  //UI像素数据   

    .wave_data    (wave_rd_data),   //波形(AD数据)
    .wave_addr    (wave_rd_addr),   //显示点数
    .outrange     (outrange),
    .wave_data_req(wave_data_req),  //请求波形（AD）数据
    .wr_over      (hdmi_wr_over),   //绘制波形完成
    .pixel_data   (pixel_data),     //hdmi像素点数据

    .v_shift  (v_shift),   //波形竖直偏移量，bit[9]=0/1:上移/下移 
    .v_scale  (v_scale),   //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    .trig_line(trig_line)  //触发电平
  );
endmodule
