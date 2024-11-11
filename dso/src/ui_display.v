module ui_display (
  input  wire        rst_n,  //!系统复位，低电平有效
  input  wire        pclk,  //!HDMI像素时钟
  input  wire        ad_clk, //!ADC采样时钟
  input  wire        sys_clk,   //!系统时钟50MHz
  input  wire        i_hs, //!HDMI输入行同步信号
  input  wire        i_vs, //!HDMI输入场同步信号
  input  wire        i_de, //!HDMI输入数据有效信号
  input  wire [23:0] i_data,   //!HDMI输入数据RGB通道
  input  wire [19:0] ad_freq, //!ADC信号的频率
  input  wire [ 7:0] ad_vpp,  //!ADC信号峰峰值
  input  wire [ 7:0] ad_max,  //!ADC信号最大值
  input  wire [ 7:0] ad_min,  //!ADC信号最小值
  input  wire [ 7:0] trig_level, //!示波器触发电平(0-255对应-5~5V)
  input  wire        trig_edge, //!示波器触发类型(上升/下降)
  input  wire        fft_en, //!FFT频域显示开关
  input  wire [ 9:0] deci_rate,//!示波器抽样率
  input  wire        fir_en,  //!FIR低通滤波开关
  input  wire [ 4:0] v_scale,//!示波器垂直缩放倍数(1/2/4倍)
  output wire        o_hs,//!HDMI输出行同步信号
  output wire        o_vs,//!HDMI输出场同步信号
  output wire        o_de,//!HDMI输出数据有效信号
  output wire [23:0] o_data //!HDMI输出数据RGB通道
);


  wire [             23:0] freq_data_out;
  wire                     freq_vs_out;
  wire                     freq_hs_out;
  wire                     freq_de_out;

  wire [             23:0] vpp_data_out;
  wire                     vpp_vs_out;
  wire                     vpp_hs_out;
  wire                     vpp_de_out;

  wire [             23:0] vmax_data_out;
  wire                     vmax_vs_out;
  wire                     vmax_hs_out;
  wire                     vmax_de_out;

  wire [             23:0] vmin_data_out;
  wire                     vmin_vs_out;
  wire                     vmin_hs_out;
  wire                     vmin_de_out;

  wire [             23:0] vtrig_data_out;
  wire                     vtrig_vs_out;
  wire                     vtrig_hs_out;
  wire                     vtrig_de_out;

  wire [             23:0] tedge_data_out;
  wire                     tedge_vs_out;
  wire                     tedge_hs_out;
  wire                     tedge_de_out;

  wire [             23:0] deci_data_out;
  wire                     deci_vs_out;
  wire                     deci_hs_out;
  wire                     deci_de_out;

  wire [             23:0] fft_data_out;
  wire                     fft_vs_out;
  wire                     fft_hs_out;
  wire                     fft_de_out;

  wire [             23:0] fir_data_out;
  wire                     fir_vs_out;
  wire                     fir_hs_out;
  wire                     fir_de_out;
  
  wire [             23:0] vscale_data_out;
  wire                     vscale_vs_out;
  wire                     vscale_hs_out;
  wire                     vscale_de_out;

  wire [        8*1*8-1:0] disp_freq;

  wire [        2*1*8-1:0] disp_vpp_i;
  wire [        8*1*8-1:0] disp_vpp_f;

  wire [        2*1*8-1:0] disp_vmax_i;
  wire [        8*1*8-1:0] disp_vmax_f;

  wire [        2*1*8-1:0] disp_vmin_i;
  wire [        8*1*8-1:0] disp_vmin_f;

  wire [        2*1*8-1:0] disp_vtrig_i;
  wire [        8*1*8-1:0] disp_vtrig_f;

  wire [        4*1*8-1:0] disp_deci_rate;
  
  wire [        1*1*8-1:0] disp_v_scale;

  wire [            8-1:0] vpp_i_out;
  wire [$clog2(10**8)-1:0] vpp_f_out;

  wire [            8-1:0] vmax_i_out;
  wire [$clog2(10**8)-1:0] vmax_f_out;
  wire                     vmax_minus;

  wire [            8-1:0] vmin_i_out;
  wire [$clog2(10**8)-1:0] vmin_f_out;
  wire                     vmin_minus;

  wire [            8-1:0] vtrig_i_out;
  wire [$clog2(10**8)-1:0] vtrig_f_out;
  wire                     vtrig_minus;


  wire [              9:0] osd_addr_req;
  wire [             12:0] osd_rd_addr    [9:0];
  wire [             15:0] osd_rd_data    [9:0];

  volt2num #(
    .IW    (8),
    .FW    (8),
    .OFFSET(0)
  ) u0_volt2num (
    .clk         (ad_clk),
    .rst_n       (rst_n),
    .v_in        ({ad_vpp, 8'b0}),
    .i_out       (vpp_i_out),
    .f_out       (vpp_f_out),
    .offset_minus()
  );

  volt2num #(
    .IW    (8),
    .FW    (8),
    .OFFSET(1)
  ) u1_volt2num (
    .clk         (ad_clk),
    .rst_n       (rst_n),
    .v_in        ({ad_max, 8'b0}),
    .i_out       (vmax_i_out),
    .f_out       (vmax_f_out),
    .offset_minus(vmax_minus)
  );

  volt2num #(
    .IW    (8),
    .FW    (8),
    .OFFSET(1)
  ) u2_volt2num (
    .clk         (ad_clk),
    .rst_n       (rst_n),
    .v_in        ({ad_min, 8'b0}),
    .i_out       (vmin_i_out),
    .f_out       (vmin_f_out),
    .offset_minus(vmin_minus)
  );

  volt2num #(
    .IW    (8),
    .FW    (8),
    .OFFSET(1)
  ) u3_volt2num (
    .clk         (ad_clk),
    .rst_n       (rst_n),
    .v_in        ({trig_level, 8'b0}),
    .i_out       (vtrig_i_out),
    .f_out       (vtrig_f_out),
    .offset_minus(vtrig_minus)
  );

  num2str #(
    .DATA_WIDTH   (20),
    .MAX_NUM      (8),
    .LEADING_ZEROS(0)
  ) u0_num2str (
    .clk     (sys_clk),
    .rst_n   (rst_n),
    .data_in (ad_freq),
    .data_out(disp_freq)
  );

  num2str #(
    .DATA_WIDTH   (8),
    .MAX_NUM      (2),
    .LEADING_ZEROS(0)
  ) u1_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vpp_i_out),
    .data_out(disp_vpp_i)
  );


  num2str #(
    .DATA_WIDTH   ($clog2(10 ** 8)),
    .MAX_NUM      (8),
    .LEADING_ZEROS(1)
  ) u2_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vpp_f_out),
    .data_out(disp_vpp_f)
  );


  assign disp_vmax_i[1*8+:8] = vmax_minus ? "-" : " ";
  num2str #(
    .DATA_WIDTH   (8),
    .MAX_NUM      (1),
    .LEADING_ZEROS(0)
  ) u3_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vmax_i_out),
    .data_out(disp_vmax_i[0*8+:8])
  );


  num2str #(
    .DATA_WIDTH   ($clog2(10 ** 8)),
    .MAX_NUM      (8),
    .LEADING_ZEROS(1)
  ) u4_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vmax_f_out),
    .data_out(disp_vmax_f)
  );


  assign disp_vmin_i[1*8+:8] = vmin_minus ? "-" : " ";
  num2str #(
    .DATA_WIDTH   (8),
    .MAX_NUM      (1),
    .LEADING_ZEROS(0)
  ) u5_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vmin_i_out),
    .data_out(disp_vmin_i[0*8+:8])
  );


  num2str #(
    .DATA_WIDTH   ($clog2(10 ** 8)),
    .MAX_NUM      (8),
    .LEADING_ZEROS(1)
  ) u6_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vmin_f_out),
    .data_out(disp_vmin_f)
  );

  assign disp_vtrig_i[1*8+:8] = vtrig_minus ? "-" : " ";
  num2str #(
    .DATA_WIDTH   (8),
    .MAX_NUM      (1),
    .LEADING_ZEROS(0)
  ) u7_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vtrig_i_out),
    .data_out(disp_vtrig_i[0*8+:8])
  );


  num2str #(
    .DATA_WIDTH   ($clog2(10 ** 8)),
    .MAX_NUM      (8),
    .LEADING_ZEROS(1)
  ) u8_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (vtrig_f_out),
    .data_out(disp_vtrig_f)
  );

  num2str #(
    .DATA_WIDTH   (10),
    .MAX_NUM      (4),
    .LEADING_ZEROS(0)
  ) u9_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (deci_rate),
    .data_out(disp_deci_rate)
  );
  
  num2str #(
    .DATA_WIDTH   (4),
    .MAX_NUM      (1),
    .LEADING_ZEROS(0)
  ) u10_num2str (
    .clk     (ad_clk),
    .rst_n   (rst_n),
    .data_in (v_scale[3:0]),
    .data_out(disp_v_scale)
  );




  char_display #(
    .X_START(50),
    .Y_START(50),
    .X_NUM  (16),
    .Y_NUM  (1)
  ) u0_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (i_hs),
    .i_vs      (i_vs),
    .i_de      (i_de),
    .i_data    (i_data),
    .i_char_arr({"FREQ:", disp_freq, " Hz"}),
    .o_hs      (freq_hs_out),
    .o_vs      (freq_vs_out),
    .o_de      (freq_de_out),
    .o_data    (freq_data_out),
    .o_addr_req(osd_addr_req[0]),
    .o_rd_addr (osd_rd_addr[0]),
    .i_rd_data (osd_rd_data[0])
  );

  char_display #(
    .X_START(50),
    .Y_START(100),
    .X_NUM  (15),
    .Y_NUM  (1)
  ) u1_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (freq_hs_out),
    .i_vs      (freq_vs_out),
    .i_de      (freq_de_out),
    .i_data    (freq_data_out),
    .i_char_arr({"Vpp :  ", disp_vpp_i, ".", disp_vpp_f[8*8-1-:3*8], " V"}),
    .o_hs      (vpp_hs_out),
    .o_vs      (vpp_vs_out),
    .o_de      (vpp_de_out),
    .o_data    (vpp_data_out),
    .o_addr_req(osd_addr_req[1]),
    .o_rd_addr (osd_rd_addr[1]),
    .i_rd_data (osd_rd_data[1])
  );

  char_display #(
    .X_START(50),
    .Y_START(150),
    .X_NUM  (15),
    .Y_NUM  (1)
  ) u2_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (vpp_hs_out),
    .i_vs      (vpp_vs_out),
    .i_de      (vpp_de_out),
    .i_data    (vpp_data_out),
    .i_char_arr({"Vmax:  ", disp_vmax_i, ".", disp_vmax_f[8*8-1-:3*8], " V"}),
    .o_hs      (vmax_hs_out),
    .o_vs      (vmax_vs_out),
    .o_de      (vmax_de_out),
    .o_data    (vmax_data_out),
    .o_addr_req(osd_addr_req[2]),
    .o_rd_addr (osd_rd_addr[2]),
    .i_rd_data (osd_rd_data[2])
  );

  char_display #(
    .X_START(50),
    .Y_START(200),
    .X_NUM  (15),
    .Y_NUM  (1)
  ) u3_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (vmax_hs_out),
    .i_vs      (vmax_vs_out),
    .i_de      (vmax_de_out),
    .i_data    (vmax_data_out),
    .i_char_arr({"Vmin:  ", disp_vmin_i, ".", disp_vmin_f[8*8-1-:3*8], " V"}),
    .o_hs      (vmin_hs_out),
    .o_vs      (vmin_vs_out),
    .o_de      (vmin_de_out),
    .o_data    (vmin_data_out),
    .o_addr_req(osd_addr_req[3]),
    .o_rd_addr (osd_rd_addr[3]),
    .i_rd_data (osd_rd_data[3])
  );

  char_display #(
    .X_START(50),
    .Y_START(250),
    .X_NUM  (20),
    .Y_NUM  (1)
  ) u4_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (vmin_hs_out),
    .i_vs      (vmin_vs_out),
    .i_de      (vmin_de_out),
    .i_data    (vmin_data_out),
    .i_char_arr({"Trig Level: ", disp_vtrig_i, ".", disp_vtrig_f[8*8-1-:3*8], " V"}),
    .o_hs      (vtrig_hs_out),
    .o_vs      (vtrig_vs_out),
    .o_de      (vtrig_de_out),
    .o_data    (vtrig_data_out),
    .o_addr_req(osd_addr_req[4]),
    .o_rd_addr (osd_rd_addr[4]),
    .i_rd_data (osd_rd_data[4])
  );

  char_display #(
    .X_START(50),
    .Y_START(300),
    .X_NUM  (18),
    .Y_NUM  (1)
  ) u5_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (vtrig_hs_out),
    .i_vs      (vtrig_vs_out),
    .i_de      (vtrig_de_out),
    .i_data    (vtrig_data_out),
    .i_char_arr({"Trig Edge: ", trig_edge ? "Rising " : "Falling"}),
    .o_hs      (tedge_hs_out),
    .o_vs      (tedge_vs_out),
    .o_de      (tedge_de_out),
    .o_data    (tedge_data_out),
    .o_addr_req(osd_addr_req[5]),
    .o_rd_addr (osd_rd_addr[5]),
    .i_rd_data (osd_rd_data[5])
  );


  char_display #(
    .X_START(50),
    .Y_START(350),
    .X_NUM  (16),
    .Y_NUM  (1)
  ) u6_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (tedge_hs_out),
    .i_vs      (tedge_vs_out),
    .i_de      (tedge_de_out),
    .i_data    (tedge_data_out),
    .i_char_arr({"Deci Rate: ", disp_deci_rate, "x"}),
    .o_hs      (deci_hs_out),
    .o_vs      (deci_vs_out),
    .o_de      (deci_de_out),
    .o_data    (deci_data_out),
    .o_addr_req(osd_addr_req[6]),
    .o_rd_addr (osd_rd_addr[6]),
    .i_rd_data (osd_rd_data[6])
  );

  char_display #(
    .X_START(50),
    .Y_START(400),
    .X_NUM  (8),
    .Y_NUM  (1)
  ) u7_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (deci_hs_out),
    .i_vs      (deci_vs_out),
    .i_de      (deci_de_out),
    .i_data    (deci_data_out),
    .i_char_arr({"FFT: ", fft_en ? " ON" : "OFF"}),
    .o_hs      (fft_hs_out),
    .o_vs      (fft_vs_out),
    .o_de      (fft_de_out),
    .o_data    (fft_data_out),
    .o_addr_req(osd_addr_req[7]),
    .o_rd_addr (osd_rd_addr[7]),
    .i_rd_data (osd_rd_data[7])
  );

  char_display #(
    .X_START(50),
    .Y_START(450),
    .X_NUM  (8),
    .Y_NUM  (1)
  ) u8_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (fft_hs_out),
    .i_vs      (fft_vs_out),
    .i_de      (fft_de_out),
    .i_data    (fft_data_out),
    .i_char_arr({"FIR: ", fir_en ? " ON" : "OFF"}),
    .o_hs      (fir_hs_out),
    .o_vs      (fir_vs_out),
    .o_de      (fir_de_out),
    .o_data    (fir_data_out),
    .o_addr_req(osd_addr_req[8]),
    .o_rd_addr (osd_rd_addr[8]),
    .i_rd_data (osd_rd_data[8])
  );
  
  char_display #(
    .X_START(50),
    .Y_START(500),
    .X_NUM  (13),
    .Y_NUM  (1)
  ) u9_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (fir_hs_out),
    .i_vs      (fir_vs_out),
    .i_de      (fir_de_out),
    .i_data    (fir_data_out),
    .i_char_arr({"V_SCALE: ", v_scale[4] ? "  " : "1/", disp_v_scale, "x"}),
    .o_hs      (vscale_hs_out),
    .o_vs      (vscale_vs_out),
    .o_de      (vscale_de_out),
    .o_data    (vscale_data_out),
    .o_addr_req(osd_addr_req[9]),
    .o_rd_addr (osd_rd_addr[9]),
    .i_rd_data (osd_rd_data[9])
  );

  osd_rom_multiport #(
    .PORT_NUM(10)
  ) u_osd_rom_multiport (
    .i_clk(pclk),
    .i_rst_n(rst_n),
    .i_addr_req(osd_addr_req),  // one-hot
    .i_rd_addr({
      osd_rd_addr[9],
      osd_rd_addr[8],
      osd_rd_addr[7],
      osd_rd_addr[6],
      osd_rd_addr[5],
      osd_rd_addr[4],
      osd_rd_addr[3],
      osd_rd_addr[2],
      osd_rd_addr[1],
      osd_rd_addr[0]
    }),
    .o_rd_data({
	  osd_rd_data[9],
      osd_rd_data[8],
      osd_rd_data[7],
      osd_rd_data[6],
      osd_rd_data[5],
      osd_rd_data[4],
      osd_rd_data[3],
      osd_rd_data[2],
      osd_rd_data[1],
      osd_rd_data[0]
    })
  );


  assign o_hs   = vscale_hs_out;
  assign o_vs   = vscale_vs_out;
  assign o_de   = vscale_de_out;
  assign o_data = vscale_data_out;
endmodule
