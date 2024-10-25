module cdc (
  input clk1,
  input rst1_n,

  input clk2,
  input rst2_n,

  input a,

  output reg b_r,
  output     busy
);

  //--------------------------------------------
  reg  a_latch;
  reg  b_latch;
  reg  b_latch_r;
  reg  b_latch_2r;
  wire b;
  reg  b_feedback_latch;
  reg  c_latch;
  reg  c_latch_r;


  //--------------------------------------------
  //前面的代码与单比特脉冲从快到慢的跨时钟操作完全一致
  always @(posedge clk1 or negedge rst1_n) begin
    if (!rst1_n) a_latch <= 1'b0;
    else if (a)  //把a脉冲转为电平
      a_latch <= 1'b1;
    else if (c_latch_r)  //反馈使电平归零
      a_latch <= 1'b0;
  end

  always @(posedge clk2 or negedge rst2_n) begin
    if (!rst2_n) begin
      b_latch    <= 1'b0;
      b_latch_r  <= 1'b0;
      b_latch_2r <= 1'b0;
    end else begin
      b_latch    <= a_latch;
      b_latch_r  <= b_latch;  //电平跨时钟
      b_latch_2r <= b_latch_r;
    end
  end

  assign b = b_latch_r & (~b_latch_2r);  //提取电平上升沿，获得b

  always @(posedge clk2 or negedge rst2_n) begin
    if (!rst2_n) b_feedback_latch <= 1'b0;
    else if (b) b_feedback_latch <= 1'b1;  //反馈回clk1，让a_latch归零
    else if (~b_latch_r) b_feedback_latch <= 1'b0;
  end

  always @(posedge clk1 or negedge rst1_n) begin
    if (!rst1_n) begin
      c_latch   <= 1'b0;
      c_latch_r <= 1'b0;
    end else begin
      c_latch   <= b_feedback_latch;
      c_latch_r <= c_latch;  //反馈信号从clk2跨到clk1
    end
  end

  assign busy = a_latch | c_latch_r;  //反馈忙信号

  always @(posedge clk2 or negedge rst2_n) begin
    if (!rst2_n) b_r <= 1'b0;
    else b_r <= b;
  end

endmodule




