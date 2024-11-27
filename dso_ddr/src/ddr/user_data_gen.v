module user_data_gen #(
	parameter          USER_DATA_WIDTH    = 8
)(
	input                                sys_clk             ,
	input 							     sys_rst_n           ,
	input                                ddrc_init_done      ,
	input                                wr_test_ctrl        ,
	output [USER_DATA_WIDTH-1:0]         user_data           ,
	output                               user_data_valid     ,
	input                                fifo_write_ready     
);
   
parameter TEST_CNT = 10;

reg [USER_DATA_WIDTH-1:0] cnt          ;
// reg [7:0]                 test_cnt     ;
reg                       wr_test_en   ;
// wire                      test_finished;
   
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		wr_test_en <= 1'b0;
	end else if(wr_test_ctrl) begin
		wr_test_en <= !wr_test_en;
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		cnt <= 'b0;
	end else if(ddrc_init_done && wr_test_en && fifo_write_ready) begin
		cnt <= cnt + 1'b1;
	end
end

// always @(posedge sys_clk or negedge sys_rst_n) begin
	// if(!sys_rst_n) begin
		// test_cnt <= 8'b0;
	// end else if(wr_test_ctrl) begin
		// test_cnt <= 8'b0;
	// end else if(cnt == (1<<USER_DATA_WIDTH) -1) begin
		// test_cnt <= test_cnt + 1'b1;
	// end
// end


assign user_data = cnt;
assign user_data_valid = wr_test_en;
// assign test_finished = test_cnt == TEST_CNT - 1;
endmodule