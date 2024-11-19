module top(
    //公共接口
    input  wire clk,    //时钟输入
    input  wire hard_rst_n,  //来自外部的复位信号，低电平有效
    output wire core_active,//处理器活动指示，以肉眼可见速度翻转

    //JTAG接口
    input  wire JTAG_TMS,
    input  wire JTAG_TDI,
    output wire JTAG_TDO,
    input  wire JTAG_TCK, //即使没有JTAG，也保留这个接口，使得约束可以通用

    // //SD、TF卡接口
    // output wire       sd_clk,
    // inout             sd_cmd,
    // input  wire [3:0] sd_dat,//需要上拉
    // key[0]切换dso通道 key[1] 切换dso/la
    input wire [1:0] key,
    output wire dac_clk,
    output wire [7:0] dac_data,
    // dso 接口
    input wire [7:0] ad_data,
    output wire       ad_clk,
    output wire       rstn_out,
    //i2c
    output wire       iic_tx_scl,
    inout  wire       iic_tx_sda,
    output wire       led_int,

    // hdmi 接口
    output wire       pix_clk,     //pixclk
    output wire       vs_out,
    output wire       hs_out,
    output wire       de_out,
    output wire [7:0] r_out,
    output wire [7:0] g_out,
    output wire [7:0] b_out,
    // eth 接口
    input  wire                         eth_rxc                    ,
    input  wire                         eth_rx_ctl                 ,
    input  wire        [   3:0]         eth_rxd                    ,
    output wire                         eth_txc                    ,
    output wire                         eth_tx_ctl                 ,
    output wire        [   3:0]         eth_txd                    ,
    output wire                         eth_rst_n                  ,

    //FPIOA
    inout  wire [8-1:0] fpioa  //处理器IO接口

    // //DDR
    // output                               mem_rst_n                 ,
    // output                               mem_ck                    ,
    // output                               mem_ck_n                  ,
    // output                               mem_cke                   ,
    // output                               mem_cs_n                  ,
    // output                               mem_ras_n                 ,
    // output                               mem_cas_n                 ,
    // output                               mem_we_n                  ,
    // output                               mem_odt                   ,
    // output      [15-1:0] mem_a                     ,
    // output      [3-1:0]    mem_ba                    ,
    // inout       [32/8-1:0]     mem_dqs                   ,
    // inout       [32/8-1:0]     mem_dqs_n                 ,
    // inout       [32-1:0]       mem_dq                    ,
    // output      [32/8-1:0]     mem_dm                    ,
    // output reg                           heart_beat_led            ,
    // output                               ddr_init_done             


   );
    // wire                 s5_icb_cmd_valid;
    // wire                 s5_icb_cmd_ready;
    // wire [31:0]          s5_icb_cmd_addr ;
    // wire                 s5_icb_cmd_read ;
    // wire [31:0]          s5_icb_cmd_wdata;
    // wire [3:0]           s5_icb_cmd_wmask;
    // wire                 s5_icb_rsp_valid;
    // wire                 s5_icb_rsp_ready;
    // wire                 s5_icb_rsp_err  ;
    // wire [31:0]          s5_icb_rsp_rdata;
    // wire                 core_rst_n;
    // wire ddr_clk,pll_lock;
    // wire pll_lock,
    sparrow_soc inst_sparrow_soc  (
        .clk(clk),    
        .hard_rst_n(hard_rst_n),  
        .core_active(core_active),
        .core_rst_n(core_rst_n),
        .JTAG_TMS(JTAG_TMS),
        .JTAG_TDI(JTAG_TDI),
        .JTAG_TDO(JTAG_TDO),
        .JTAG_TCK(JTAG_TCK), 
        // .sd_clk(sd_clk),
        // .sd_cmd(sd_cmd),
        // .sd_dat(sd_dat),
        .key(key),
        .dac_clk(dac_clk),
        .dac_data(dac_data),

        .ad_clk(ad_clk),  
        .ad_data(ad_data),
        .rstn_out(rstn_out),
        .iic_tx_scl(iic_tx_scl),
        .iic_tx_sda(iic_tx_sda),
        .led_int(led_int),

        .pix_clk(pix_clk),
        .vs_out(vs_out),
        .hs_out(hs_out),
        .de_out(de_out),
        .r_out(r_out),
        .g_out(g_out),
        .b_out(b_out),

        .eth_rxc    (eth_rxc    ),
        .eth_rx_ctl (eth_rx_ctl ),
        .eth_rxd    (eth_rxd    ),
        .eth_txc    (eth_txc    ),
        .eth_tx_ctl (eth_tx_ctl ),
        .eth_txd    (eth_txd    ),
        .eth_rst_n  (eth_rst_n  ),

        // .s5_icb_cmd_valid(s5_icb_cmd_valid),
        // .s5_icb_cmd_ready(s5_icb_cmd_ready),
        // .s5_icb_cmd_addr (s5_icb_cmd_addr ),
        // .s5_icb_cmd_read (s5_icb_cmd_read ),
        // .s5_icb_cmd_wdata(s5_icb_cmd_wdata),
        // .s5_icb_cmd_wmask(s5_icb_cmd_wmask),
        // .s5_icb_rsp_valid(s5_icb_rsp_valid),
        // .s5_icb_rsp_ready(s5_icb_rsp_ready),
        // .s5_icb_rsp_err  (s5_icb_rsp_err  ),
        // .s5_icb_rsp_rdata(s5_icb_rsp_rdata),

        .fpioa(fpioa)
    );
