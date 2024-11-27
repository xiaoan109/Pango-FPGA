module la_wave_display(
	input                       rst_n,   
	input                       pclk,
  /////////from sample ctrl 也是慢时钟的
  input                       sys_clk,
	input    [23:0]             wave_color,
	input    [7:0]              wr_data /* synthesis PAP_MARK_DEBUG="true" */,
  input                       wr_en /* synthesis PAP_MARK_DEBUG="true" */,
  input    [9:0]              wr_addr /* synthesis PAP_MARK_DEBUG="true" */,
  input    [9:0]              start_addr /* synthesis PAP_MARK_DEBUG="true" */, 
  /////////////////////
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input    [23:0]             i_data,

   //inputs from cpu
   input                       trigger_en,  // 慢时钟下的 慢于hdmi的时钟
   input                       right_shift,
   input                       left_shift,
   input                       zoom_in,
   input                       zoom_out,
   input    [9:0]              pre_num,

  output [9:0] o_ram_addr,
  output [7:0] o_q,

	output                      o_hs             /* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_vs             /* synthesis PAP_MARK_DEBUG="true" */,    
	output                      o_de             /* synthesis PAP_MARK_DEBUG="true" */,    
	output   [23:0]             o_data           /* synthesis PAP_MARK_DEBUG="true" */
);

   parameter   CH0_H = 70,   CH0_L = 170  ,
               CH1_H = 190,  CH1_L = 290  ,
               CH2_H = 310,  CH2_L = 410  ,
               CH3_H = 430,  CH3_L = 530  ,
               CH4_H = 550,  CH4_L = 650  ,
               CH5_H = 670,  CH5_L = 770  ,
               CH6_H = 790,  CH6_L = 890  ,
               CH7_H = 910,  CH7_L = 1010 ;

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
   reg      [6:0]              interval     ;
 

  reg right_shift_r, left_shift_r;
  reg right_shift_rr, left_shift_rr;
  always@(posedge pclk) begin
      if (~rst_n) begin
        right_shift_r <= 1'b0;
        left_shift_r <= 1'b0;
        right_shift_rr <= 1'b0;
        left_shift_rr <= 1'b0;
      end
      else begin
        right_shift_r <= right_shift;
        left_shift_r <= left_shift;
        right_shift_rr <= right_shift_r;
        left_shift_rr <= left_shift_r;
      end
  end

  wire neg_right_shift, neg_left_shift;
  assign neg_right_shift = right_shift_rr && ~right_shift_r;
  assign neg_left_shift = left_shift_rr && ~left_shift_r;



  //  reg [9:0] ram_addr;
  wire [9:0] ram_addr;
   reg [6:0] addr_cnt;
   reg [9:0] offset;

assign o_ram_addr = ram_addr;
assign o_q = q;

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
      if(region_active == 1'b1 && pos_de == 1'b1 && addr_cnt == interval - 1) begin
         rdaddress <= rdaddress + 10'd1;
      end
      else if (region_active == 1'b1 && pos_de == 1'b1) begin
         rdaddress <= rdaddress;
      end
      else begin
         rdaddress <= 10'b0;
      end
   end

   always @(posedge pclk) begin
      if (~rst_n) begin
         addr_cnt <= 7'd0;
      end
      else if (addr_cnt == interval - 1) begin
         addr_cnt <= 7'd0;
      end
      else if (region_active == 1'b1 && pos_de == 1'b1) begin
         addr_cnt <= addr_cnt + 1;
      end
      else begin
         addr_cnt <= 7'd0;
      end
   end

    always @(posedge pclk) begin
        if (~rst_n) begin
          offset <= 10'd0;
        end
        else if (neg_left_shift) begin
          offset <= offset + 1'b1;
        end
        else if (neg_right_shift) begin
          offset <= offset - 1'b1;
        end
        else begin
          offset <= offset;
        end
    end


    reg zoom_in_r, zoom_out_r;
    reg zoom_in_rr, zoom_out_rr;

    always@(posedge pclk) begin
        if (~rst_n) begin
          zoom_in_r <= 1'b0;
          zoom_out_r <= 1'b0;
          zoom_in_rr <= 1'b0;
          zoom_out_rr <= 1'b0;
        end
        else begin
          zoom_in_r <= zoom_in;
          zoom_out_r <= zoom_out;
          zoom_in_rr <= zoom_in_r;
          zoom_out_rr <= zoom_out_r;
        end
    end

  wire neg_zoom_in, neg_zoom_out;
  assign neg_zoom_in = zoom_in_rr && ~zoom_in_r;
  assign neg_zoom_out = zoom_out_rr && ~zoom_out_r;

    always @(posedge pclk) begin
        if (~rst_n) begin
          interval <= 7'd1;
        end
        else if (neg_zoom_in && interval < 63) begin
          interval <= interval << 1;
        end
        else if (neg_zoom_out && interval > 1) begin
          interval <= interval >> 1;
        end
        else begin
          interval <= interval;
        end
    end
   
   wire [9:0] trig_start_addr;   
   assign trig_start_addr = start_addr  + pre_num-pre_num / interval;

  assign ram_addr = rdaddress + (trig_start_addr + offset);

  reg [9:0] ram_addr_r;
  reg [9:0] ram_addr_rr;

  always@(posedge pclk) begin
    if (~rst_n) begin
      ram_addr_r <= 10'd0;
      ram_addr_rr <= 10'd0;
    end
    else begin
      ram_addr_r <= ram_addr;
      ram_addr_rr <= ram_addr_r;
    end
  end
wire edge_ram_addr;
assign edge_ram_addr = ram_addr_rr != ram_addr_r;

   always @(posedge pclk) begin
      if (region_active && ~trigger_en) begin
         if ((ram_addr_r == start_addr+pre_num && edge_ram_addr)) begin
            v_data <= {8'd100,8'd255,8'd0};
         end
         else if (edge_ram_addr && pos_y>=60 && pos_y<= 65) begin
            v_data <= {8'd100,8'd255,8'd0};
         end
         else if ((pos_y == CH0_H && q[0]) || (pos_y == CH0_L && ~q[0]) || (pos_y >=CH0_H && pos_y <= CH0_L && q_edge[0]) ||
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

ram1024x8 u_ram (
  .wr_data(wr_data),        // input  [7:0]
  .wr_addr(wr_addr),        // input  [9:0]
  .wr_en(wr_en),            // input
  .wr_clk(sys_clk),            // input
  .wr_rst(~rst_n),          // input
  .rd_addr(ram_addr),       // input  [9:0]
  .rd_data(q),              // output [7:0]
  .rd_clk(pclk),            // input
  .rd_rst(~rst_n)           // input
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