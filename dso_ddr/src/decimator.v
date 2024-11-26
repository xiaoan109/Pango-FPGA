module decimator (
  input wire ad_clk,//!ADC采样时钟
  input wire rst_n, //!系统复位，低电平有效
  input wire [9:0] deci_rate, //!示波器抽样率
  output reg deci_valid //!示波器抽样有效信号
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
