module osd_rom_multiport #(
  parameter PORT_NUM = 5
) (
  input  wire                   i_clk,
  input  wire                   i_rst_n,
  input  wire [   PORT_NUM-1:0] i_addr_req,  // one-hot
  input  wire [PORT_NUM*13-1:0] i_rd_addr,
  output wire [PORT_NUM*16-1:0] o_rd_data
);


  reg     [12:0] rd_addr_sel;
  wire    [15:0] rd_data;

  //   assign rd_addr_sel = i_rd_addr[i_addr_req*13+:13];

  integer        i;
  always @(*) begin : encoder
    for (i = PORT_NUM - 1; i >= 0; i = i - 1) begin
      if (i_addr_req[i] == 1) begin
        rd_addr_sel = i_rd_addr[i*13+:13];
        disable encoder;
      end else begin
        rd_addr_sel = 13'b0;
      end
    end
  end

  genvar j;
  generate
    for (j = 0; j < PORT_NUM; j = j + 1) begin : gen_data
      assign o_rd_data[j*16+:16] = i_addr_req[j] ? rd_data : 16'b0;
    end
  endgenerate

  osd_rom u_osd_rom (
    .addr   (rd_addr_sel),  // input [12:0]
    .clk    (i_clk),        // input
    .rst    (!i_rst_n),     // input
    .rd_data(rd_data)       // output [15:0]
  );
endmodule
