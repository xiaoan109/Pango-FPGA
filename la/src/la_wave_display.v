module la_wave_display(
	input                       rst_n,   
	input                       pclk,
	input    [23:0]             wave_color,
// input                       ad_clk ,
  input                       trigger_en,
 	input    [7:0]              ad_wr_data,
   input                       ad_wr_en,
   input    [9:0]              ad_wr_addr,
   input    [9:0]              start_addr,
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input    [23:0]             i_data,  
	output                      o_hs             /* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_vs             /* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_de             /* synthesis PAP_MARK_DEBUG="true" */,    
	output   [23:0]             o_data           /* synthesis PAP_MARK_DEBUG="true" */
);

// parameter IDLE = 3'b001 ;
// parameter S_SAMPLE = 3'b010 ;
// parameter S_WAIT = 3'b100 ;

   parameter   CH0_H = 70,   CH0_L = 170  ,
               CH1_H = 190,  CH1_L = 290  ,
               CH2_H = 310,  CH2_L = 410  ,
               CH3_H = 430,  CH3_L = 530  ,
               CH4_H = 550,  CH4_L = 650  ,
               CH5_H = 670,  CH5_L = 770  ,
               CH6_H = 790,  CH6_L = 890  ,
               CH7_H = 910,  CH7_L = 1010 ;

   reg      [3:0]              state;
// wire     [9:0]              wr_addr;
   reg      [10:0]             sample_cnt;
   reg      [31:0]             wait_cnt;
// reg                         wren;
   wire     [11:0]             pos_x;
   wire     [11:0]             pos_y;
   wire                        pos_hs;
   wire                        pos_vs;
   wire                        pos_de;
   wire     [23:0]             pos_data;
   reg      [23:0]             v_data;
   reg      [9:0]              rdaddress    ; 
   wire     [7:0]              q            ; 
   reg                         region_active; 
   reg      [7:0]              q_d1         ;
   wire     [7:0]              q_edge       ;  
/* wire     [11:0]             ref_sig      ; 
   wire                        ref_sig2     ; 
   wire     [9:0]              ref_rd_addr  ; 
   reg      [7:0]              q_d1         ; 
   reg                         region_active; 
   wire     [7:0]              q_edge       ; 

   assign ref_sig = 12'd287 - q[7:0] ;
   assign ref_sig2 = ((region_active == 1'b1)&&(12'd287 - pos_y == {4'd0,q[7:0]})) ? 1'b1 : 1'b0 ;
   assign ref_rd_addr = rdaddress[9:0];
*/
   assign o_data = v_data;
   assign o_hs   = pos_hs;
   assign o_vs   = pos_vs;
   assign o_de   = pos_de;
   assign q_edge = q ^ q_d1;

  always @(posedge pclk) begin
      q_d1 <= q;
   end

   always @(posedge pclk) begin
      if(pos_y >= 12'd60 && pos_y <= 12'd1020 && pos_x >= 12'd442 && pos_x  <= 12'd1465) begin
      	region_active <= 1'b1;
      end
      else begin
         region_active <= 1'b0;
      end
   end

   always @(posedge pclk) begin
      if(region_active == 1'b1 && pos_de == 1'b1) begin
         rdaddress <= rdaddress + 10'd1;
      end
      else begin
         rdaddress <= 10'd0;
      end
   end

  reg [9:0] ram_addr;
  always@(posedge pclk) begin
    if (~rst_n) begin
      ram_addr <= 10'd0;
    end
    else if (region_active == 1'b1 && pos_de == 1'b1) begin
      ram_addr <= rdaddress + start_addr+1'b1;
    end
    else begin
      ram_addr <= ram_addr;
    end
  end
