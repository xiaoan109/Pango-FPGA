module ddr3_wr_ctrl #(
    parameter          CTRL_ADDR_WIDTH      = 28,
    parameter          MEM_DQ_WIDTH         = 16,
    parameter          MEM_SPACE_AW         = 18
)(
	input                                clk                 ,
	input 							     rst_n               ,
	input                                write_en            ,
	output reg                           write_done_p        ,

    input [CTRL_ADDR_WIDTH-1:0]          ddr3_wr_addr        ,
	input [MEM_DQ_WIDTH*8-1:0]           ddr3_wr_data        ,
	output reg                           ddr3_wr_req         ,
    input [3:0]                          ddr3_axi_id         ,
    input [3:0]                          ddr3_axi_len        ,
    input                                ddr3_axi_ap         ,

    output reg [CTRL_ADDR_WIDTH-1:0]     axi_awaddr          /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg                           axi_awuser_ap       /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg [3:0]                     axi_awuser_id       /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg [3:0]                     axi_awlen           /*synthesis PAP_MARK_DEBUG="true"*/,
    input                                axi_awready         /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg                           axi_awvalid         /*synthesis PAP_MARK_DEBUG="true"*/,

	output     [MEM_DQ_WIDTH*8-1:0]      axi_wdata           /*synthesis PAP_MARK_DEBUG="true"*/,
    output     [MEM_DQ_WIDTH*8/8-1:0]    axi_wstrb           /*synthesis PAP_MARK_DEBUG="true"*/,
    input                                axi_wready          /*synthesis PAP_MARK_DEBUG="true"*/,
	input [3:0]                          axi_wusero_id       /*synthesis PAP_MARK_DEBUG="true"*/,
	input                                axi_wusero_last     /*synthesis PAP_MARK_DEBUG="true"*/
);

localparam DQ_NUM = MEM_DQ_WIDTH/8;
localparam [CTRL_ADDR_WIDTH:0] AXI_ADDR_MAX = (1'b1<<MEM_SPACE_AW);

localparam E_IDLE = 3'd0;
localparam E_WR   = 3'd1;
localparam E_END  = 3'd2;

reg [15:0] req_wr_cnt     ;
reg [15:0] execute_wr_cnt ;
wire       write_finished ;

reg [2:0] wr_state;

assign axi_wstrb = {(MEM_DQ_WIDTH*8/8){1'b1}};

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		axi_awaddr <= 'b0;
		axi_awuser_ap <= 1'b0;
		axi_awuser_id <= 4'b0;
		axi_awlen <= 4'b0;
		axi_awvalid <= 1'b0;
		wr_state <= E_IDLE;
		write_done_p <= 1'b0;
	end else begin
		if(wr_state == E_IDLE && write_en && write_finished) begin //add more condition for easy debug
			axi_awuser_id <= ddr3_axi_id;
			axi_awaddr <= ddr3_wr_addr;
			axi_awlen <= ddr3_axi_len;
			axi_awuser_ap <= ddr3_axi_ap;
		end
		case(wr_state)
			E_IDLE: begin
				if(write_en && write_finished) begin
					wr_state <= E_WR;
				end
			end
			E_WR: begin
				axi_awvalid <= 1'b1;
				if(axi_awvalid && axi_awready) begin
					wr_state <= E_END;
					write_done_p <= 1'b1;
					axi_awvalid <= 1'b0;
				end
			end
			E_END: begin
				axi_awvalid <= 1'b0;
				write_done_p <= 1'b0;
				if(write_finished) begin
					wr_state <= E_IDLE;
				end
			end
			default: begin
				wr_state <= E_IDLE;
			end
		endcase
	end
end

assign axi_wdata = ddr3_wr_data;

always @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
   	  req_wr_cnt     <= 16'd0;
   	  execute_wr_cnt <= 16'd0;
   end else begin
   	  if (axi_awvalid && axi_awready) begin
   	  	req_wr_cnt <= req_wr_cnt + axi_awlen + 1;
   	  end
   	  if (axi_wready) begin
   	     execute_wr_cnt <= execute_wr_cnt + 1;
   	  end
   end
end

assign write_finished = (req_wr_cnt == execute_wr_cnt);

always @(*) begin
	ddr3_wr_req = 1'b0;
	if(wr_state == E_WR && axi_awvalid && axi_awready) begin
		ddr3_wr_req = 1'b1;
	end else if(wr_state == E_END && axi_wready && !axi_wusero_last) begin
		ddr3_wr_req = 1'b1;
	end
end

endmodule