module ddr3_rd_ctrl #(
	parameter CTRL_ADDR_WIDTH      = 28,
	parameter MEM_DQ_WIDTH         = 16,
	parameter MEM_SPACE_AW         = 18
)(
	input                                clk           ,
	input                                rst_n         ,
	input [CTRL_ADDR_WIDTH-1:0]          ddr3_rd_addr  ,
	input [3:0]                          ddr3_axi_id   ,
	input [3:0]                          ddr3_axi_len  ,
	input                                ddr3_axi_ap   ,
	input                                read_en       ,
	output reg                           read_done_p   ,
	output                               ddr3_rd_valid ,
	output [MEM_DQ_WIDTH*8-1:0]          ddr3_rd_data  ,

	output reg [CTRL_ADDR_WIDTH-1:0]     axi_araddr    /*synthesis PAP_MARK_DEBUG="true"*/,
	output reg                           axi_aruser_ap /*synthesis PAP_MARK_DEBUG="true"*/,
	output reg [3:0]                     axi_aruser_id /*synthesis PAP_MARK_DEBUG="true"*/,
	output reg [3:0]                     axi_arlen     /*synthesis PAP_MARK_DEBUG="true"*/,
	input                                axi_arready   /*synthesis PAP_MARK_DEBUG="true"*/,
	output reg                           axi_arvalid   /*synthesis PAP_MARK_DEBUG="true"*/,

	input [MEM_DQ_WIDTH*8-1:0]           axi_rdata     /*synthesis PAP_MARK_DEBUG="true"*/,
	input [3:0]                          axi_rid       /*synthesis PAP_MARK_DEBUG="true"*/,
	input                                axi_rlast     /*synthesis PAP_MARK_DEBUG="true"*/,
	input                                axi_rvalid    /*synthesis PAP_MARK_DEBUG="true"*/,
	// output reg [7:0]                     err_cnt       ,
	output reg                           err_flag
);

localparam E_IDLE = 3'd0;
localparam E_RD   = 3'd1;
localparam E_END  = 3'd2;
localparam DQ_NUM = MEM_DQ_WIDTH/8;

reg [15:0] req_rd_cnt;
reg [15:0] execute_rd_cnt;
wire  read_finished;

reg [2:0] rd_state;


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		axi_araddr <= 'b0;
		axi_aruser_id <= 4'b0;
		axi_arlen <= 4'b0;
		axi_aruser_ap <= 1'b0;
		axi_arvalid <= 1'b0;
		rd_state <= E_IDLE;
		read_done_p <= 1'b0;
	end else begin
		if(rd_state == E_IDLE && read_en && read_finished) begin
			axi_araddr <= ddr3_rd_addr;
			axi_aruser_id <= ddr3_axi_id;
			axi_arlen <= ddr3_axi_len;
			axi_aruser_ap <= ddr3_axi_ap;
		end
		case(rd_state)
			E_IDLE: begin
				if(read_en && read_finished) begin
					rd_state <= E_RD;
				end
			end
			E_RD: begin
				axi_arvalid <= 1'b1;
				if(axi_arvalid && axi_arready) begin
					rd_state <= E_END;
					read_done_p <= 1'b1;
					axi_arvalid <= 1'b0;
				end
			end
			E_END: begin
				axi_arvalid <= 1'b0;
				read_done_p <= 1'b0;
				if(read_finished) begin
					rd_state <= E_IDLE;
				end
			end
			default: begin
				rd_state <= E_IDLE;
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
   	  req_rd_cnt     <= 16'd0;
   	  execute_rd_cnt <= 16'd0;
   end else begin
   	  if (axi_arvalid && axi_arready) begin
   	  	 req_rd_cnt <= req_rd_cnt + {8'd0,axi_arlen} + 1;
   	  end   	  
   	  if (axi_rvalid) begin
   	     execute_rd_cnt <= execute_rd_cnt + 1;
   	  end      
   end
end
assign  read_finished = (req_rd_cnt == execute_rd_cnt);


assign ddr3_rd_valid = axi_rvalid;
assign ddr3_rd_data = axi_rdata;

endmodule