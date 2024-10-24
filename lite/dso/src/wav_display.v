module wav_display (
  input         rst_n,
  input         pclk,
  input  [23:0] wave_color,
  input         ad_clk,
  input         ad_buf_wr,
  input  [11:0] ad_buf_wr_addr,
  input  [ 7:0] ad_buf_data,
  output [11:0] wave_rd_addr,
  input  [11:0] ad_buf_rd_addr,
  input         fft_en,
  input  [11:0] ram_rd_data,
  input         i_hs,
  input         i_vs,
  input         i_de,
  input  [23:0] i_data,
  output        o_hs  /* synthesis PAP_MARK_DEBUG="true" */,
  output        o_vs  /* synthesis PAP_MARK_DEBUG="true" */,
  output        o_de  /* synthesis PAP_MARK_DEBUG="true" */,
  output [23:0] o_data  /* synthesis PAP_MARK_DEBUG="true" */,
  output        wr_over,
  input  [ 4:0] v_scale
);

  wire [11:0] pos_x;
  wire [11:0] pos_y;
  wire        pos_hs;
  wire        pos_vs;
  wire        pos_de;
  wire [23:0] pos_data;
  reg  [23:0] v_data;
  reg  [ 9:0] rdaddress  /* synthesis PAP_MARK_DEBUG="true" */;
  wire [ 7:0] q  /* synthesis PAP_MARK_DEBUG="true" */;
  reg         region_active  /* synthesis PAP_MARK_DEBUG="true" */;
  // wire [11:0] ref_sig  /* synthesis PAP_MARK_DEBUG="true" */;
  // assign ref_sig = 12'd287 - q[7:0];
  // wire ref_sig2  /* synthesis PAP_MARK_DEBUG="true" */; 
  // assign ref_sig2 = ((region_active == 1'b1) && (12'd287 - pos_y == {4'd0, q[7:0]})) ? 1'b1 : 1'b0;
  // wire [9:0] ref_rd_addr  /* synthesis PAP_MARK_DEBUG="true" */;
  // assign ref_rd_addr = rdaddress[9:0];
  wire [11:0] wave_data;
  wire [11:0] scale_data;
  wire [11:0] fft_data;
  wire [11:0] sel_data;
  reg  [11:0] pre_data;
  assign wave_data = {4'd0, 8'd255 - q};
  assign scale_data = v_scale[4] ?  (12'd533 + ((wave_data - 12'd128) << v_scale[3:1])): (12'd533 + ((wave_data - 12'd128) >> v_scale[3:1]));  // 1/2/4 scale
  assign fft_data = (12'd4095 - ram_rd_data) >> 2;
  assign sel_data = fft_en ? fft_data : scale_data;

  assign o_data = v_data;
  assign o_hs = pos_hs;
  assign o_vs = pos_vs;
  assign o_de = pos_de;

  always @(posedge pclk) begin
    if (pos_y >= 12'd9 && pos_y <= 12'd1075 && pos_x >= 12'd442 && pos_x <= 12'd1522)
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
      else v_data <= pos_data;
    else v_data <= pos_data;

  end

  always @(posedge pclk) begin
    if (region_active == 1'b1) pre_data <= sel_data;
  end

  assign wave_rd_addr = rdaddress;

  //标志一帧波形绘制完毕
  assign wr_over = (pos_x == 12'd1522) && (pos_y == 12'd1075);

  ram1024x8 u_ram (
    .wr_data(ad_buf_data),          // input [7:0]
    .wr_addr(ad_buf_wr_addr[9:0]),  // input [9:0]
    .wr_en  (ad_buf_wr),            // input
    .wr_clk (ad_clk),               // input
    .wr_rst (~rst_n),               // input
    .rd_addr(ad_buf_rd_addr[9:0]),  // input [9:0]
    .rd_data(q),                    // output [7:0]
    .rd_clk (pclk),                 // input
    .rd_rst (~rst_n)                // input
  );


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
