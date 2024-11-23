module wr_driver #(
    parameter          CTRL_ADDR_WIDTH      = 28,
    parameter          MEM_DQ_WIDTH         = 16,
    parameter          MEM_SPACE_AW         = 18,
	parameter          USER_DATA_WIDTH      = 8
)(
	input                                 sys_clk             ,
	input                                 sys_rst_n           ,
	input                                 user_data_valid     ,
	input [USER_DATA_WIDTH-1:0 ]          user_data           ,
	output                                fifo_write_ready    ,
	input                                 ddr3_core_clk       ,
	input                                 ddr3_core_rst_n     ,
	input                                 ddrc_init_done      ,
	output reg                            write_en            ,
	input                                 write_done_p        ,

    output reg [CTRL_ADDR_WIDTH-1:0]      ddr3_wr_addr        ,
	output [MEM_DQ_WIDTH*8-1:0]           ddr3_wr_data        ,
	input                                 ddr3_wr_req         ,
    output [3:0]                          ddr3_axi_id         ,
    output [3:0]                          ddr3_axi_len        ,
    output                                ddr3_axi_ap         
);

localparam DQ_NUM = MEM_DQ_WIDTH/8;
localparam E_IDLE     = 3'd0;
localparam E_WR       = 3'd1;
localparam E_END      = 3'd2;
localparam BURST_LEN  = 4; //4*8*32bit, AXI_AxLEN = 3

reg ddrc_init_done_d0;
reg ddrc_init_done_d1;

reg [2:0] wr_test_state;

wire wr_full;
wire [5:0] fifo_rdusedw;

reg [$clog2(BURST_LEN)-1:0] burst_cnt;

always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	if(!ddr3_core_rst_n) begin
		ddrc_init_done_d0 <= 0;
		ddrc_init_done_d1 <= 0;
	end else begin
		ddrc_init_done_d0 <= ddrc_init_done;
		ddrc_init_done_d1 <= ddrc_init_done_d0;
	end
end

always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	if(!ddr3_core_rst_n) begin
		wr_test_state <= E_IDLE;
		write_en <= 1'b0;
	end else begin
		case(wr_test_state)
			E_IDLE: begin
				if(ddrc_init_done_d1 && fifo_rdusedw >= BURST_LEN) begin // 32bit fifo read
					wr_test_state <= E_WR;
				end
			end
			E_WR: begin
				if(write_done_p) begin
					write_en <= 1'b0;
					wr_test_state <= E_END;
				end else begin
					write_en <= 1'b1;
				end
			end
			E_END: begin
				if(burst_cnt == 'b0 && fifo_rdusedw >= BURST_LEN) begin
					wr_test_state <= E_WR;
				end
			end
			default: begin
				wr_test_state <= E_IDLE;
			end
		endcase
	end
end

always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	if(!ddr3_core_rst_n) begin
		ddr3_wr_addr <= 'b0;
	end else if(write_done_p) begin
		ddr3_wr_addr <= ddr3_wr_addr + BURST_LEN*8;
	end
end

always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	if(!ddr3_core_rst_n) begin
		burst_cnt <= 'b0;
	end else if(ddr3_wr_req) begin
		burst_cnt <= burst_cnt + 1'b1;
	end
end

assign ddr3_axi_id = 4'b0;
assign ddr3_axi_len = BURST_LEN - 1;
assign ddr3_axi_ap = 1'b0;

assign fifo_write_ready = !wr_full;



async_fifo_8to256 u_async_fifo_8to256 (
  .wr_clk(sys_clk),                   // input
  .wr_rst(!sys_rst_n),                // input
  .wr_en(user_data_valid),            // input
  .wr_data(user_data),                // input [7:0]
  .wr_full(wr_full),                  // output
  .wr_water_level(),                  // output [10:0]
  .almost_full(),                     // output
  .rd_clk(ddr3_core_clk),             // input
  .rd_rst(!ddr3_core_rst_n),          // input
  .rd_en(ddr3_wr_req),                // input
  .rd_data(ddr3_wr_data),             // output [255:0]
  .rd_empty(),                        // output
  .rd_water_level(fifo_rdusedw),      // output [5:0]
  .almost_empty()                     // output
);
endmodule