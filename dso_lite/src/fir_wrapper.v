module fir_wrapper (
  input  wire       ad_clk, //!ADC采样时钟
  input  wire       rst_n,  //!系统复位，低电平有效
  input  wire [7:0] ad_data,  //!ADC采样数据
  input  wire       fir_en, //!FIR低通滤波开关
  output wire [7:0] ad_data_out //!ADC经FIR滤波后数据
);


  reg  [ 7:0] yout_round  /* synthesis PAP_MARK_DEBUG="true" */;
  reg  [ 7:0] ad_filter_data  /* synthesis PAP_MARK_DEBUG="true" */;
  wire [16:0] ad_mult_data  /* synthesis PAP_MARK_DEBUG="true" */;
  wire [19:0] yout  /* synthesis PAP_MARK_DEBUG="true" */;


  // wire        ad_origin_pulse;
  // wire [ 7:0] ad_origin_vpp;
  // wire [ 7:0] ad_origin_max;
  // wire [ 7:0] ad_origin_min;

  // wire        squ_wave;

  fxp_mul_pipe #(
    .WIIA (9),  //sign bit=0
    .WIFA (8),
    .WIIB (9),  //sign bit=0
    .WIFB (8),
    .WOI  (9),  //sign bit=0
    .WOF  (8),
    .ROUND(1)
  ) u_fxp_mul_pipe (
    .rstn    (rst_n),
    .clk     (ad_clk),
    .ina     ({1'b0, yout_round, 8'b0}),
    .inb     ({1'b0, 16'd484}),           //1.8888..*256 = 484
    .out     (ad_mult_data),
    .overflow()
  );

  always @(posedge ad_clk) begin
    yout_round <= yout[19:12] + yout[11];
    ad_filter_data <= ad_mult_data[15:8];
  end


  // param_measure u_param_measure (
  //   .clk       (sys_clk),          // 时钟
  //   .rst_n     (sys_rst_n),        // 复位信号
  //   .trig_level(8'd127),           // 触发电平
  //   .ad_clk    (ad_clk),           // AD时钟
  //   .ad_data   (ad_data),          // AD输入数据
  //   .ad_pulse  (ad_origin_pulse),  //pulse_gen模块输出的脉冲信号,仅用于调试
  //   .ad_freq   (),                 // 被测时钟频率输出
  //   .ad_vpp    (ad_origin_vpp),    // AD峰峰值
  //   .ad_max    (ad_origin_max),    // AD最大值
  //   .ad_min    (ad_origin_min)     // AD最小值
  // );


  // wave_point_cnt u_wave_point_cnt (
  //   .ad_clk  (ad_clk),
  //   .rst_n   (sys_rst_n),
  //   .ad_pulse(ad_origin_pulse),
  //   .ad_data (ad_data),
  //   .ad_freq (ad_freq),
  //   .ad_max  (ad_origin_max),
  //   .squ_wave(squ_wave)
  // );


  fir_top u_fir_top (
    .rstn (rst_n),    //复位，低有效
    .clk  (ad_clk),   //工作频率，即采样频率
    .en   (fir_en),   //输入数据有效信号
    .xin  (ad_data),  //输入混合频率的信号数据
    .valid(),         //输出数据有效信号
    .yout (yout)      //输出数据，低频信号，即250KHz
  );



  assign ad_data_out = fir_en ? ad_filter_data : ad_data;
endmodule
