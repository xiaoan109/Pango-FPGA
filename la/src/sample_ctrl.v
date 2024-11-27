// +FHEADER =====================================================================
// FilePath       : \LA_final\source\sample_ctrl.v
// Author         : zkwang2001 1922601163@qq.com
// CreateDate     : 24-11-23
// LastEditors    : zkwang2001 1922601163@qq.com
// LastEditTime   : 24-11-24
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
module sample_ctrl #(
   parameter CHN_NUM = 8
)(
   input                          iSysClk,
   input                          iRst,
   input                          clk_en,
   input                          trigger_en,   //enable trigger
   input         [3-1:0]          chn_sel,
   input         [2:0]            mode_sel,
   input         [CHN_NUM-1:0]    data_in,
   input         [9:0]            pre_num,
   input                          trigger_logic, //0:and 1:or 
   output  [2:0]  mode_sel1,
   output  [2:0]  mode_sel2,
   output  [2:0]  mode_sel3,
   output  [2:0]  mode_sel4,
   output  [2:0]  mode_sel5,
   output  [2:0]  mode_sel6,
   output  [2:0]  mode_sel7,
   output  [2:0]  mode_sel8,
   output   reg  [9:0]            start_addr,
   output   reg                   finished,
   output   reg  [9:0]            wr_addr,
   output        [CHN_NUM-1:0]    wr_data,
   output   reg                   wr_en
);
   reg           [9:0]            sample_cnt;

   reg           [CHN_NUM-1:0]    data_in_d1;
   reg           [CHN_NUM-1:0]    data_in_d2;
  //  reg           [CHN_NUM-1:0]    trigger_data_1;   /* synthesis PAP_MARK_DEBUG="true" */
  //  reg           [CHN_NUM-1:0]    trigger_data_2;   /* synthesis PAP_MARK_DEBUG="true" */
   reg                            trigger_flag;     /* synthesis PAP_MARK_DEBUG="true" */
  //  reg                            trigger_flag_1;
  //  reg                            trigger_flag_2;
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

  reg [2:0] chn_mode [0:7];

  always @(chn_sel or mode_sel ) begin 
   case (chn_sel)
      3'd0:chn_mode[0] = mode_sel;
      3'd1:chn_mode[1] = mode_sel;
      3'd2:chn_mode[2] = mode_sel;
      3'd3:chn_mode[3] = mode_sel;
      3'd4:chn_mode[4] = mode_sel;
      3'd5:chn_mode[5] = mode_sel;
      3'd6:chn_mode[6] = mode_sel;
      3'd7:chn_mode[7] = mode_sel;
      default: begin 
              chn_mode[0] = 3'd0;
              chn_mode[1] = 3'd0;
              chn_mode[2] = 3'd0;
              chn_mode[3] = 3'd0;
              chn_mode[4] = 3'd0;
              chn_mode[5] = 3'd0;
              chn_mode[6] = 3'd0;
              chn_mode[7] = 3'd0;
      end
   endcase
  end
