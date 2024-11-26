`timescale 1ns/1ps

`define DDR3
module ddr3_test_top #(
	parameter MEM_ROW_ADDR_WIDTH   = 15         ,

	parameter MEM_COL_ADDR_WIDTH   = 10         ,

	parameter MEM_BADDR_WIDTH      = 3         ,

	parameter MEM_DQ_WIDTH         =  32         ,

	parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8,
	parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8,
	parameter CTRL_ADDR_WIDTH      = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH,

	parameter USER_DATA_WIDTH      = 8
)(
	input                                  sys_clk         ,
	input                                  sys_rst_n       ,
	input                                  wr_test_ctrl    ,
	input                                  rd_test_ctrl    ,
	output                                 pll_lock        ,
	output                                 ddr_init_done   ,


	output                                 mem_rst_n       ,
	output                                 mem_ck          ,
	output                                 mem_ck_n        ,
	output                                 mem_cke         ,

	output                                 mem_cs_n        ,

	output                                 mem_ras_n       ,
	output                                 mem_cas_n       ,
	output                                 mem_we_n        ,
	output                                 mem_odt         ,
	output     [MEM_ROW_ADDR_WIDTH-1:0]    mem_a           ,
	output     [MEM_BADDR_WIDTH-1:0]       mem_ba          ,
	inout      [MEM_DQS_WIDTH-1:0]         mem_dqs         ,
	inout      [MEM_DQS_WIDTH-1:0]         mem_dqs_n       ,
	inout      [MEM_DQ_WIDTH-1:0]          mem_dq          ,
	output     [MEM_DM_WIDTH-1:0]          mem_dm          ,
	output reg                             heart_beat_led  ,
	output                                 err_flag_led
);


parameter TH_1S         = 27'd50_000_000;
parameter TH_4MS        = 27'd200_000;
parameter REM_DQS_WIDTH = 4 - MEM_DQS_WIDTH;

