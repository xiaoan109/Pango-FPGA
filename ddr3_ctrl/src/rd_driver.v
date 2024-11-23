module rd_driver#(
    parameter          CTRL_ADDR_WIDTH      = 28,
    parameter          MEM_DQ_WIDTH         = 16,
    parameter          MEM_SPACE_AW         = 18,
	parameter          USER_DATA_WIDTH      = 8
)(
	input                                 sys_clk             ,
	input                                 sys_rst_n           ,
	input                                 ddr3_core_clk       ,
	input                                 ddr3_core_rst_n     ,
	input                                 ddrc_init_done      ,
	input                                 user_ddr3_rd_en     ,
	// input                                 user_fifo_rd_en     ,
	output [USER_DATA_WIDTH-1:0]          user_rd_data        ,   //Clock Domain: sys_clk
	output reg                            user_rd_data_valid  ,   //Clock Domain: sys_clk
	input [CTRL_ADDR_WIDTH-1:0]           user_rd_addr        ,   //Clock Domain: ddr3_core_clk
	input                                 user_rd_addr_valid  ,   //Clock Domain: ddr3_core_clk
	// output [11:0]                         fifo_rdusedw        ,
	output reg                            read_en             ,
	input                                 read_done_p         ,
	input                                 ddr3_rd_valid       ,
	input [MEM_DQ_WIDTH*8-1:0]            ddr3_rd_data        ,
	
	output reg [CTRL_ADDR_WIDTH-1:0]      ddr3_rd_addr        ,
	output [3:0]                          ddr3_axi_id         ,
	output [3:0]                          ddr3_axi_len        ,
	output                                ddr3_axi_ap         
);
   
localparam DQ_NUM = MEM_DQ_WIDTH/8;
localparam E_IDLE     = 3'd0;
localparam E_RD       = 3'd1;
localparam E_END      = 3'd2;
localparam BURST_LEN  = 4; //4*8*32bit, AXI_AxLEN = 3
localparam DATA_RECV_NUM = 1024; //1024B data
localparam DDR3_READ_TIMES = (DATA_RECV_NUM *  USER_DATA_WIDTH) / (MEM_DQ_WIDTH * 8 * BURST_LEN);

reg ddrc_init_done_d0;
reg ddrc_init_done_d1;

reg [2:0] rd_test_state;

wire rd_empty;
wire [6:0] fifo_wrusedw;
wire [11:0] fifo_rdusedw;
reg user_fifo_rd_en;

reg [$clog2(BURST_LEN):0] burst_cnt;
reg [$clog2(DDR3_READ_TIMES)-1:0] rd_addr_cnt;
reg [$clog2(DATA_RECV_NUM)-1:0] rd_data_cnt;

reg [CTRL_ADDR_WIDTH-1:0] user_rd_addr_fix;
reg user_rd_addr_keep;

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
		rd_test_state <= E_IDLE;
		read_en <= 1'b0;
	end else begin
		case(rd_test_state)
			E_IDLE: begin
				if(ddrc_init_done_d1 && fifo_wrusedw <= (1<<6) - BURST_LEN && user_ddr3_rd_en) begin // 32bit fifo read
					rd_test_state <= E_RD;
				end
			end
			E_RD: begin
				if(read_done_p) begin
					read_en <= 1'b0;
					rd_test_state <= E_END;
				end else begin
					read_en <= 1'b1;
				end
			end
			E_END: begin
				if(burst_cnt == BURST_LEN && fifo_wrusedw  <= (1<<6) - BURST_LEN && user_ddr3_rd_en) begin
					rd_test_state <= E_RD;
				end
			end
			default: begin
				rd_test_state <= E_IDLE;
			end
		endcase
	end
end

always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	if(!ddr3_core_rst_n) begin
		rd_addr_cnt <= 'b0;
	end else if(read_done_p) begin
		rd_addr_cnt <= rd_addr_cnt + 1'b1;
	end
end

always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	if(!ddr3_core_rst_n) begin
		user_rd_addr_fix <= 'b0;
		user_rd_addr_keep <= 1'b0;
	end else if(!user_rd_addr_keep && user_rd_addr_valid && ~|rd_addr_cnt) begin
		user_rd_addr_fix <= user_rd_addr;
		user_rd_addr_keep <= 1'b1;
	end else if(user_rd_addr_keep && read_done_p) begin
		user_rd_addr_fix <= user_rd_addr_fix;
		user_rd_addr_keep <= 1'b0;
	end
end

// always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	// if(!ddr3_core_rst_n) begin
		// ddr3_rd_addr <= 'b0;
	// end else if(user_rd_addr_valid && ~|rd_addr_cnt) begin
		// ddr3_rd_addr <= user_rd_addr;
	// end else if(read_done_p) begin
		// ddr3_rd_addr <= user_rd_addr + rd_addr_cnt * BURST_LEN * 8;
	// end
// end

always @(*) begin
	ddr3_rd_addr = user_rd_addr_fix + rd_addr_cnt * BURST_LEN * 8;
	if(!ddr3_core_rst_n) begin
		ddr3_rd_addr = 'b0;
	end
end

always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	if(!ddr3_core_rst_n) begin
		burst_cnt <= 'b0;
	end else if(read_done_p) begin
		burst_cnt <= 'b0;
	end else if(ddr3_rd_valid) begin
		burst_cnt <= burst_cnt + 1'b1;
	end
end

assign ddr3_axi_id = 4'b0;
assign ddr3_axi_len = BURST_LEN - 1;
assign ddr3_axi_ap = 1'b0;



async_fifo_256to8_ext async_fifo_256to8_ext (
  .wr_clk(ddr3_core_clk),             // input
  .wr_rst(!ddr3_core_rst_n),          // input
  .wr_en(ddr3_rd_valid),              // input
  .wr_data(ddr3_rd_data),             // input [255:0]
  .wr_full(),                         // output
  .wr_water_level(fifo_wrusedw),      // output [6:0]
  .almost_full(),                     // output
  .rd_clk(sys_clk),                   // input
  .rd_rst(!sys_rst_n),                // input
  .rd_en(user_fifo_rd_en),            // input
  .rd_data(user_rd_data),             // output [7:0]
  .rd_empty(rd_empty),                // output
  .rd_water_level(fifo_rdusedw),      // output [11:0]
  .almost_empty()                     // output
);



always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		user_fifo_rd_en <= 1'b0;
	end else if(user_ddr3_rd_en && fifo_rdusedw >= DATA_RECV_NUM) begin
		user_fifo_rd_en <= 1'b1;
	end else if(rd_data_cnt == DATA_RECV_NUM - 1) begin
		user_fifo_rd_en <= 1'b0;
	end
end
	
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		rd_data_cnt <= 'b0;
	end else if(user_rd_data_valid) begin
		rd_data_cnt <= rd_data_cnt + 1'b1;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		user_rd_data_valid <= 1'b0;
	end else begin
		user_rd_data_valid <= user_fifo_rd_en && !rd_empty;
	end
end

endmodule