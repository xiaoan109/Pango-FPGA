module decimator (
  input wire ad_clk,
  input wire rst_n,
  input wire [9:0] deci_rate,
  output reg deci_valid
);
  reg [9:0] deci_cnt;

  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      deci_cnt <= 10'd0;
    end else if (deci_cnt == deci_rate - 1) begin
      deci_cnt <= 10'd0;
    end else begin
      deci_cnt <= deci_cnt + 1'b1;
    end
  end

  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      deci_valid <= 1'b0;
    end else if (deci_cnt == deci_rate - 1) begin
      deci_valid <= 1'b1;
    end else begin
      deci_valid <= 1'b0;
    end
  end
endmodule
