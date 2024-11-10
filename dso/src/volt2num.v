module volt2num #(
  parameter IW = 8,
  parameter FW = 8,
  parameter OFFSET = 0,
  parameter SCALE = 10 ** FW  //Do not modify!
) (
  input  wire                     clk,
  input  wire                     rst_n,
  input       [        IW+FW-1:0] v_in,
  output reg  [           IW-1:0] i_out,
  output reg  [$clog2(SCALE)-1:0] f_out,
  output wire                     offset_minus  //if minus after offset
);

  localparam [IW+FW-1:0] ADC_MAX = 10 << FW;
  localparam ADC_NUM = 256 << FW;

  reg [IW*2+FW*2-1:0] v_r0;
  reg [IW+FW-1:0] v_r1;
  reg [IW+FW-1:0] v_r2;
  reg [IW+FW-1:0] v_r3;
  wire [FW+$clog2(SCALE) -1:0] mult_tmp;


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      v_r0 <= 'b0;
      v_r1 <= 'b0;
    end else begin
      v_r0 <= (v_in * ADC_MAX) >> FW;
      v_r1 <= (v_r0 << FW) >> $clog2(ADC_NUM);
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      v_r2 <= 'b0;
      v_r3 <= 'b0;
    end else begin
      v_r2 <= v_r1 - {8'd5, 8'd0};
      v_r3 <= v_r2[IW+FW-1] ? (~v_r2 + 1'b1) : v_r2;
    end
  end

  assign mult_tmp = OFFSET ? (v_r3[FW-1:0] * SCALE) : (v_r1[FW-1:0] * SCALE);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      i_out <= 'b0;
      f_out <= 'b0;
    end else begin
      i_out <= OFFSET ? v_r3[IW+FW-1:FW] : v_r1[IW+FW-1:FW];
      f_out <= mult_tmp >> FW;
    end
  end

  assign offset_minus = v_r2[IW+FW-1];
endmodule
