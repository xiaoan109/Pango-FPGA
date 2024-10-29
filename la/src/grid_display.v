module grid_display(
	input                       rst_n,   
	input                       pclk,
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input		[23:0]          i_data,  
	output                      o_hs,    
	output                      o_vs,    
	output                      o_de,    
	output		[23:0]          o_data
);
	wire		[11:0] 			pos_x;
	wire		[11:0] 			pos_y;
	wire       					pos_hs;
	wire       					pos_vs;
	wire       					pos_de;
	wire		[23:0] 			pos_data;
	reg			[23:0]  		v_data;
	reg			[3:0]   		grid_x;
	reg			[6:0]   		grid_y;
	reg			        		region_active;

	parameter   CH0_H = 70,   CH0_L = 170  ,
                CH1_H = 190,  CH1_L = 290  ,
                CH2_H = 310,  CH2_L = 410  ,
                CH3_H = 430,  CH3_L = 530  ,
                CH4_H = 550,  CH4_L = 650  ,
                CH5_H = 670,  CH5_L = 770  ,
                CH6_H = 790,  CH6_L = 890  ,
                CH7_H = 910,  CH7_L = 1010 ;

	assign o_data = v_data;
	assign o_hs	  = pos_hs;
	assign o_vs	  = pos_vs;
	assign o_de	  = pos_de;

	always @(posedge pclk) begin
		if(pos_y >= 12'd60 && pos_y <= 12'd1020 && pos_x >= 12'd442 && pos_x  <= 12'd1521) begin
			region_active <= 1'b1;
		end
		else begin
			region_active <= 1'b0;
		end
	end

	always @(posedge pclk) begin
		if(region_active == 1'b1 && pos_de == 1'b1) begin
			grid_x <= (grid_x == 4'd9) ? 4'd0 : grid_x + 4'd1;
		end
		else begin
			grid_x <= 4'd0;
		end
	end

	always @(posedge pclk) begin
		if((region_active == 1'b1 && pos_de == 1'b1)&&((pos_y <= 12'd1020) && (pos_y >= 12'd60))&&(pos_x  == 12'd1521)) begin
			grid_y <= (grid_y == 7'd119) ? 7'd0 : grid_y + 7'd1;
		end
		else if (pos_y >= 12'd1020) begin
			grid_y <= 7'd0;
		end
	    else begin
	        grid_y <= grid_y;
		end
	end


	always @(posedge pclk) begin
		if(region_active == 1'b1) begin
	        if(((pos_y == 12'd1020) || (pos_y == 12'd60) || (grid_y == 7'd119) || ((pos_y < 12'd1020 && pos_y > 12'd60) && (grid_x == 4'd9)&& pos_y[0] == 1'b1))&&(pos_y != 12'd540))
				v_data <= {8'd100,8'd100,8'd0};
	        else if(((pos_y == 12'd1020) || (pos_y == 12'd60) || (grid_y == 7'd119) || ((pos_y < 12'd1020 && pos_y > 12'd60) && (grid_x == 4'd9)&& pos_y[0] == 1'b1))&&(pos_y == 12'd540))
				v_data <= {8'd255,8'd215,8'd0};
			else begin
				v_data <= 24'h000000;
			end
		end
		else begin
			v_data <= pos_data;
		end
	end

timing_gen_xy timing_gen_xy_m0(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);
endmodule