module wave_point_cnt #(
  parameter ADC_CLK = 29700000
) (
  input  wire        ad_clk,
  input  wire        rst_n,
  input  wire        ad_pulse,
  input  wire [ 7:0] ad_data,
  input  wire [ 7:0] ad_max,
  input  wire [19:0] ad_freq,
  output reg         squ_wave
);

  localparam POINT_THRESHOLD = 10;

  //reg define
  reg cnt_flag;
  reg cnt_flag_d;

  reg [31:0] counter  /* synthesis PAP_MARK_DEBUG="true" */;
  reg [31:0] point_all;

  //wire define
  wire cnt_flag_pos;
  wire cnt_flag_neg;

  //边沿检测，捕获信号上升/下降沿
  assign cnt_flag_pos = (~cnt_flag_d) & cnt_flag;
  assign cnt_flag_neg = cnt_flag_d & (~cnt_flag);

  //利用cnt_flag标志一个被测时钟周期
  always @(posedge ad_pulse or negedge rst_n) begin
    if (!rst_n) cnt_flag <= 1'b0;
    else cnt_flag <= ~cnt_flag;
  end

  //将cnt_flag延时一个AD时钟周期
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) cnt_flag_d <= 1'b0;
    else cnt_flag_d <= cnt_flag;
  end

  //筛选一个被测时钟周期内ad_data>max/2的point
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 32'b0;
    end else if (cnt_flag_neg) begin
      counter <= 32'b0;
    end else if (cnt_flag) begin
      if (ad_data >= (128 + ((ad_max - 128) >> 1))) begin
        counter <= counter + 1'b1;
      end
    end
  end

  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      point_all <= 32'b0;
    end else begin
      point_all <= ADC_CLK / ad_freq;  // TODO: divider needed
    end
  end

  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      squ_wave <= 1'b0;
    end else if (cnt_flag_neg) begin
      if(counter >= (point_all >>1) - POINT_THRESHOLD && counter <= (point_all >>1) + POINT_THRESHOLD) begin
        squ_wave <= 1'b1;
      end else begin
        squ_wave <= 1'b0;
      end
    end
  end

endmodule
