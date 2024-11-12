module char_display #(
  parameter X_START = 5,
  parameter Y_START = 5,
  parameter X_NUM   = 1,
  parameter Y_NUM   = 1
) (
  input                      rst_n,
  input                      pclk,
  input                      i_hs,
  input                      i_vs,
  input                      i_de,
  input  [             23:0] i_data,
  input  [X_NUM*Y_NUM*8-1:0] i_char_arr,
  output                     o_hs,
  output                     o_vs,
  output                     o_de,
  output [             23:0] o_data,
  output                     o_addr_req,
  output [             12:0] o_rd_addr,
  input  [             15:0] i_rd_data

);

  localparam X_END = X_START + 16 * X_NUM;
  localparam Y_END = Y_START + 32 * Y_NUM;
  localparam RED = 24'hff0000;
  localparam BLUE = 24'h0000ff;

  wire [                   11:0] pos_x;
  wire [                   11:0] pos_y;
  wire                           pos_hs;
  wire                           pos_vs;
  wire                           pos_de;
  wire [                   23:0] pos_data;
  reg  [                   23:0] v_data;
  reg                            region_active;
  reg                            region_active_d0;
  reg                            region_active_d1;
  reg                            region_active_d2;

  reg                            pos_vs_d0;
  reg                            pos_vs_d1;

  reg  [                    3:0] osd_x;
  reg  [                   12:0] osd_ram_addr;

  wire [                   15:0] rd_data;

  reg  [                    7:0] x_sel;
  reg  [                    7:0] y_sel;
  reg  [$clog2(X_NUM*Y_NUM)-1:0] arr_sel;

  assign o_data = v_data;
  assign o_hs   = pos_hs;
  assign o_vs   = pos_vs;
  assign o_de   = pos_de;

  //   assign x_sel  = (pos_x >= X_START && pos_x < X_END) ? (pos_x - X_START) / 9 : 8'b0;
  //   assign y_sel  = (pos_y >= Y_START && pos_y < Y_END) ? (pos_y - Y_START) / 16 : 8'b0;

  always @(posedge pclk) begin
    if (pos_y >= Y_START && pos_y < Y_END && pos_x >= X_START && pos_x < X_END)
      region_active <= 1'b1;
    else region_active <= 1'b0;
  end

  always @(posedge pclk) begin
    region_active_d0 <= region_active;
    region_active_d1 <= region_active_d0;
    region_active_d2 <= region_active_d1;
  end

  always @(posedge pclk) begin
    pos_vs_d0 <= pos_vs;
    pos_vs_d1 <= pos_vs_d0;
  end

  //delay 2 clock
  //region_active_d0
  always @(posedge pclk) begin
    if (region_active_d2 == 1'b1) osd_x <= osd_x + 4'd1;
    else osd_x <= 4'd0;
  end

  always @(posedge pclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      x_sel <= 8'b0;
      y_sel <= 8'b0;
    end else if (region_active == 1'b1) begin
      x_sel <= (pos_x - X_START) / 16;
      y_sel <= (pos_y - Y_START) / 32;
    end else begin
      x_sel <= 8'b0;
      y_sel <= 8'b0;
    end
  end

  always @(posedge pclk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      arr_sel <= 'b0;
    end else if (region_active_d0 == 1'b1) begin
      arr_sel <= X_NUM * Y_NUM - 1 - (x_sel + y_sel * X_NUM);
    end else begin
      arr_sel <= 'b0;
    end
  end

  always @(posedge pclk) begin
    if (pos_vs_d1 == 1'b1 && pos_vs_d0 == 1'b0) osd_ram_addr <= 13'd0;
    else if (region_active_d1 == 1'b1)
      osd_ram_addr <= (i_char_arr[arr_sel*8+:8] * 32) + (pos_y - Y_START) % 32;
  end

  always @(posedge pclk) begin
    if (region_active_d2 == 1'b1)
      if (rd_data[osd_x] == 1'b1) v_data <= RED;
      else v_data <= pos_data;
    else v_data <= pos_data;
  end

  assign o_addr_req = region_active_d2;
  assign o_rd_addr = osd_ram_addr;
  assign rd_data = i_rd_data;

  // osd_rom u_osd_rom (
  //   .addr   (osd_ram_addr),  // input [12:0]
  //   .clk    (pclk),          // input
  //   .rst    (!rst_n),        // input
  //   .rd_data(rd_data)        // output [15:0]
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
