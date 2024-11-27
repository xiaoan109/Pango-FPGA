// `define PDS_LITE
module dso_top #(
  parameter MEM_ROW_ADDR_WIDTH   = 15,

  parameter MEM_COL_ADDR_WIDTH   = 10,

  parameter MEM_BADDR_WIDTH      = 3,

  parameter MEM_DQ_WIDTH         =  32,

  parameter MEM_DM_WIDTH         = MEM_DQ_WIDTH/8,
  parameter MEM_DQS_WIDTH        = MEM_DQ_WIDTH/8,
  parameter CTRL_ADDR_WIDTH      = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH,

  parameter USER_DATA_WIDTH      = 8
  )(
  input wire sys_clk,   //!系统时钟50MHz
  input wire sys_rst_n, //!系统复位，低电平有效

  //hdmi_in
  input wire       i_vs_hdmi,  //!HDMI输入场同步信号
  input wire       i_hs_hdmi,  //!HDMI输入行同步信号
  input wire       i_de_hdmi,  //!HDMI输入数据有效信号
  input wire [7:0] i_r_hdmi,   //!HDMI输入数据R通道
  input wire [7:0] i_g_hdmi,   //!HDMI输入数据G通道
  input wire [7:0] i_b_hdmi,   //!HDMI输入数据B通道
  input wire       rstn_out,   //!HDMI输入复位
  //hdmi_out
  input  wire       pix_clk,  //!HDMI像素时钟
  output wire       vs_out,   //!HDMI输出场同步信号
  output wire       hs_out,   //!HDMI输出行同步信号
  output wire       de_out,   //!HDMI输出数据有效信号
  output wire [7:0] r_out,    //!HDMI输出数据R通道
  output wire [7:0] g_out,    //!HDMI输出数据G通道
  output wire [7:0] b_out,    //!HDMI输出数据B通道

  input wire       ad_clk,  //!ADC采样时钟
  input wire [7:0] ad_data, //!ADC采样数据

  //ctrl regs
  input wire [7:0] trig_level,  //!示波器触发电平(0-255对应-5~5V)
  input wire [9:0] deci_rate,  //!示波器抽样率
  input wire wave_run,  //!示波器RUN/STOP
  input wire trig_edge,  //!示波器触发类型(上升/下降)
  input wire [4:0] v_scale,  //!示波器垂直缩放倍数(1/2/4倍)
  input wire fft_en,  //!FFT频域显示开关
  input wire fir_en,  //!FIR低通滤波开关
  input wire [11:0] trig_line,  //!触发电平绘制像素点
  //measure regs
  output wire [19:0] ad_freq ,    //!ADC信号的频率
  output wire [7:0] ad_vpp   ,    //!ADC信号峰峰值
  output wire [7:0] ad_max   ,    //!ADC信号最大值
  output wire [7:0] ad_min   ,    //!ADC信号最小值
  //DDR3
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


  //parameter define
  parameter TH_1S         = 27'd50_000_000;
  parameter TH_4MS        = 27'd200_000;
  parameter REM_DQS_WIDTH = 4 - MEM_DQS_WIDTH;

  `ifdef SIMULATION
  parameter MEM_SPACE_AW = 13; //to reduce simulation time
  `else
  parameter MEM_SPACE_AW = CTRL_ADDR_WIDTH;
  `endif


  wire [23:0] pixel_data;

  wire        ad_pulse;
  wire        debug_clk;
  wire        deci_valid;

  wire [ 7:0] hdmi_r_out;
  wire [ 7:0] hdmi_g_out;
  wire [ 7:0] hdmi_b_out;
  wire        hdmi_vs_out;
  wire        hdmi_hs_out;
  wire        hdmi_de_out;

  wire [23:0] osd_data_out;
  wire        osd_vs_out;
  wire        osd_hs_out;
  wire        osd_de_out;

  wire [23:0] grid_data_out;
  wire        grid_vs_out;
  wire        grid_hs_out;
  wire        grid_de_out;

  wire        ad_buf_wr;
  // wire [11:0] ad_buf_wr_addr;
  wire [ 7:0] ad_buf_data;
  wire [ 9:0] wave_rd_addr;
  wire [ 7:0] ad_buf_rd_data;
  wire        ad_sample_trig;
  wire        ad_sample_trig_sync;
  wire [ 9:0] ad_sample_offset;
  reg  [ 6:0] offset_addr; // 1 ~ 127 -> ddr3 addr: 0 ~ 31
  wire        wr_over;
  wire        wr_over_cdc;
  wire        cdc_busy;

  wire [11:0] ram_rd_data;

  wire [ 7:0] ad_filter_data;

  assign hdmi_hs_out = i_hs_hdmi;
  assign hdmi_vs_out = i_vs_hdmi;
  assign hdmi_de_out = i_de_hdmi;
  assign hdmi_r_out  = i_r_hdmi;
  assign hdmi_g_out  = i_g_hdmi;
  assign hdmi_b_out  = i_b_hdmi;


  wire                             ddr3_core_rst_n           ;
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
  // wire [USER_DATA_WIDTH-1:0]       user_wr_data              ;
  // wire                             user_wr_data_valid        ;
  wire                             user_ddr3_rd_en           ;
  // wire                             user_fifo_rd_en           ;
  // wire [USER_DATA_WIDTH-1:0]       user_rd_data              /*synthesis PAP_MARK_DEBUG="true"*/;
  // wire                             user_rd_data_valid        /* synthesis PAP_MARK_DEBUG="true" */;
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
  wire [CTRL_ADDR_WIDTH-1:0]       user_rd_addr              /* synthesis PAP_MARK_DEBUG="true" */; //USER OR DDR3 CLK DOMAIN
  wire                             user_rd_addr_valid        /* synthesis PAP_MARK_DEBUG="true" */; //USER OR DDR3 CLK DOMAIN
  wire [MEM_DQ_WIDTH*8-1:0]        ddr3_rd_data              ;
  wire                             ddr3_rd_valid             ;
  wire [3:0]                       ddr3_axi_rd_id            ;
  wire [3:0]                       ddr3_axi_rd_len           ;
  wire                             ddr3_axi_rd_ap            ;



  fir_wrapper u_fir_wrapper (
    .ad_clk     (ad_clk),
    .rst_n      (sys_rst_n),
    .ad_data    (ad_data),
    .fir_en     (fir_en),
    .ad_data_out(ad_filter_data)
  );


  //参数测量模块，测量输入波形峰峰值和频率
  param_measure u_param_measure (
    .clk  (sys_clk),
    .rst_n(sys_rst_n),

    .trig_level(trig_level),  //trig_level

    .ad_clk   (ad_clk),
    .ad_data  (ad_filter_data),
    .ad_pulse (ad_pulse),
    .ad_freq  (ad_freq),   // 频率
    .ad_vpp   (ad_vpp),    // 峰峰值
    .ad_max   (ad_max),
    .ad_min   (ad_min)
  );

  //抽样控制模块
  decimator u_decimator (
    .ad_clk    (ad_clk),
    .rst_n     (sys_rst_n),
    .deci_rate (deci_rate),
    .deci_valid(deci_valid)
  );

  //output osd

  dso_ui_display u_dso_ui_display (
    .rst_n     (rstn_out),
    .pclk      (pix_clk),
    .ad_clk    (ad_clk),
    .sys_clk   (sys_clk),
    .i_hs      (hdmi_hs_out),
    .i_vs      (hdmi_vs_out),
    .i_de      (hdmi_de_out),
    .i_data    ({hdmi_r_out, hdmi_g_out, hdmi_b_out}),
    .ad_freq   (ad_freq),
    .ad_vpp    (ad_vpp),
    .ad_max    (ad_max),
    .ad_min    (ad_min),
    .trig_level(trig_level),
    .trig_edge (trig_edge),
    .fft_en    (fft_en),
    .deci_rate (deci_rate),
    .fir_en    (fir_en),
    .v_scale   (v_scale),
    .o_hs      (osd_hs_out),
    .o_vs      (osd_vs_out),
    .o_de      (osd_de_out),
    .o_data    (osd_data_out)
  );


  //output grid
  dso_grid_display u_dso_grid_display (
    .rst_n (rstn_out),
    .pclk  (pix_clk),
    .i_hs  (osd_hs_out),
    .i_vs  (osd_vs_out),
    .i_de  (osd_de_out),
    .i_data(osd_data_out),
    .o_hs  (grid_hs_out),
    .o_vs  (grid_vs_out),
    .o_de  (grid_de_out),
    .o_data(grid_data_out)
  );

  //output hdmi wave
  dso_wave_display u_dso_wave_display (
    .rst_n             (rstn_out),
    .pclk              (pix_clk),
    .wave_color        (24'hff0000),
    // .ad_clk            (ad_clk),
    // .ad_buf_wr     (ad_buf_wr),
    // .ad_buf_wr_addr(ad_buf_wr_addr),
    // .ad_buf_data   (ad_buf_data),
    .wave_rd_addr      (wave_rd_addr),
    .ad_buf_rd_data    (ad_buf_rd_data),
    .fft_en            (fft_en),
    .ram_rd_data       (ram_rd_data),
    .i_hs              (grid_hs_out),
    .i_vs              (grid_vs_out),
    .i_de              (grid_de_out),
    .i_data            (grid_data_out),
    .o_hs              (hs_out),
    .o_vs              (vs_out),
    .o_de              (de_out),
    .o_data            ({r_out, g_out, b_out}),
    .wr_over           (wr_over),
    .v_scale           (v_scale),
    .trig_line         (trig_line)
  );

  cdc u_cdc (
    .clk1  (pix_clk),
    .rst1_n(rstn_out),

    .clk2  (ad_clk),
    .rst2_n(sys_rst_n),

    .a(wr_over),

    .b_r (wr_over_cdc),
    .busy(cdc_busy)
  );

  ad9280_sample u_ad9280_sample (
    .ad_clk        (ad_clk),
    .rst_n         (sys_rst_n),
    .ad_data       (ad_filter_data),
    .deci_valid    (deci_valid),
    .wave_run      (wave_run),
    .trig_level    (trig_level),
    .trig_edge     (trig_edge),
    // .wave_rd_addr  (wave_rd_addr),
    .wr_over       (wr_over_cdc),
    .ad_buf_wr     (ad_buf_wr),
    // .ad_buf_wr_addr(ad_buf_wr_addr),
    .ad_buf_data   (ad_buf_data),
    // .ad_buf_rd_addr(ad_buf_rd_addr)
	.ad_sample_trig(ad_sample_trig),
	.ad_sample_offset(ad_sample_offset)
  );

  wr_driver #(
    .CTRL_ADDR_WIDTH       (CTRL_ADDR_WIDTH      ),
    .MEM_DQ_WIDTH          (MEM_DQ_WIDTH         ),
    .MEM_SPACE_AW          (MEM_SPACE_AW         ),
	.USER_DATA_WIDTH       (USER_DATA_WIDTH      )
  )u_wr_driver(
	.sys_clk               (ad_clk               ),
	.sys_rst_n             (sys_rst_n            ),
	.user_data_valid       (ad_buf_wr            ),
	.user_data             (ad_buf_data          ),
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

  //TODO
  cdc_data CD (
  .clk( ddr3_core_clk ),
  .nrst( 1'b1 ),
  .d( ad_sample_trig ),
  .q( ad_sample_trig_sync )
);

  edge_detect #(
    .WIDTH( 1 )
  ) ED1 (
    .clk( ddr3_core_clk ),
    .anrst( 1'b1 ),
    .in( ad_sample_trig_sync ),
    .rising( user_rd_addr_valid ),
    .falling(  ),
    .both(  )
  );
  // always @(posedge ddr3_core_clk or negedge ddr3_core_rst_n) begin
	// if(!ddr3_core_rst_n) begin
      // offset_addr <= 7'b0;
	// end else if(user_rd_addr_valid) begin
	  // offset_addr <= ad_sample_offset[6:0];
	// end
  // end
  // assign user_rd_addr = ddr3_wr_addr - 4 * 4 * 8 + (offset_addr >> 2) & ~3'h7; //DDR3_READ_TIMES/2 * BURST_LEN * 8
  assign user_rd_addr = ddr3_wr_addr - 4 * 4 * 8; //DDR3_READ_TIMES/2 * BURST_LEN * 8
  assign user_ddr3_rd_en = ddr_init_done; //TODO

  rd_driver #(
    .CTRL_ADDR_WIDTH       (CTRL_ADDR_WIDTH      ),
    .MEM_DQ_WIDTH          (MEM_DQ_WIDTH         ),
    .MEM_SPACE_AW          (MEM_SPACE_AW         ),
	.USER_DATA_WIDTH       (USER_DATA_WIDTH      )
  )u_rd_driver(
	.sys_clk               (pix_clk              ),
	.sys_rst_n             (sys_rst_n            ),
	.ddr3_core_clk         (ddr3_core_clk        ),
	.ddr3_core_rst_n       (ddr3_core_rst_n      ),
	.ddrc_init_done        (ddr_init_done        ),
	.user_ddr3_rd_en       (user_ddr3_rd_en      ),
	// .user_fifo_rd_en       (user_fifo_rd_en      ),
	.user_wave_rd_addr     (wave_rd_addr         ), //pix clk domain
	.user_rd_data          (ad_buf_rd_data       ),
	// .user_rd_data_valid    (user_rd_data_valid   ),
	.user_rd_addr          (user_rd_addr         ), //ddr3 core clk domain
	.user_rd_addr_valid    (user_rd_addr_valid   ), //ddr3 core clk domain
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


`ifdef PDS_LITE
  fft_adc_top u_fft_adc_top (
    .sys_clk  (ad_clk),
    .sys_rst_n(sys_rst_n),

    .ad_data    (ad_filter_data),
    .deci_valid (deci_valid),
    .fft_en     (fft_en),
    .rd_clk     (pix_clk),
    .rd_addr    (wave_rd_addr),
    .ram_rd_data(ram_rd_data)
  );
`else
  assign ram_rd_data = 12'b0;
`endif

endmodule
