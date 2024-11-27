module dso_wave_display (
  input  wire        rst_n,           //!系统复位，低电平有效
  input  wire        pclk,            //!HDMI像素时钟
  input  wire [23:0] wave_color,      //!波形绘制颜色
  // input  wire        ad_clk,          //!ADC采样时钟
  // input  wire        ad_buf_wr,       //!ADC采样RAM写使能
  // input  wire [11:0] ad_buf_wr_addr,  //!ADC采样RAM写地址
  // input  wire [7:0]  ad_buf_data,     //!ADC采样RAM写数据
  output wire [9:0] wave_rd_addr,    //!输出ADC采样RAM读地址
  input  wire [7:0]  ad_buf_rd_data,  //!输入ADC采样RAM读数据
  input  wire        fft_en,          //!FFT频域显示开启
  input  wire [11:0] ram_rd_data,     //!FFT RAM读数据
  input  wire        i_hs,            //!HDMI输入行同步信号
  input  wire        i_vs,            //!HDMI输入场同步信号
  input  wire        i_de,            //!HDMI输入数据有效信号
  input  wire [23:0] i_data,          //!HDMI输入数据RGB通道 
  output wire        o_hs,            //!HDMI输出行同步信号
  output wire        o_vs,            //!HDMI输出场同步信号
  output wire        o_de,            //!HDMI输出数据有效信号
  output wire [23:0] o_data,          //!HDMI输出数据RGB通道
  output wire        wr_over,         //!HDMI一帧绘制完成
  input  wire [ 4:0] v_scale,         //!示波器垂直缩放倍数
  input  wire [11:0] trig_line        //!触发电平绘制像素点
);

  localparam RED = 24'hff0000;
  localparam BLUE = 24'h0000ff;

  wire [11:0] pos_x;
  wire [11:0] pos_y;
  wire        pos_hs;
  wire        pos_vs;
  wire        pos_de;
  wire [23:0] pos_data;
  reg  [23:0] v_data;
  reg  [ 9:0] rdaddress  /* synthesis PAP_MARK_DEBUG="true" */;
  reg         region_active  /* synthesis PAP_MARK_DEBUG="true" */;
  wire [11:0] wave_data;
  // wire [11:0] scale_data;
  reg [11:0] scale_data;
  wire [11:0] fft_data;
  wire [11:0] sel_data;
  reg  [11:0] pre_data;
  // reg  [ 9:0] v_shift_t;
  reg  [ 4:0] v_scale_t;
  reg  [11:0] trig_line_t;
  
  assign wave_data = {4'd0, 8'd255 - ad_buf_rd_data};
  // assign scale_data = v_scale_t[4] ?  (12'd541 + ((wave_data - 12'd128) << v_scale_t[3:1])): (12'd541 + ((wave_data-12'd128)>> v_scale_t[3:1]));  // 1/2/4 scale
  always @(posedge pclk) begin
	scale_data = v_scale_t[4] ? (12'd541 + ((wave_data - 12'd128) << v_scale_t[3:1])): (12'd541 + ((wave_data>> v_scale_t[3:1]) - (12'd128>> v_scale_t[3:1]))); 
  end
  assign fft_data = (12'd4095 - ram_rd_data) >> 2;
  assign sel_data = fft_en ? fft_data : scale_data;

  assign o_data = v_data;
  assign o_hs = pos_hs;
  assign o_vs = pos_vs;
  assign o_de = pos_de;

  //寄存输入的参数
  always @(posedge pclk or negedge rst_n) begin
    if (!rst_n) begin
      // v_shift_t   <= 10'b0;
      v_scale_t   <= 5'b0;
      trig_line_t <= 12'b0;
    end else begin
      // v_shift_t   <= v_shift;
      v_scale_t   <= v_scale;
      trig_line_t <= trig_line;
    end
  end

  always @(posedge pclk) begin
    if (pos_y >= 12'd9 && pos_y <= 12'd1075 && pos_x >= 12'd442 && pos_x <= 12'd1465)
      region_active <= 1'b1;
    else region_active <= 1'b0;
  end

  always @(posedge pclk) begin
    if (region_active == 1'b1 && pos_de == 1'b1) rdaddress <= rdaddress + 10'd1;
    else rdaddress <= 10'd0;
  end

  always @(posedge pclk) begin
    if (region_active == 1'b1)
      if ((pos_y >= pre_data && pos_y <= sel_data) || (pos_y <= pre_data && pos_y >= sel_data))
        v_data <= wave_color;
      else if (pos_y == trig_line_t) v_data <= BLUE;
      else v_data <= pos_data;
    else v_data <= pos_data;

  end

  always @(posedge pclk) begin
    if (region_active == 1'b1) pre_data <= sel_data;
  end

  assign wave_rd_addr = rdaddress;

  //标志一帧波形绘制完毕
  assign wr_over = (pos_x == 12'd1465) && (pos_y == 12'd1075);

  // ram1024x8 u_ram (
    // .wr_data(ad_buf_data),          // input [7:0]
    // .wr_addr(ad_buf_wr_addr[9:0]),  // input [9:0]
    // .wr_en  (ad_buf_wr),            // input
    // .wr_clk (ad_clk),               // input
    // .wr_rst (~rst_n),               // input
    // .rd_addr(ad_buf_rd_addr[9:0]),  // input [9:0]
    // .rd_data(q),                    // output [7:0]
    // .rd_clk (pclk),                 // input
    // .rd_rst (~rst_n)                // input
  // );


  timing_gen_xy timing_gen_xy_m0 (
    .rst_n (rst_n),
    .clk   (pclk),
    .i_hs  (i_hs),
    .i_vs  (i_vs),
    .i_de  (i_de),
    .i_data(i_data),
    .o_hs  (pos_hs),
    .o_vs  (pos_vs),
    .o_de  (pos_de),
    .o_data(pos_data),
    .x     (pos_x),
    .y     (pos_y)
  );
endmodule
