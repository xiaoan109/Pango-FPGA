module grid_display (
  input         rst_n,
  input         pclk,
  input         i_hs,
  input         i_vs,
  input         i_de,
  input  [23:0] i_data,
  output        o_hs,
  output        o_vs,
  output        o_de,
  output [23:0] o_data
);
  wire [11:0] pos_x;
  wire [11:0] pos_y;
  wire        pos_hs;
  wire        pos_vs;
  wire        pos_de;
  wire [23:0] pos_data;
  reg  [23:0] v_data;
  reg  [ 3:0] grid_x;
  reg  [ 6:0] grid_y;
  reg         region_active;

  assign o_data = v_data;
  assign o_hs   = pos_hs;
  assign o_vs   = pos_vs;
  assign o_de   = pos_de;
  always @(posedge pclk) begin
    if (pos_y >= 12'd9 && pos_y <= 12'd1075 && pos_x >= 12'd442 && pos_x <= 12'd1521)
      region_active <= 1'b1;
    else region_active <= 1'b0;
  end

  always @(posedge pclk) begin
    if (region_active == 1'b1 && pos_de == 1'b1) grid_x <= (grid_x == 4'd7) ? 4'd0 : grid_x + 4'd1;
    else grid_x <= 4'd0;
  end

  always @(posedge pclk) begin
    if((region_active == 1'b1 && pos_de == 1'b1)&&((pos_y <= 12'd1055) && (pos_y >= 12'd32))&&(pos_x  == 12'd1521))
      grid_y <= (grid_y == 7'd101) ? 7'd0 : grid_y + 7'd1;
    else if (pos_y >= 12'd1055) grid_y <= 7'd0;
    else grid_y <= grid_y;
  end


  always @(posedge pclk) begin
    if (region_active == 1'b1)
      if(((pos_y == 12'd1055) || (pos_y == 12'd32) || (grid_y == 7'd101) || ((pos_y < 12'd1055 && pos_y > 12'd32) && (grid_x == 4'd7)&& pos_y[0] == 1'b1))&&(pos_y != 12'd541))
        v_data <= {8'd100, 8'd100, 8'd0};
      else if(((pos_y == 12'd1055) || (pos_y == 12'd32) || (grid_y == 7'd101) || ((pos_y < 12'd1055 && pos_y > 12'd32) && (grid_x == 4'd7)&& pos_y[0] == 1'b1))&&(pos_y == 12'd541))
        v_data <= {8'd255, 8'd215, 8'd0};
      else v_data <= 24'h000000;
    else v_data <= pos_data;
  end

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
