module ad_pulse_gen (
  input wire rst_n,  //系统复位，低电平有效

  input wire [7:0] trig_level,
  input wire       ad_clk,      //ADC驱动时钟
  input wire [7:0] ad_data,     //ADC输入数据

  output wire ad_pulse  //输出的脉冲信号
);

  parameter THR_DATA = 3;  //抖动阈值

  //reg define
  reg pulse;
  reg pulse_delay;

  reg [7:0] pre_data;
  reg [7:0] pre_data1;

  assign ad_pulse = pulse & pulse_delay;

  //寄存AD数据，用于判断触发条件
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      pre_data  <= 8'd0;
      pre_data1 <= 8'd0;
    end else begin
      pre_data  <= ad_data;
      pre_data1 <= pre_data;
    end
  end


  //根据触发电平，将输入的AD采样值转换成高低电平
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      pulse <= 1'b0;
    end else begin
      if ((trig_level >= THR_DATA) && (pre_data < trig_level - THR_DATA) &&  (pre_data1 < trig_level - THR_DATA) &&  (ad_data < trig_level - THR_DATA)) begin
        pulse <= 1'b0;
      end else if ((pre_data > trig_level + THR_DATA) && (pre_data1 > trig_level + THR_DATA) && (ad_data > trig_level + THR_DATA)) begin
        pulse <= 1'b1;
      end
    end
  end

  //延时一个时钟周期，用于消除抖动
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      pulse_delay <= 1'b0;
    end else begin
      pulse_delay <= pulse;
    end
  end

endmodule
