module sample_ctrl #(
   parameter CHN_NUM = 8
)(
   input                       iSysClk,
   input                       iRst,
   input                       clk_en,
   input                       trigger_en,   //enable trigger
   input      [3-1:0]          chn_sel,
   input      [2:0]            mode_sel,
   input      [CHN_NUM-1:0]    data_in,
   output reg [CHN_NUM-1:0]    wr_addr,
   output     [CHN_NUM-1:0]    wr_data,
   output reg                  wr_en
);

   reg    [CHN_NUM-1:0]    data_in_d1;
   reg    [CHN_NUM-1:0]    data_in_d2;
   reg    [CHN_NUM-1:0]    trigger_data;     //decide which data is being monitored according to mode_sel
   reg                     trigger_flag;
   reg                     trigger_ready;    //indicating a trigger is being processed
   wire                    full;             //indicating RAM will be full in next clock cycle
   wire   [CHN_NUM-1:0]    s_posedge;
   wire   [CHN_NUM-1:0]    s_negedge;
   wire   [CHN_NUM-1:0]    s_edge;

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

   always @(posedge clk_en) begin
      if (~iRst) begin
         trigger_flag <= 1'b0;
      end
      else if (trigger_data[chn_sel] && clk_en) begin
      //else if (trigger_data[chn_sel]) begin
         trigger_flag <= 1'b1;
      end
      else begin
         trigger_flag <= 1'b0;
      end
   end

   always @(posedge iSysClk) begin
      if (~iRst) begin
         trigger_ready <= 1'b0;
      end
      else if (trigger_en) begin
         trigger_ready <= 1'b1;
      end
      else if (full) begin
         trigger_ready <= 1'b0;
      end
      else begin
         trigger_ready <= trigger_ready;
      end
   end

   assign full = (wr_addr == 8'hff);

   always @(posedge iSysClk) begin
      if (~iRst) begin
         wr_en <= 1'b0;
      end
      else if (trigger_ready && trigger_flag && ~wr_en) begin
         wr_en <= 1'b1;
      end
      else if (full) begin
         wr_en <= 1'b0;
      end
      else begin
         wr_en <= wr_en;
      end
   end

   always @(posedge iSysClk) begin
      if (~iRst) begin 
         wr_addr <= 'b0;
      end
      else if (clk_en && wr_en) begin
         wr_addr <= wr_addr + 1'b1;
      end
      else if (~wr_en) begin
         wr_addr <= 'b0;
      end
      else begin
         wr_addr <= wr_addr;
      end
   end

   assign wr_data = data_in_d2;

endmodule