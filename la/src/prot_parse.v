// +FHEADER =====================================================================
// FilePath       : \LA_final\source\prot_parse.v
// Author         : zkwang2001 1922601163@qq.com
// CreateDate     : 24-11-24
// LastEditors    : zkwang2001 1922601163@qq.com
// LastEditTime   : 24-11-27
// Version        :
// Description    : 
//                  
// 
// Parameter       :
//                  
// 
// IO Port         :
//                  
// 
// Modification History
//    Date   |   Author   |   Version   |   Change Description
// ==============================================================================
//  23-08-24 |     NJU    |     0.1     | Original Version
//                  
// 
// -FHEADER =====================================================================
module prot_parse#(
  parameter DATA_WIDTH = 10
)(
    input clk,
    input rst_n,
    input [31:0] samp_freq, // 采样频率
    input [31:0] data_freq, // 数据波特率
    input start,
    input [9:0] start_addr,
    input data_in_valid,
    input data_in,
    output reg [9:0] rd_addr,/* synthesis PAP_MARK_DEBUG="true" */
    output reg [DATA_WIDTH-1:0] data_out,  // 最高16bit有效
    output  wire data_out_valid_w
);

reg data_out_valid;
reg running;
reg start_r,start_rr;
always@(posedge clk ) begin
  if(~rst_n) begin
    running <= 1'b0;
  end else if(start_r) begin
    running <= 1'b1;
 end else if (data_out_valid)begin
      running <= 1'b0;
    end 
end

assign data_out_valid_w = data_out_valid && running;

always@(posedge clk ) begin
  if(~rst_n) begin
    start_r <= 1'b0;
    start_rr <= 1'b0;
  end else begin
    start_r <= start;
    start_rr <= start_r;
  end
end
wire pos_start;
assign pos_start = ~start_r && start_rr;

  wire [31:0] one_data_num;
  assign one_data_num = samp_freq / data_freq ;

// 从起始地址开始 取中间的数据
  always@(posedge clk ) begin
    if(~rst_n) begin
      rd_addr <= 10'b0;
    end else if(pos_start) begin
      rd_addr <= start_addr+2*one_data_num-2;
    end else if(data_in_valid) begin
      rd_addr <= rd_addr + 2*one_data_num;
    end
  end

// 计数 每 DATA_WIDTH bit输出一次valid 和数据 
  reg [3:0]shift_cnt;
  always @(posedge clk ) begin
    if(~rst_n) begin
      shift_cnt <= 4'd0;
    end else if(data_in_valid && running) begin
      if(shift_cnt == DATA_WIDTH -1 ) begin
        shift_cnt <= 4'd0;
      end else begin
        shift_cnt <= shift_cnt + 4'd1;
      end
    end
  end

//输出数据
always@(posedge clk ) begin
  if(~rst_n) begin
    data_out <= 'b0;
  end else if(data_in_valid && running) begin
    data_out <= {data_out[DATA_WIDTH-2:0],data_in};
  end else if (~running) begin
    data_out <= data_out;
  end
end

// 输出数据valid信号
always@(posedge clk ) begin
  if(~rst_n) begin
    data_out_valid <= 1'b0;
  end else if(shift_cnt == DATA_WIDTH - 1 && data_in_valid) begin
    data_out_valid <=  1'b1;
  end else begin
    data_out_valid <= 1'b0;
  end
end


endmodule
