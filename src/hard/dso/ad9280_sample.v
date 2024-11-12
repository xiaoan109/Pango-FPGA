module ad9280_sample (
  input ad_clk,
  input rst_n,
  input [7:0] ad_data,
  input deci_valid,
  input wave_run  /* synthesis PAP_MARK_DEBUG="true" */,
  input [7:0] trig_level,
  input trig_edge,
  input [11:0] wave_rd_addr  /* synthesis PAP_MARK_DEBUG="true" */,
  input wr_over  /* synthesis PAP_MARK_DEBUG="true" */,
  output ad_buf_wr  /* synthesis PAP_MARK_DEBUG="true" */,
  output [11:0] ad_buf_wr_addr  /* synthesis PAP_MARK_DEBUG="true" */,
  output [7:0] ad_buf_data  /* synthesis PAP_MARK_DEBUG="true" */,
  output [11:0] ad_buf_rd_addr  /* synthesis PAP_MARK_DEBUG="true" */
);

  parameter WAVE_DEPTH = 1024;
  parameter HALF_WAVE_DEPTH = WAVE_DEPTH >> 1;

  reg [10:0] sample_cnt;
  reg [11:0] wr_addr;  //RAM写地址
  reg trig_en;
  reg [11:0] trig_addr  /* synthesis PAP_MARK_DEBUG="true" */;
  reg trig_flag;
  reg [7:0] pre_data;
  reg [7:0] pre_data1;
  reg [7:0] pre_data2;
  wire [12:0] rel_addr;

  wire trig_pulse  /* synthesis PAP_MARK_DEBUG="true" */;
  assign ad_buf_wr_addr = wr_addr;
  assign ad_buf_data = ad_data;
  assign ad_buf_wr = deci_valid && (sample_cnt <= WAVE_DEPTH - 1) && wave_run;

  assign trig_pulse = trig_edge ? ((pre_data2<trig_level) && (pre_data1<trig_level)&& (pre_data>=trig_level) && (ad_data>trig_level)) : ((pre_data2>trig_level) && (pre_data1>trig_level) && (pre_data<=trig_level) && (ad_data<trig_level));
  // assign trig_pulse = trig_edge ? (pre_data < trig_level && ad_data >= trig_level) : (pre_data > trig_level && ad_data <= trig_level) ;

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
      sample_cnt <= 11'd0;
      trig_en <= 1'b0;
    end else begin
      if (deci_valid) begin
        if (sample_cnt < (HALF_WAVE_DEPTH - 1)) begin  //触发前至少接收WAVE_DEPTH/2个数据
          sample_cnt <= sample_cnt + 1'b1;
          trig_en <= 1'b0;
        end else begin
          trig_en <= 1'b1;  //打开触发使能
          if (trig_flag) begin  //检测到触发信号
            trig_en <= 1'b0;
            if (sample_cnt < WAVE_DEPTH) begin  //继续接收WAVE_DEPTH/2个数据
              sample_cnt <= sample_cnt + 1'b1;
            end
          end
        end
      end
      //波形绘制完成后重新计数
      if ((sample_cnt == WAVE_DEPTH) && wr_over && wave_run) begin
        sample_cnt <= 11'd0;
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
      if (trig_flag && (sample_cnt == WAVE_DEPTH) && wr_over && wave_run) begin
        trig_flag <= 1'b0;
      end
    end
  end

  //根据触发地址，计算像素横坐标所映射的RAM地址
  assign rel_addr = trig_addr + wave_rd_addr;
  assign ad_buf_rd_addr = (rel_addr < HALF_WAVE_DEPTH) ? (rel_addr + HALF_WAVE_DEPTH) :
                   (rel_addr > (WAVE_DEPTH+HALF_WAVE_DEPTH-1)) ? (rel_addr - (WAVE_DEPTH+HALF_WAVE_DEPTH)):
                   (rel_addr - HALF_WAVE_DEPTH);


endmodule
