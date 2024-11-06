module sample_ctrl #(
   parameter CHN_NUM = 8
)(
   input                          iSysClk, /* synthesis PAP_MARK_DEBUG="true" */
   input                          iRst,
   input                          clk_en,
   input                          trigger_en,   //enable trigger
   input         [3-1:0]          chn_sel,
   input         [2:0]            mode_sel,
   input         [CHN_NUM-1:0]    data_in,
   input         [9:0]            pre_num,
   output   reg  [9:0]            start_addr, /* synthesis PAP_MARK_DEBUG="true" */
   output   reg                   finished,
   output   reg  [9:0]            wr_addr,
   output        [CHN_NUM-1:0]    wr_data,
   output   reg                   wr_en
);
   reg           [9:0]            sample_cnt;

   reg           [CHN_NUM-1:0]    data_in_d1;
   reg           [CHN_NUM-1:0]    data_in_d2;
   reg           [CHN_NUM-1:0]    trigger_data;     //decide which data is being monitored according to mode_sel
   reg                            trigger_flag;
   reg                            trigger_ready;    //indicating a trigger is being processed
   wire          [CHN_NUM-1:0]    s_posedge;
   wire          [CHN_NUM-1:0]    s_negedge;
   wire          [CHN_NUM-1:0]    s_edge;

   always @(posedge iSysClk) begin
      if (~iRst) begin
         data_in_d1 <= 'b0;
         data_in_d2 <= 'b0;
      end
      else begin
         data_in_d1 <= data_in;
         data_in_d2 <= data_in_d1;
      end
   end

   assign s_posedge =  data_in_d1 & ~data_in_d2;
   assign s_negedge = ~data_in_d1 &  data_in_d2;
   assign s_edge    =  data_in_d1 ^  data_in_d2;

   always @(mode_sel or s_posedge or s_negedge or s_edge or data_in_d2) begin
      case(mode_sel)
         3'd0: trigger_data = ~data_in_d2;   //low_level
         3'd1: trigger_data =  data_in_d2;   //high_level
         3'd2: trigger_data =  s_posedge;    //positive_edge
         3'd3: trigger_data =  s_negedge;    //negative_edge
         3'd4: trigger_data =  s_edge;       //any_edge
         default: trigger_data = 8'hff;
      endcase
   end

  reg clk_en_d1, clk_en_d2;
  wire clk_en_edge;

  always@(posedge iSysClk) begin
      if (~iRst) begin
         clk_en_d1 <= 'b0;
         clk_en_d2 <= 'b0;
      end
      else begin
         clk_en_d1 <= clk_en;
         clk_en_d2 <= clk_en_d1;
      end
  end
  assign clk_en_edge = clk_en_d1 ^ clk_en_d2; 


   always @(posedge iSysClk) begin
      if (~iRst) begin
         trigger_flag <= 1'b0;
      end
      else if (trigger_data[chn_sel] && trigger_en) begin
      //else if (trigger_data[chn_sel]) begin
         trigger_flag <= 1'b1;
      end
      else if (finished) begin
         trigger_flag <= 1'b0;
      end
   end


  always@(posedge iSysClk)begin
    if(~iRst)begin
      finished <= 10'd0;
    end else if(sample_cnt ==  (10'd1023-pre_num) && finished == 1'b0) begin
      finished <= 1'b1;
    end else begin
      finished <= 1'b0; 
    end 
  end

always@(posedge iSysClk)begin
    if(~iRst)begin
      start_addr <= 10'd0;
    end else if(finished)begin
      start_addr <= wr_addr;
    end else begin
      start_addr <= start_addr;
    end
  end

// flag 拉高之后才开始计数 计数出发后的数据
  always@(posedge iSysClk)begin
    if(~iRst)begin
      sample_cnt <= 11'd0;
    end else if(wr_en && trigger_en)begin
      sample_cnt <= sample_cnt + 1'b1;
    end else if (finished) begin
      sample_cnt <= 11'd0; 
    end else begin
      sample_cnt <= sample_cnt;
    end
  end

// wr_en 相当于data_valid信号
   always @(posedge iSysClk) begin
      if (~iRst) begin
         wr_en <= 1'b0;
      end
      else if (trigger_en && clk_en_edge) begin
         wr_en <= 1'b1;
      end
      else begin
         wr_en <= 1'b0;
      end
   end

   always @(posedge iSysClk) begin
      if (~iRst) begin 
         wr_addr <= 'b0;
      end
      else if (wr_en) begin
         wr_addr <= wr_addr + 1'b1;
      end
      else if (finished) begin
         wr_addr <= 'b0;
      end
      else begin
         wr_addr <= wr_addr;
      end
   end

   assign wr_data = data_in_d2;

endmodule