//axi bus   
    // wire [28-1:0]  axi_awaddr                 ;
    // wire                        axi_awuser_ap              ;
    // wire [3:0]                  axi_awuser_id              ;
    // wire [3:0]                  axi_awlen                  ;
    // wire                        axi_awready                ;
    // wire                        axi_awvalid                ;
    // wire [32*8-1:0]             axi_wdata                  ;
    // wire [32*8/8-1:0]           axi_wstrb                  ;
    // wire                        axi_wready                 ;
    // wire [3:0]                  axi_wusero_id              ;
    // wire                        axi_wusero_last            ;
    // wire [28-1:0]               axi_araddr                 ;
    // wire                        axi_aruser_ap              ;
    // wire [3:0]                  axi_aruser_id              ;
    // wire [3:0]                  axi_arlen                  ;
    // wire                        axi_arready                ;
    // wire                        axi_arvalid                ;
    // wire [32*8-1:0]             axi_rdata                  ;
    // wire                        axi_rvalid                 ;
    // wire [3:0]                  axi_rid                    ;
    // wire                        axi_rlast                  ;

    // wire ddr_rst_n;
    // reg [15:0] rstn_1ms;

    // always @(posedge clk or negedge core_rst_n)
    // begin
    //     if(!core_rst_n)
    //         rstn_1ms <= 16'd0;
    //     else
    //     begin
    //         if(rstn_1ms == 16'd50000)
    //             rstn_1ms <= rstn_1ms;
    //         else
    //             rstn_1ms <= rstn_1ms + 16'b1;
    //     end
    // end
    
    // assign ddr_rst_n = (rstn_1ms == 16'd50000);


    // icb_ddr inst_icb_ddr
    //     (
    //         .clk             (clk),
    //         .rst_n           (core_rst_n),
    //         .s_icb_cmd_valid (s5_icb_cmd_valid),
    //         .s_icb_cmd_ready (s5_icb_cmd_ready),
    //         .s_icb_cmd_addr  (s5_icb_cmd_addr),
    //         .s_icb_cmd_read  (s5_icb_cmd_read),
    //         .s_icb_cmd_wdata (s5_icb_cmd_wdata),
    //         .s_icb_cmd_wmask (s5_icb_cmd_wmask),
    //         .s_icb_rsp_valid (s5_icb_rsp_valid),
    //         .s_icb_rsp_ready (s5_icb_rsp_ready),
    //         .s_icb_rsp_err   (s5_icb_rsp_err),
    //         .s_icb_rsp_rdata (s5_icb_rsp_rdata),
    //         .axi_clk         (ddr_clk),
    //         .axi_rst_n       (ddr_rst_n),
    //         .axi_awaddr      (axi_awaddr),
    //         .axi_awuser_ap   (axi_awuser_ap),
    //         .axi_awuser_id   (axi_awuser_id),
    //         .axi_awlen       (axi_awlen),
    //         .axi_awready     (axi_awready),
    //         .axi_awvalid     (axi_awvalid),
    //         .axi_wdata       (axi_wdata),
    //         .axi_wstrb       (axi_wstrb),
    //         .axi_wready      (axi_wready),
    //         .axi_wusero_id   (axi_wusero_id),
    //         .axi_wusero_last (axi_wusero_last),
    //         .axi_araddr      (axi_araddr),
    //         .axi_aruser_ap   (axi_aruser_ap),
    //         .axi_aruser_id   (axi_aruser_id),
    //         .axi_arlen       (axi_arlen),
    //         .axi_arready     (axi_arready),
    //         .axi_arvalid     (axi_arvalid),
    //         .axi_rdata       (axi_rdata),
    //         .axi_rid         (axi_rid),
    //         .axi_rlast       (axi_rlast),
    //         .axi_rvalid      (axi_rvalid)
    //     );

    // axi_ddr inst_ddr3 (
    //          .ref_clk                   (clk            ),
    //          .resetn                    (ddr_rst_n          ),// input
    //          .ddr_init_done             (ddr_init_done      ),// output
    //          .ddrphy_clkin              (ddr_clk            ),// output
    //          .pll_lock                  (pll_lock           ),// output

    //          .axi_awaddr                (axi_awaddr         ),// input [27:0]
    //          .axi_awuser_ap             (1'b0               ),// input
    //          .axi_awuser_id             (axi_awuser_id      ),// input [3:0]
    //          .axi_awlen                 (axi_awlen          ),// input [3:0]
    //          .axi_awready               (axi_awready        ),// output
    //          .axi_awvalid               (axi_awvalid        ),// input
    //          .axi_wdata                 (axi_wdata          ),
    //          .axi_wstrb                 (axi_wstrb          ),// input [31:0]
    //          .axi_wready                (axi_wready         ),// output
    //          .axi_wusero_id             (                   ),// output [3:0]
    //          .axi_wusero_last           (axi_wusero_last    ),// output
    //          .axi_araddr                (axi_araddr         ),// input [27:0]
    //          .axi_aruser_ap             (1'b0               ),// input
    //          .axi_aruser_id             (axi_aruser_id      ),// input [3:0]
    //          .axi_arlen                 (axi_arlen          ),// input [3:0]
    //          .axi_arready               (axi_arready        ),// output
    //          .axi_arvalid               (axi_arvalid        ),// input
    //          .axi_rdata                 (axi_rdata          ),// output [255:0]
    //          .axi_rid                   (axi_rid            ),// output [3:0]
    //          .axi_rlast                 (axi_rlast          ),// output
    //          .axi_rvalid                (axi_rvalid         ),// output

    //          .apb_clk                   (1'b0               ),// input
    //          .apb_rst_n                 (1'b1               ),// input
    //          .apb_sel                   (1'b0               ),// input
    //          .apb_enable                (1'b0               ),// input
    //          .apb_addr                  (8'b0               ),// input [7:0]
    //          .apb_write                 (1'b0               ),// input
    //          .apb_ready                 (                   ), // output
    //          .apb_wdata                 (16'b0              ),// input [15:0]
    //          .apb_rdata                 (                   ),// output [15:0]
    //          .apb_int                   (                   ),// output

    //          .mem_rst_n                 (mem_rst_n          ),// output
    //          .mem_ck                    (mem_ck             ),// output
    //          .mem_ck_n                  (mem_ck_n           ),// output
    //          .mem_cke                   (mem_cke            ),// output
    //          .mem_cs_n                  (mem_cs_n           ),// output
    //          .mem_ras_n                 (mem_ras_n          ),// output
    //          .mem_cas_n                 (mem_cas_n          ),// output
    //          .mem_we_n                  (mem_we_n           ),// output
    //          .mem_odt                   (mem_odt            ),// output
    //          .mem_a                     (mem_a              ),// output [14:0]
    //          .mem_ba                    (mem_ba             ),// output [2:0]
    //          .mem_dqs                   (mem_dqs            ),// inout [3:0]
    //          .mem_dqs_n                 (mem_dqs_n          ),// inout [3:0]
    //          .mem_dq                    (mem_dq             ),// inout [31:0]
    //          .mem_dm                    (mem_dm             ),// output [3:0]
    //          //debug
    //          .debug_data                (                   ),// output [135:0]
    //          .debug_slice_state         (                   ),// output [51:0]
    //          .debug_calib_ctrl          (                   ),// output [21:0]
    //          .ck_dly_set_bin            (                   ),// output [7:0]
    //          .force_ck_dly_en           (1'b0               ),// input
    //          .force_ck_dly_set_bin      (8'h05              ),// input [7:0]
    //          .dll_step                  (                   ),// output [7:0]
    //          .dll_lock                  (                   ),// output
    //          .init_read_clk_ctrl        (2'b0               ),// input [1:0]
    //          .init_slip_step            (4'b0               ),// input [3:0]
    //          .force_read_clk_ctrl       (1'b0               ),// input
    //          .ddrphy_gate_update_en     (1'b0               ),// input
    //          .update_com_val_err_flag   (                   ),// output [3:0]
    //          .rd_fake_stop              (1'b0               ) // input
    //    );


//心跳信号
// reg [26:0] cnt;

// localparam TH_1S = 27'd50_000_000;
//      always@(posedge ddr_clk) begin
//         if (!ddr_init_done)
//             cnt <= 27'd0;
//         else if ( cnt >= TH_1S )
//             cnt <= 27'd0;
//         else
//             cnt <= cnt + 27'd1;
//      end

//      always @(posedge ddr_clk)
//         begin
//         if (!ddr_init_done)
//             heart_beat_led <= 1'd1;
//         else if ( cnt >= TH_1S )
//             heart_beat_led <= ~heart_beat_led;
//     end
endmodule