// Created by IP Generator (Version 2022.1 build 99559)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


ram_2port the_instance_name (
  .a_addr(a_addr),          // input [11:0]
  .a_wr_data(a_wr_data),    // input [7:0]
  .a_rd_data(a_rd_data),    // output [7:0]
  .a_wr_en(a_wr_en),        // input
  .a_clk(a_clk),            // input
  .a_clk_en(a_clk_en),      // input
  .a_rst(a_rst),            // input
  .b_addr(b_addr),          // input [11:0]
  .b_wr_data(b_wr_data),    // input [7:0]
  .b_rd_data(b_rd_data),    // output [7:0]
  .b_wr_en(b_wr_en),        // input
  .b_clk(b_clk),            // input
  .b_clk_en(b_clk_en),      // input
  .b_rst(b_rst)             // input
);
