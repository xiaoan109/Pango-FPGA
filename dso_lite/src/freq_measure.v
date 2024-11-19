module freq_measure #(
  parameter CLK_FS = 26'd50_000_000
)  // 基准时钟频率值
(  //system clock
  input wire clk_fs,  // 基准时钟信号
  input wire rst_n,   // 复位信号

  //cymometer interface
  input  wire        clk_fx,  // 被测时钟信号
  output reg  [19:0] data_fx  // 被测时钟频率输出
);

  //parameter define
  localparam MAX = 30;  // 定义fs_cnt、fx_cnt的最大位宽
  localparam GATE_TIME = 16'd2_000;  // 门控时间设置

  //reg define
  reg            gate;  // 门控信号
  reg            gate_fs;  // 同步到基准时钟的门控信号
  reg            gate_fs_r;  // 用于同步gate信号的寄存器
  reg            gate_fs_d0;  // 用于采集基准时钟下gate下降沿
  reg            gate_fs_d1;  // 
  reg            gate_fx_d0;  // 用于采集被测时钟下gate下降沿
  reg            gate_fx_d1;  // 
  reg  [   58:0] data_fx_t;  // 
  reg  [   15:0] gate_cnt;  // 门控计数
  reg  [MAX-1:0] fs_cnt;  // 门控时间内基准时钟的计数值
  reg  [MAX-1:0] fs_cnt_temp;  // fs_cnt 临时值
  reg  [MAX-1:0] fx_cnt;  // 门控时间内被测时钟的计数值
  reg  [MAX-1:0] fx_cnt_temp;  // fx_cnt 临时值

  //wire define
  wire           neg_gate_fs;  // 基准时钟下门控信号下降沿
  wire           neg_gate_fx;  // 被测时钟下门控信号下降沿

  //边沿检测，捕获信号下降沿
  assign neg_gate_fs = gate_fs_d1 & (~gate_fs_d0);
  assign neg_gate_fx = gate_fx_d1 & (~gate_fx_d0);

  //门控信号计数器，使用被测时钟计数
  always @(posedge clk_fx or negedge rst_n) begin
    if (!rst_n) begin
      gate_cnt <= 16'd0;
    end else if (gate_cnt == GATE_TIME + 5'd20) begin
      gate_cnt <= 16'd0;
    end else begin
      gate_cnt <= gate_cnt + 1'b1;
    end
  end

  //门控信号，拉高时间为GATE_TIME个实测时钟周期
  always @(posedge clk_fx or negedge rst_n) begin
    if (!rst_n) begin
      gate <= 1'b0;
    end else if (gate_cnt < 4'd10) begin
      gate <= 1'b0;
    end else if (gate_cnt < GATE_TIME + 4'd10) begin
      gate <= 1'b1;
    end else if (gate_cnt <= GATE_TIME + 5'd20) begin
      gate <= 1'b0;
    end else begin
      gate <= 1'b0;
    end
  end

  //将门控信号同步到基准时钟下
  always @(posedge clk_fs or negedge rst_n) begin
    if (!rst_n) begin
      gate_fs_r <= 1'b0;
      gate_fs   <= 1'b0;
    end else begin
      gate_fs_r <= gate;
      gate_fs   <= gate_fs_r;
    end
  end

  //打拍采门控信号的下降沿（被测时钟下）
  always @(posedge clk_fx or negedge rst_n) begin
    if (!rst_n) begin
      gate_fx_d0 <= 1'b0;
      gate_fx_d1 <= 1'b0;
    end else begin
      gate_fx_d0 <= gate;
      gate_fx_d1 <= gate_fx_d0;
    end
  end

  //打拍采门控信号的下降沿（基准时钟下）
  always @(posedge clk_fs or negedge rst_n) begin
    if (!rst_n) begin
      gate_fs_d0 <= 1'b0;
      gate_fs_d1 <= 1'b0;
    end else begin
      gate_fs_d0 <= gate_fs;
      gate_fs_d1 <= gate_fs_d0;
    end
  end

  //门控时间内对被测时钟计数
  always @(posedge clk_fx or negedge rst_n) begin
    if (!rst_n) begin
      fx_cnt_temp <= 32'd0;
      fx_cnt <= 32'd0;
    end else if (gate) begin
      fx_cnt_temp <= fx_cnt_temp + 1'b1;
    end else if (neg_gate_fx) begin
      fx_cnt_temp <= 32'd0;
      fx_cnt <= fx_cnt_temp;
    end
  end

  //门控时间内对基准时钟计数
  always @(posedge clk_fs or negedge rst_n) begin
    if (!rst_n) begin
      fs_cnt_temp <= 32'd0;
      fs_cnt <= 32'd0;
    end else if (gate_fs) begin
      fs_cnt_temp <= fs_cnt_temp + 1'b1;
    end else if (neg_gate_fs) begin
      fs_cnt_temp <= 32'd0;
      fs_cnt <= fs_cnt_temp;
    end
  end

  //计算被测信号频率
  always @(posedge clk_fs or negedge rst_n) begin
    if (!rst_n) begin
      data_fx_t <= 1'b0;
    end else if (gate_fs == 1'b0) begin
      data_fx_t <= CLK_FS * fx_cnt;
    end
  end

  always @(posedge clk_fs or negedge rst_n) begin
    if (!rst_n) begin
      data_fx <= 20'd0;
    end else if (gate_fs == 1'b0) begin
      data_fx <= data_fx_t / fs_cnt;
    end
  end

endmodule
