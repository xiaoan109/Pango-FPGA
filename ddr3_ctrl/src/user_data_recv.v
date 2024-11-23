module user_data_recv #(
	parameter          USER_DATA_WIDTH      = 8
)(
	input                                 sys_clk             ,
	input                                 sys_rst_n           ,
	input                                 ddrc_init_done      ,
	input                                 rd_test_ctrl        ,
	output reg                            user_ddr3_rd_en     ,
	// output reg                            user_fifo_rd_en     ,
	input [USER_DATA_WIDTH-1:0]           user_rd_data        ,
	input                                 user_rd_data_valid  
	// input [11:0]                          fifo_rdusedw        
);
   
// localparam DATA_RECV_NUM = 1024; //1024B data

// reg [$clog2(DATA_RECV_NUM)-1:0] cnt;
   
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		user_ddr3_rd_en <= 1'b0;
	end else if(ddrc_init_done && rd_test_ctrl) begin
		user_ddr3_rd_en <= !user_ddr3_rd_en;
	end
end

// always @(posedge sys_clk or negedge sys_rst_n) begin
	// if(!sys_rst_n) begin
		// user_fifo_rd_en <= 1'b0;
	// end else if(user_ddr3_rd_en && fifo_rdusedw >= DATA_RECV_NUM) begin
		// user_fifo_rd_en <= 1'b1;
	// end else if(cnt == DATA_RECV_NUM - 1) begin
		// user_fifo_rd_en <= 1'b0;
	// end
// end
	
// always @(posedge sys_clk or negedge sys_rst_n) begin
	// if(!sys_rst_n) begin
		// cnt <= 'b0;
	// end else if(user_rd_data_valid) begin
		// cnt <= cnt + 1'b1;
	// end
// end
 
endmodule