//  设置每个通道的触发模式
// 1 低电平
// 2 高电平
// 3 上升沿
// 4 下降沿
// 5 边沿
// 6 无触发
// 0 default
  wire  [7:0] chn__trig_en;
  assign  chn__trig_en[0] =    (chn_mode[0] == 3'd1 && ~data_in_d2[0]) 
                            || (chn_mode[0] == 3'd2 &&  data_in_d2[0])
                            || (chn_mode[0] == 3'd3 &&  s_posedge[0])
                            || (chn_mode[0] == 3'd4 &&  s_negedge[0])
                            || (chn_mode[0] == 3'd5 &&  s_edge[0])
                            || (chn_mode[0] == 3'd6 && 1'b0 )
                            || (chn_mode[0] == 3'd0 );

  assign chn__trig_en[1] =     (chn_mode[1] == 3'd1 && ~data_in_d2[1]) 
                            || (chn_mode[1] == 3'd2 &&  data_in_d2[1])
                            || (chn_mode[1] == 3'd3 &&  s_posedge[1])
                            || (chn_mode[1] == 3'd4 &&  s_negedge[1])
                            || (chn_mode[1] == 3'd5 &&  s_edge[1])
                            || (chn_mode[1] == 3'd6 && 1'b0 )
                            || (chn_mode[1] == 3'd0 );

  assign chn__trig_en[2] =     (chn_mode[2] == 3'd1 && ~data_in_d2[2]) 
                            || (chn_mode[2] == 3'd2 &&  data_in_d2[2])
                            || (chn_mode[2] == 3'd3 &&  s_posedge[2])
                            || (chn_mode[2] == 3'd4 &&  s_negedge[2])
                            || (chn_mode[2] == 3'd5 &&  s_edge[2])
                            || (chn_mode[2] == 3'd6 && 1'b0 )
                            || (chn_mode[2] == 3'd0 );

  assign chn__trig_en[3] =     (chn_mode[3] == 3'd1 && ~data_in_d2[3]) 
                            || (chn_mode[3] == 3'd2 &&  data_in_d2[3])
                            || (chn_mode[3] == 3'd3 &&  s_posedge[3])
                            || (chn_mode[3] == 3'd4 &&  s_negedge[3])
                            || (chn_mode[3] == 3'd5 &&  s_edge[3])
                            || (chn_mode[3] == 3'd6 && 1'b0 )
                            || (chn_mode[3] == 3'd0 );

  assign chn__trig_en[4] =     (chn_mode[4] == 3'd1 && ~data_in_d2[4]) 
                            || (chn_mode[4] == 3'd2 &&  data_in_d2[4])
                            || (chn_mode[4] == 3'd3 &&  s_posedge[4])
                            || (chn_mode[4] == 3'd4 &&  s_negedge[4])
                            || (chn_mode[4] == 3'd5 &&  s_edge[4])
                            || (chn_mode[4] == 3'd6 && 1'b0 )
                            || (chn_mode[4] == 3'd0 );

  assign chn__trig_en[5] =     (chn_mode[5] == 3'd1 && ~data_in_d2[5])
                            || (chn_mode[5] == 3'd2 &&  data_in_d2[5])
                            || (chn_mode[5] == 3'd3 &&  s_posedge[5])
                            || (chn_mode[5] == 3'd4 &&  s_negedge[5])
                            || (chn_mode[5] == 3'd5 &&  s_edge[5])
                            || (chn_mode[5] == 3'd6 && 1'b0 )
                            || (chn_mode[5] == 3'd0 );

  assign chn__trig_en[6] =     (chn_mode[6] == 3'd1 && ~data_in_d2[6])   
                            || (chn_mode[6] == 3'd2 &&  data_in_d2[6])
                            || (chn_mode[6] == 3'd3 &&  s_posedge[6])
                            || (chn_mode[6] == 3'd4 &&  s_negedge[6])
                            || (chn_mode[6] == 3'd5 &&  s_edge[6])
                            || (chn_mode[6] == 3'd6 && 1'b0 )
                            || (chn_mode[6] == 3'd0 );

  assign chn__trig_en[7] =     (chn_mode[7] == 3'd1 && ~data_in_d2[7])
                            || (chn_mode[7] == 3'd2 &&  data_in_d2[7])
                            || (chn_mode[7] == 3'd3 &&  s_posedge[7])
                            || (chn_mode[7] == 3'd4 &&  s_negedge[7])
                            || (chn_mode[7] == 3'd5 &&  s_edge[7])
                            || (chn_mode[7] == 3'd6 && 1'b0 )
                            || (chn_mode[7] == 3'd0 );

assign mode_sel1 = chn_mode[0];
assign mode_sel2 = chn_mode[1];
assign mode_sel3 = chn_mode[2];
assign mode_sel4 = chn_mode[3];
assign mode_sel5 = chn_mode[4];
assign mode_sel6 = chn_mode[5];
assign mode_sel7 = chn_mode[6];
assign mode_sel8 = chn_mode[7];


reg trigger_flag_en;
always @(*) begin
   if (trigger_logic)
      trigger_flag_en = chn__trig_en[0] | chn__trig_en[1] | chn__trig_en[2] | chn__trig_en[3] | chn__trig_en[4] | chn__trig_en[5] | chn__trig_en[6] | chn__trig_en[7];
   else
      trigger_flag_en = chn__trig_en[0] & chn__trig_en[1] & chn__trig_en[2] & chn__trig_en[3] & chn__trig_en[4] & chn__trig_en[5] & chn__trig_en[6] & chn__trig_en[7];
end

   reg  clk_en_d1, clk_en_d2;
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
      else if (trigger_flag_en && trigger_en) begin
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
         start_addr <= wr_addr+1;
       end else begin
         start_addr <= start_addr;
       end
     end

// flag 拉高之后才开始计数 计数触发后的数据
   always@(posedge iSysClk)begin
      if(~iRst)begin
        sample_cnt <= 11'd0;
      end else if(wr_en && trigger_flag)begin
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