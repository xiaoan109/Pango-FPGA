module ad9280_sample (
  input  wire        ad_clk,          //!ADC采样时钟
  input  wire        rst_n,           //!系统复位，低电平有效
  input  wire [ 7:0] ad_data,         //!ADC采样数据
  input  wire        deci_valid,      //!示波器抽样有效信号
  input  wire        wave_run,        //!示波器RUN/STOP
  input  wire [ 7:0] trig_level,      //!示波器触发电平(0-255对应-5~5V)
  input  wire        trig_edge,       //!示波器触发类型(上升/下降)
  // input  wire [11:0] wave_rd_addr,    //!输入ADC采样RAM读地址
  input  wire        wr_over,         //!HDMI一帧绘制完成
  output wire        ad_buf_wr,       //!ADC采样RAM写使能
  // output wire [11:0] ad_buf_wr_addr,  //!ADC采样RAM写地址
  output wire [ 7:0] ad_buf_data,     //!ADC采样RAM写数据
  // output wire [11:0] ad_buf_rd_addr   //!输出ADC采样RAM读地址
  output wire        ad_sample_trig,
  output wire [9:0]  ad_sample_offset
);

  parameter WAVE_DEPTH = 1024;
  parameter HALF_WAVE_DEPTH = WAVE_DEPTH >> 1;

  reg [10:0] sample_cnt;
  reg [11:0] wr_addr;  //RAM写地址
  reg trig_en;
  // reg [11:0] trig_addr  /* synthesis PAP_MARK_DEBUG="true" */;
  reg trig_flag;
  reg [7:0] pre_data;
  reg [7:0] pre_data1;
  reg [7:0] pre_data2;
  // wire [12:0] rel_addr;
  reg [9:0] refresh_cnt;

  wire trig_pulse  /* synthesis PAP_MARK_DEBUG="true" */;
  // assign ad_buf_wr_addr = wr_addr;
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
      // trig_addr <= 12'd0;
      trig_flag <= 1'b0;
    end else begin
      if (deci_valid && trig_en && trig_pulse) begin
        trig_flag <= 1'b1;
        // trig_addr <= wr_addr + 2;
      end
      if (trig_flag && (sample_cnt == WAVE_DEPTH) && wr_over && wave_run) begin
        trig_flag <= 1'b0;
      end
    end
  end

  //根据触发地址，计算像素横坐标所映射的RAM地址
  // assign rel_addr = trig_addr + wave_rd_addr;
  // // assign ad_buf_rd_addr = (rel_addr < HALF_WAVE_DEPTH) ? (rel_addr + HALF_WAVE_DEPTH) :
                   // // (rel_addr > (WAVE_DEPTH+HALF_WAVE_DEPTH-1)) ? (rel_addr - (WAVE_DEPTH+HALF_WAVE_DEPTH)):
                   // // (rel_addr - HALF_WAVE_DEPTH);
				   
  // assign ad_buf_rd_addr =  {2'b0, trig_addr + wave_rd_addr - HALF_WAVE_DEPTH};
	
	
	
  // assign ad_sample_trig =  deci_valid && trig_en && trig_pulse;
  assign ad_sample_trig =  deci_valid && trig_en && trig_flag; //1 clk after trig_pulse
	
  always @(posedge ad_clk or negedge rst_n) begin
	if(!rst_n) begin
	  refresh_cnt <= 10'b0;
	end else if(trig_en && trig_flag) begin
	  refresh_cnt <= 10'b0;
	end else if(trig_en && deci_valid) begin
	  refresh_cnt <= refresh_cnt + 1'b1; //需要对这个cnt再+1, 因为反映这部分数据会比trig_en慢一拍, trig_en的时候已经有一个刷新数据了
	end
  end
  
  assign ad_sample_offset = refresh_cnt + 1'b1;

endmodule