`ifdef SIMULATION
parameter MEM_SPACE_AW = 13; //to reduce simulation time
`else
parameter MEM_SPACE_AW = CTRL_ADDR_WIDTH;
`endif

wire                             ddr3_core_rst_n       ;
wire                             ddr3_core_clk             ;
//axi intf
wire [CTRL_ADDR_WIDTH-1:0]       axi_awaddr                ;
wire                             axi_awuser_ap             ;
wire [3:0]                       axi_awuser_id             ;
wire [3:0]                       axi_awlen                 ;
wire                             axi_awready               ;
wire                             axi_awvalid               ;
wire [MEM_DQ_WIDTH*8-1:0]        axi_wdata                 ;
wire [MEM_DQ_WIDTH*8/8-1:0]      axi_wstrb                 ;
wire                             axi_wready                ;
wire [3:0]                       axi_wusero_id             ;
wire                             axi_wusero_last           ;
wire [CTRL_ADDR_WIDTH-1:0]       axi_araddr                ;
wire                             axi_aruser_ap             ;
wire [3:0]                       axi_aruser_id             ;
wire [3:0]                       axi_arlen                 ;
wire                             axi_arready               ;
wire                             axi_arvalid               ;
wire [MEM_DQ_WIDTH*8-1:0]        axi_rdata                 ;
wire [3:0]                       axi_rid                   ;
wire                             axi_rlast                 ;
wire                             axi_rvalid                ;

wire                             resetn                    ;

reg  [26:0]                      cnt                       ;
//debug
wire [7:0]                       ck_dly_set_bin            ;
wire                             force_ck_dly_en           ;
wire [7:0]                       force_ck_dly_set_bin      ;
wire [7:0]                       dll_step                  ;
wire                             dll_lock                  ;

wire [1:0]                       init_read_clk_ctrl        ;
wire [3:0]                       init_slip_step            ;
wire                             force_read_clk_ctrl       ;
wire                             ddrphy_gate_update_en     ;

wire [34*MEM_DQS_WIDTH-1:0]      debug_data                ;
wire [13*MEM_DQS_WIDTH-1:0]      debug_slice_state         ;
wire [21:0]                      debug_calib_ctrl          ;

wire                             rd_fake_stop              ;

wire [MEM_DQS_WIDTH-1:0]         update_com_val_err_flag   ;

//user
wire [USER_DATA_WIDTH-1:0]       user_wr_data              ;
wire                             user_wr_data_valid        ;
wire                             user_ddr3_rd_en           ;
wire                             user_fifo_rd_en           ;
wire [USER_DATA_WIDTH-1:0]       user_rd_data              /*synthesis PAP_MARK_DEBUG="true"*/;
wire                             user_rd_data_valid        ;
wire [11:0]                      fifo_rdusedw              ;

//write
wire                             write_en                  ;
wire                             write_done_p              ;
wire [CTRL_ADDR_WIDTH-1:0]       ddr3_wr_addr              ;
wire [MEM_DQ_WIDTH*8-1:0]        ddr3_wr_data              ;
wire                             ddr3_wr_req               ;
wire [3:0]                       ddr3_axi_wr_id            ;
wire [3:0]                       ddr3_axi_wr_len           ;
wire                             ddr3_axi_wr_ap            ;

//read
wire                             read_en                   ;
wire                             read_done_p               ;
wire [CTRL_ADDR_WIDTH-1:0]       ddr3_rd_addr              ;
wire [CTRL_ADDR_WIDTH-1:0]       user_rd_addr              ; //USER OR DDR3 CLK DOMAIN
wire                             user_rd_addr_valid        ; //USER OR DDR3 CLK DOMAIN
wire [MEM_DQ_WIDTH*8-1:0]        ddr3_rd_data              ;
wire                             ddr3_rd_valid             ;
wire [3:0]                       ddr3_axi_rd_id            ;
wire [3:0]                       ddr3_axi_rd_len           ;
wire                             ddr3_axi_rd_ap            ;

//key ctrl
wire                             wr_test_ctrl_flag         ;
wire                             rd_test_ctrl_flag         ;



assign force_read_clk_ctrl        = 1'b0;
assign init_slip_step             = 4'b0;
assign init_read_clk_ctrl         = 2'b0;
assign rd_fake_stop               = 1'b0;
assign ddrphy_gate_update_en      = 1'b1;
assign force_ck_dly_en            = 1'b0;
assign force_ck_dly_set_bin       = 8'b00010100;

//***********************************************************************************

assign resetn = sys_rst_n ;

//***********************************************************************************
reg [2:0]   rst_board_dly;
reg [26:0]  cnt_rst   ;
reg         rst_board_rg = 1'b1;

always @(posedge sys_clk)
begin
  rst_board_dly <= {rst_board_dly[1:0],sys_rst_n};
end

always @(posedge sys_clk)
begin
  if (!rst_board_dly[2] && rst_board_dly[1]) begin
    cnt_rst <= 0;
    rst_board_rg <= 1'b1;
  end
  else begin
  	if(!rst_board_dly[2])begin
  		if(cnt_rst == TH_4MS) begin
  			rst_board_rg <= 1'b0;
  		end
  		else begin
  			cnt_rst <= cnt_rst + 1'b1;
  		end
  	end
  end
end

always@(posedge ddr3_core_clk or negedge resetn)
begin
   if (!resetn)
      cnt <= 27'd0;
   else if ( cnt >= TH_1S )
      cnt <= 27'd0;
   else
      cnt <= cnt + 27'd1;
end

always @(posedge ddr3_core_clk or negedge resetn)
begin
   if (!resetn)
      heart_beat_led <= 1'd1;
   else if ( cnt >= TH_1S )
      heart_beat_led <= ~heart_beat_led;
end

ipsxb_rst_sync u_core_clk_rst_sync(
    .clk                        (ddr3_core_clk   ),
    .rst_n                      (resetn          ),
    .sig_async                  (1'b1),
    .sig_synced                 (ddr3_core_rst_n )
);





ddr3_test  #
  (
   //***************************************************************************
   // The following parameters are Memory Feature
   //***************************************************************************
   .MEM_ROW_WIDTH          (MEM_ROW_ADDR_WIDTH),
   .MEM_COLUMN_WIDTH       (MEM_COL_ADDR_WIDTH),
   .MEM_BANK_WIDTH         (MEM_BADDR_WIDTH   ),
   .MEM_DQ_WIDTH           (MEM_DQ_WIDTH      ),
   .MEM_DM_WIDTH           (MEM_DM_WIDTH      ),
   .MEM_DQS_WIDTH          (MEM_DQS_WIDTH     ),
   .CTRL_ADDR_WIDTH        (CTRL_ADDR_WIDTH   )
  )

  I_ipsxb_ddr_top(
   .ref_clk                (sys_clk                ),
   .resetn                 (resetn                 ),
   .ddr_init_done          (ddr_init_done          ),
   .ddrphy_clkin           (ddr3_core_clk          ),
   .pll_lock               (pll_lock               ),

   .axi_awaddr             (axi_awaddr             ),
   .axi_awuser_ap          (axi_awuser_ap          ),
   .axi_awuser_id          (axi_awuser_id          ),
   .axi_awlen              (axi_awlen              ),
   .axi_awready            (axi_awready            ),
   .axi_awvalid            (axi_awvalid            ),

   .axi_wdata              (axi_wdata              ),
   .axi_wstrb              (axi_wstrb              ),
   .axi_wready             (axi_wready             ),
   .axi_wusero_id          (axi_wusero_id          ),
   .axi_wusero_last        (axi_wusero_last        ),

   .axi_araddr             (axi_araddr             ),
   .axi_aruser_ap          (axi_aruser_ap          ),
   .axi_aruser_id          (axi_aruser_id          ),
   .axi_arlen              (axi_arlen              ),
   .axi_arready            (axi_arready            ),
   .axi_arvalid            (axi_arvalid            ),

   .axi_rdata              (axi_rdata              ),
   .axi_rid                (axi_rid                ),
   .axi_rlast              (axi_rlast              ),
   .axi_rvalid             (axi_rvalid             ),

   .apb_clk                (1'b0                   ),
   .apb_rst_n              (1'b0                   ),
   .apb_sel                (1'b0                   ),
   .apb_enable             (1'b0                   ),
   .apb_addr               (8'd0                   ),
   .apb_write              (1'b0                   ),
   .apb_ready              (                       ),
   .apb_wdata              (16'd0                  ),
   .apb_rdata              (                       ),
   .apb_int                (                       ),
   .debug_data             (debug_data             ),
   .debug_slice_state      (debug_slice_state      ),
   .debug_calib_ctrl       (debug_calib_ctrl       ),
   .ck_dly_set_bin         (ck_dly_set_bin         ),
   .force_ck_dly_en        (force_ck_dly_en        ),
   .force_ck_dly_set_bin   (force_ck_dly_set_bin   ),
   .dll_step               (dll_step               ),
   .dll_lock               (dll_lock               ),
   .init_read_clk_ctrl     (init_read_clk_ctrl     ),
   .init_slip_step         (init_slip_step         ),
   .force_read_clk_ctrl    (force_read_clk_ctrl    ),
   .ddrphy_gate_update_en  (ddrphy_gate_update_en  ),
   .update_com_val_err_flag(update_com_val_err_flag),
   .rd_fake_stop           (rd_fake_stop           ),

   .mem_rst_n              (mem_rst_n              ),
   .mem_ck                 (mem_ck                 ),
   .mem_ck_n               (mem_ck_n               ),
   .mem_cke                (mem_cke                ),

   .mem_cs_n               (mem_cs_n               ),

   .mem_ras_n              (mem_ras_n              ),
   .mem_cas_n              (mem_cas_n              ),
   .mem_we_n               (mem_we_n               ),
   .mem_odt                (mem_odt                ),
   .mem_a                  (mem_a                  ),
   .mem_ba                 (mem_ba                 ),
   .mem_dqs                (mem_dqs                ),
   .mem_dqs_n              (mem_dqs_n              ),
   .mem_dq                 (mem_dq                 ),
   .mem_dm                 (mem_dm                 )
  );

key_filter u0_key_filter (
    .sys_clk               (sys_clk                ),   //系统时钟50Mhz
    .sys_rst_n             (sys_rst_n              ),   //全局复位
    .key_in                (wr_test_ctrl           ),   //按键输入信号

    .key_flag              (wr_test_ctrl_flag      )    //key_flag为1时表示消抖后检测到按键被按下
                                                        //key_flag为0时表示没有检测到按键被按下
);


user_data_gen #(
	.USER_DATA_WIDTH       (USER_DATA_WIDTH        )
)u_user_data_gen(
	.sys_clk               (sys_clk                ),
	.sys_rst_n             (sys_rst_n              ),
	.ddrc_init_done        (ddr_init_done          ),
	.wr_test_ctrl          (wr_test_ctrl_flag      ),
	.user_data             (user_wr_data           ),
	.user_data_valid       (user_wr_data_valid     ),
	.fifo_write_ready      (fifo_write_ready       )
);

wr_driver #(
    .CTRL_ADDR_WIDTH       (CTRL_ADDR_WIDTH      ),
    .MEM_DQ_WIDTH          (MEM_DQ_WIDTH         ),
    .MEM_SPACE_AW          (MEM_SPACE_AW         ),
	.USER_DATA_WIDTH       (USER_DATA_WIDTH      )
)u_wr_driver(
	.sys_clk               (sys_clk              ),
	.sys_rst_n             (sys_rst_n            ),
	.user_data_valid       (user_wr_data_valid   ),
	.user_data             (user_wr_data         ),
	.fifo_write_ready      (fifo_write_ready     ),
	.ddr3_core_clk         (ddr3_core_clk        ),
	.ddr3_core_rst_n       (ddr3_core_rst_n      ),
	.ddrc_init_done        (ddr_init_done        ),
	.write_en              (write_en             ),
	.write_done_p          (write_done_p         ),

    .ddr3_wr_addr          (ddr3_wr_addr         ),
	.ddr3_wr_data          (ddr3_wr_data         ),
	.ddr3_wr_req           (ddr3_wr_req          ),
    .ddr3_axi_id           (ddr3_axi_wr_id       ),
    .ddr3_axi_len          (ddr3_axi_wr_len      ),
    .ddr3_axi_ap           (ddr3_axi_wr_ap       )
);

ddr3_wr_ctrl  #(
    .CTRL_ADDR_WIDTH       (CTRL_ADDR_WIDTH      ),
    .MEM_DQ_WIDTH          (MEM_DQ_WIDTH         ),
    .MEM_SPACE_AW          (MEM_SPACE_AW         )
)u_ddr3_wr_ctrl(
	.clk                   (ddr3_core_clk        ),
	.rst_n                 (ddr3_core_rst_n      ),
	.write_en              (write_en             ),
	.write_done_p          (write_done_p         ),

    .ddr3_wr_addr          (ddr3_wr_addr         ),
	.ddr3_wr_data          (ddr3_wr_data         ),
	.ddr3_wr_req           (ddr3_wr_req          ),
    .ddr3_axi_id           (ddr3_axi_wr_id       ),
    .ddr3_axi_len          (ddr3_axi_wr_len      ),
    .ddr3_axi_ap           (ddr3_axi_wr_ap       ),

    .axi_awaddr            (axi_awaddr           ),
    .axi_awuser_ap         (axi_awuser_ap        ),
    .axi_awuser_id         (axi_awuser_id        ),
    .axi_awlen             (axi_awlen            ),
    .axi_awready           (axi_awready          ),
    .axi_awvalid           (axi_awvalid          ),

	.axi_wdata             (axi_wdata            ),
    .axi_wstrb             (axi_wstrb            ),
    .axi_wready            (axi_wready           ),
	.axi_wusero_id         (axi_wusero_id        ),
	.axi_wusero_last       (axi_wusero_last      )
);


key_filter u1_key_filter (
    .sys_clk               (sys_clk                ),   //系统时钟50Mhz
    .sys_rst_n             (sys_rst_n              ),   //全局复位
    .key_in                (rd_test_ctrl           ),   //按键输入信号

    .key_flag              (rd_test_ctrl_flag      )    //key_flag为1时表示消抖后检测到按键被按下
                                                        //key_flag为0时表示没有检测到按键被按下
);

user_data_recv  #(
	.USER_DATA_WIDTH       (USER_DATA_WIDTH        )
)u_user_data_recv(
	.sys_clk               (sys_clk                ),
	.sys_rst_n             (sys_rst_n              ),
	.ddrc_init_done        (ddr_init_done          ),
	.rd_test_ctrl          (rd_test_ctrl_flag      ),
	.user_ddr3_rd_en       (user_ddr3_rd_en        ),
	// .user_fifo_rd_en       (user_fifo_rd_en        ),
	.user_rd_data          (user_rd_data           ),
	.user_rd_data_valid    (user_rd_data_valid     )
	// .fifo_rdusedw          (fifo_rdusedw           )
);


// temp
assign user_rd_addr = 'b0 + 'd32;
assign user_rd_addr_valid = 1'b1;

// always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	// if(!ddr3_core_rst_n) begin
		// user_rd_addr <= 'b0;
		// user_rd_addr_valid <= 1'b0;
	// end else begin
		// user_rd_addr <= ({$random} % 4) << 5;
		// user_rd_addr_valid <= $random;
	// end
// end

rd_driver #(
    .CTRL_ADDR_WIDTH       (CTRL_ADDR_WIDTH      ),
    .MEM_DQ_WIDTH          (MEM_DQ_WIDTH         ),
    .MEM_SPACE_AW          (MEM_SPACE_AW         ),
	.USER_DATA_WIDTH       (USER_DATA_WIDTH      )
)u_rd_driver(
	.sys_clk               (sys_clk              ),
	.sys_rst_n             (sys_rst_n            ),
	.ddr3_core_clk         (ddr3_core_clk        ),
	.ddr3_core_rst_n       (ddr3_core_rst_n      ),
	.ddrc_init_done        (ddr_init_done        ),
	.user_ddr3_rd_en       (user_ddr3_rd_en      ),
	// .user_fifo_rd_en       (user_fifo_rd_en      ),
	.user_rd_data          (user_rd_data         ),
	.user_rd_data_valid    (user_rd_data_valid   ),
	.user_rd_addr          (user_rd_addr         ),
	.user_rd_addr_valid    (user_rd_addr_valid   ),
	// .fifo_rdusedw          (fifo_rdusedw         ),
	.read_en               (read_en              ),
	.read_done_p           (read_done_p          ),
	.ddr3_rd_valid         (ddr3_rd_valid        ),
	.ddr3_rd_data          (ddr3_rd_data         ),

	.ddr3_rd_addr          (ddr3_rd_addr         ),
	.ddr3_axi_id           (ddr3_axi_rd_id       ),
	.ddr3_axi_len          (ddr3_axi_rd_len      ),
	.ddr3_axi_ap           (ddr3_axi_rd_ap       )
);

ddr3_rd_ctrl #(
	.CTRL_ADDR_WIDTH       (CTRL_ADDR_WIDTH      ),
	.MEM_DQ_WIDTH          (MEM_DQ_WIDTH         ),
	.MEM_SPACE_AW          (MEM_SPACE_AW         )
)u_ddr3_rd_ctrl(
	.clk                   (ddr3_core_clk        ),
	.rst_n                 (ddr3_core_rst_n      ),
	.ddr3_rd_addr          (ddr3_rd_addr         ),
	.ddr3_axi_id           (ddr3_axi_rd_id       ),
	.ddr3_axi_len          (ddr3_axi_rd_len      ),
	.ddr3_axi_ap           (ddr3_axi_rd_ap       ),
	.read_en               (read_en              ),
	.read_done_p           (read_done_p          ),
	.ddr3_rd_valid         (ddr3_rd_valid        ),
	.ddr3_rd_data          (ddr3_rd_data         ),

	.axi_araddr            (axi_araddr           ),
	.axi_aruser_ap         (axi_aruser_ap        ),
	.axi_aruser_id         (axi_aruser_id        ),
	.axi_arlen             (axi_arlen            ),
	.axi_arready           (axi_arready          ),
	.axi_arvalid           (axi_arvalid          ),

	.axi_rdata             (axi_rdata            ),
	.axi_rid               (axi_rid              ),
	.axi_rlast             (axi_rlast            ),
	.axi_rvalid            (axi_rvalid           ),
	.err_flag              (err_flag_led         )
);

endmodule