// always @(posedge pclk) begin
// 	if(region_active == 1'b1) begin
// 		if((12'd1055- pos_y)/4 == {4'd0,q[7:0]}) begin
// 			v_data <= wave_color;
//       end
// 		else begin
// 			v_data <= pos_data;
//       end
//    end
// 	else begin
// 		v_data <= pos_data;
//    end
// end

  //  always @(posedge pclk) begin
  //     if (region_active) begin
  //        if ((pos_y == CH0_H && q[0]) || (pos_y == CH0_L && ~q[0]) ||
  //            (pos_y == CH1_H && q[1]) || (pos_y == CH1_L && ~q[1]) ||
  //            (pos_y == CH2_H && q[2]) || (pos_y == CH2_L && ~q[2]) ||
  //            (pos_y == CH3_H && q[3]) || (pos_y == CH3_L && ~q[3]) ||
  //            (pos_y == CH4_H && q[4]) || (pos_y == CH4_L && ~q[4]) ||
  //            (pos_y == CH5_H && q[5]) || (pos_y == CH5_L && ~q[5]) ||
  //            (pos_y == CH6_H && q[6]) || (pos_y == CH6_L && ~q[6]) ||
  //            (pos_y == CH7_H && q[7]) || (pos_y == CH7_L && ~q[7])) 
  //        begin
  //           v_data <= wave_color;
  //        end
  //        else begin
  //           v_data <= pos_data;
  //        end
  //     end
  //     else begin
  //        v_data <= pos_data;
  //     end
  //  end

   always @(posedge pclk) begin
      if (region_active && ~trigger_en) begin
         if ((pos_y == CH0_H && q[0]) || (pos_y == CH0_L && ~q[0]) || (pos_y >=CH0_H && pos_y <= CH0_L && q_edge[0]) ||
             (pos_y == CH1_H && q[1]) || (pos_y == CH1_L && ~q[1]) || (pos_y >=CH1_H && pos_y <= CH1_L && q_edge[1]) ||
             (pos_y == CH2_H && q[2]) || (pos_y == CH2_L && ~q[2]) || (pos_y >=CH2_H && pos_y <= CH2_L && q_edge[2]) ||
             (pos_y == CH3_H && q[3]) || (pos_y == CH3_L && ~q[3]) || (pos_y >=CH3_H && pos_y <= CH3_L && q_edge[3]) ||
             (pos_y == CH4_H && q[4]) || (pos_y == CH4_L && ~q[4]) || (pos_y >=CH4_H && pos_y <= CH4_L && q_edge[4]) ||
             (pos_y == CH5_H && q[5]) || (pos_y == CH5_L && ~q[5]) || (pos_y >=CH5_H && pos_y <= CH5_L && q_edge[5]) ||
             (pos_y == CH6_H && q[6]) || (pos_y == CH6_L && ~q[6]) || (pos_y >=CH6_H && pos_y <= CH6_L && q_edge[6]) ||
             (pos_y == CH7_H && q[7]) || (pos_y == CH7_L && ~q[7]) || (pos_y >=CH7_H && pos_y <= CH7_L && q_edge[7]) )
         begin
            v_data <= wave_color;
         end
         else begin
            v_data <= pos_data;
         end
      end
      else begin
         v_data <= pos_data;
      end
   end


// always @(posedge ad_clk ) begin
// 	if (~rst_n) begin
// 		state <= 3'b001 ;
// 		//wren <= 1'b0 ;
// 		sample_cnt <= 11'd0;
// 		wait_cnt <= 32'd0;
// 	end
// 	else begin
// 		case (state)
// 			IDLE : begin
// 				state <= S_SAMPLE ; 
// 			end 
// 			S_SAMPLE : begin
// 				if(sample_cnt == 11'd1023)
// 				begin
// 					sample_cnt <= 11'd0;
// 					//wren <= 1'b0;
// 					state <= S_WAIT;
// 				end
// 				else
// 				begin
// 					sample_cnt <= sample_cnt + 11'd1;
// 					//wren <= 1'b1;
// 				end
// 			end
// 			S_WAIT : begin
// 				if(wait_cnt == 32'd33_670_033)
// 				begin
// 					state <= S_SAMPLE;
// 					wait_cnt <= 32'd0;
// 				end
// 				else
// 				begin
// 					wait_cnt <= wait_cnt + 32'd1;
// 				end
// 			end
// 			default: state <= IDLE ; 
// 		endcase
// 	end 
// end

// assign wr_addr = sample_cnt[9:0] ;

ram1024x8 u_ram (
  .wr_data(ad_wr_data),                     // input [7:0]
  .wr_addr(ad_wr_addr),        // input [9:0]
  .wr_en(ad_wr_en),                         // input
  .wr_clk(pclk),                            // input
  .wr_rst(~rst_n),                           // input
  .rd_addr(ram_addr),                 // input [9:0]
  .rd_data(q),                              // output [7:0]
  .rd_clk(pclk),                            // input
  .rd_rst(~rst_n)                           // input
);

timing_gen_xy u_timing_gen_xy(
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