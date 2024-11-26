module data_store (
  input rst_n,  // 复位信号

  input [7:0] trig_level,  // 触发电平
  input       trig_edge,   // 触发边沿
  input       wave_run,    // 波形采集启动/停止
  input [9:0] h_shift,     // 波形水平偏移量

  input       ad_clk,     // AD时钟
  input [7:0] ad_data,    // AD输入数据
  input       deci_valid, // 抽样有效信号

  input             hdmi_pclk,
  input             hdmi_wr_over,
  input             wave_data_req,
  input      [11:0] wave_rd_addr,
  output     [ 7:0] wave_rd_data,
  output reg        outrange        //水平偏移超出范围
);

  //parameter define
  parameter WAVE_DEPTH = 12'd900;
  parameter HALF_WAVE_DEPTH = WAVE_DEPTH >> 1;

  //reg define
  reg  [11:0] wr_addr;  //RAM写地址
  reg         ram_aclr;  //RAM清除

  reg         trig_flag;  //触发标志
  reg         trig_en;  //触发使能
  reg  [11:0] trig_addr;  //触发地址

  reg  [ 7:0] pre_data;
  reg  [ 7:0] pre_data1;
  reg  [ 7:0] pre_data2;
  reg  [11:0] data_cnt;

  //wire define
  wire        wr_en;  //RAM写使能
  wire [12:0] rd_addr;  //RAM地址
  wire [12:0] rel_addr;  //相对触发地址
  wire [12:0] shift_addr;  //偏移后的地址
  wire        trig_pulse;  //满足触发条件时产生脉冲
  wire [ 7:0] rd_ram_data;

  assign wr_en = deci_valid && (data_cnt <= WAVE_DEPTH - 1) && wave_run;

  //计算波形水平偏移后的RAM数据地址
  assign shift_addr = h_shift[9] ? (wave_rd_addr-h_shift[8:0]) : //右移
                      (wave_rd_addr+h_shift[8:0]);               //左移
  //根据触发地址，计算像素横坐标所映射的RAM地址
  assign rel_addr = trig_addr + shift_addr;
  assign rd_addr = (rel_addr < HALF_WAVE_DEPTH) ? (rel_addr + HALF_WAVE_DEPTH) :
                   (rel_addr > (WAVE_DEPTH+HALF_WAVE_DEPTH-1)) ? (rel_addr - (WAVE_DEPTH+HALF_WAVE_DEPTH)):
                   (rel_addr - HALF_WAVE_DEPTH);

  //满足触发条件时输出脉冲信号
  assign trig_pulse = trig_edge ?
                      ((pre_data2<trig_level) && (pre_data1<trig_level)
                      && (pre_data>=trig_level) && (ad_data>trig_level)) :
                      ((pre_data2>trig_level) && (pre_data1>trig_level)
                      && (pre_data<=trig_level) && (ad_data<trig_level));


  //读出的数据为255时超出波形显示范围
  assign wave_rd_data = outrange ? 8'd255 : (8'd255 - rd_ram_data);

  //判断水平偏移后地址范围
  always @(posedge hdmi_pclk or negedge rst_n) begin
    if (!rst_n) begin
      outrange <= 1'b0;
    end else if (h_shift[9] && (wave_rd_addr < h_shift[8:0])) begin  //右移时判断左边界
      outrange <= 1'b1;
    end else if ((~h_shift[9]) && (wave_rd_addr + h_shift[8:0] > WAVE_DEPTH - 1)) begin  //左移时判断右边界
      outrange <= 1'b1;
    end else begin
      outrange <= 1'b0;
    end
  end

  //写RAM地址累加
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_addr <= 12'd0;
    end else if (deci_valid) begin
      if (wr_addr < WAVE_DEPTH - 1) begin
        wr_addr <= wr_addr + 1'b1;
      end else begin
        wr_addr <= 12'd0;
      end
    end
  end


  //触发使能
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      data_cnt <= 12'd0;
      trig_en  <= 1'b0;
    end else begin
      if (deci_valid) begin
        if (data_cnt < (HALF_WAVE_DEPTH - 1)) begin  //触发前至少接收WAVE_DEPTH/2个数据
          data_cnt <= data_cnt + 1'b1;
          trig_en  <= 1'b0;
        end else begin
          trig_en <= 1'b1;  //打开触发使能
          if (trig_flag) begin  //检测到触发信号
            trig_en <= 1'b0;
            if (data_cnt < WAVE_DEPTH) begin  //继续接收WAVE_DEPTH/2个数据
              data_cnt <= data_cnt + 1'b1;
            end
          end
        end
      end
      //波形绘制完成后重新计数
      if ((data_cnt == WAVE_DEPTH) && hdmi_wr_over & wave_run) begin
        data_cnt <= 12'd0;
      end
    end
  end

  //寄存AD数据，用于判断触发条件
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      pre_data  <= 8'd0;
      pre_data1 <= 8'd0;
      pre_data2 <= 8'd0;
    end else if (deci_valid) begin
      pre_data  <= ad_data;
      pre_data1 <= pre_data;
      pre_data2 <= pre_data1;
    end
  end

  //触发检测
  always @(posedge ad_clk or negedge rst_n) begin
    if (!rst_n) begin
      trig_addr <= 12'd0;
      trig_flag <= 1'b0;
    end else begin
      if (deci_valid && trig_en && trig_pulse) begin
        trig_flag <= 1'b1;
        trig_addr <= wr_addr + 2;
      end
      if (trig_flag && (data_cnt == WAVE_DEPTH) && hdmi_wr_over && wave_run) begin
        trig_flag <= 1'b0;
      end
    end
  end

  ram_2port u_ram_2port (
    .a_addr   (wr_addr),        // input [11:0]
    .a_wr_data(ad_data),        // input [7:0]
    .a_rd_data(),               // output [7:0]
    .a_wr_en  (wr_en),          // input
    .a_clk    (ad_clk),         // input
    .a_clk_en (1'b1),           // input
    .a_rst    (!rst_n),         // input
    .b_addr   (rd_addr),        // input [11:0]
    .b_wr_data(),               // input [7:0]
    .b_rd_data(rd_ram_data),    // output [7:0]
    .b_wr_en  (1'b0),           // input
    .b_clk    (hdmi_pclk),      // input
    .b_clk_en (wave_data_req),  // input
    .b_rst    (!rst_n)          // input
  );

endmodule
