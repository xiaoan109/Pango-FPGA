// +FHEADER =====================================================================
// FilePath       : \pangoPRJ\RISC-V\rtl\SparrowRV\rtl\soc\sparrow_soc.v
// Author         : zkwang2001 1922601163@qq.com
// CreateDate     : 24-10-22
// LastEditors    : zkwang2001 1922601163@qq.com
// LastEditTime   : 24-11-10
// Version        :
// Description    : 
//                  
// 
// Parameter       :
//                  
// 
// IO Port         :
//                  
// 
// Modification History
//    Date   |   Author   |   Version   |   Change Description
// ==============================================================================
//  23-08-24 |     NJU    |     0.1     | Original Version
//                  
// 
// -FHEADER =====================================================================
`include "defines.v"
module sparrow_soc (
    //公共接口
    input  wire clk,    //时钟输入
    input  wire hard_rst_n,  //来自外部的复位信号，低电平有效
    output wire core_active,//处理器活动指示，以肉眼可见速度翻转
    output wire core_rst_n,
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
    //s5
    // output wire                 s5_icb_cmd_valid,
    // input  wire                 s5_icb_cmd_ready,
    // output wire [`MemAddrBus]   s5_icb_cmd_addr ,
    // output wire                 s5_icb_cmd_read ,
    // output wire [`MemBus]       s5_icb_cmd_wdata,
    // output wire [3:0]           s5_icb_cmd_wmask,
    // input  wire                 s5_icb_rsp_valid,
    // output wire                 s5_icb_rsp_ready,
    // input  wire                 s5_icb_rsp_err  ,
    // input  wire [`MemBus]       s5_icb_rsp_rdata,

    //FPIOA
    inout  wire [`FPIOA_PORT_NUM-1:0] fpioa//处理器IO接口


);

//*********************************
//           定义总线线网
//
//m0
wire                 jtag_icb_cmd_valid;
wire                 jtag_icb_cmd_ready;
wire [`MemAddrBus]   jtag_icb_cmd_addr ;
wire                 jtag_icb_cmd_read ;
wire [`MemBus]       jtag_icb_cmd_wdata;
wire [3:0]           jtag_icb_cmd_wmask;
wire                 jtag_icb_rsp_valid;
wire                 jtag_icb_rsp_ready;
wire                 jtag_icb_rsp_err  ;
wire [`MemBus]       jtag_icb_rsp_rdata;
//m1
wire                 core_icb_cmd_valid;
wire                 core_icb_cmd_ready;
wire [`MemAddrBus]   core_icb_cmd_addr ;
wire                 core_icb_cmd_read ;
wire [`MemBus]       core_icb_cmd_wdata;
wire [3:0]           core_icb_cmd_wmask;
wire                 core_icb_rsp_valid;
wire                 core_icb_rsp_ready;
wire                 core_icb_rsp_err  ;
wire [`MemBus]       core_icb_rsp_rdata;
//s0
wire                 iram_icb_cmd_valid;
wire                 iram_icb_cmd_ready;
wire [`MemAddrBus]   iram_icb_cmd_addr ;
wire                 iram_icb_cmd_read ;
wire [`MemBus]       iram_icb_cmd_wdata;
wire [3:0]           iram_icb_cmd_wmask;
wire                 iram_icb_rsp_valid;
wire                 iram_icb_rsp_ready;
wire                 iram_icb_rsp_err  ;
wire [`MemBus]       iram_icb_rsp_rdata;
//s1
wire                 sram_icb_cmd_valid;
wire                 sram_icb_cmd_ready;
wire [`MemAddrBus]   sram_icb_cmd_addr ;
wire                 sram_icb_cmd_read ;
wire [`MemBus]       sram_icb_cmd_wdata;
wire [3:0]           sram_icb_cmd_wmask;
wire                 sram_icb_rsp_valid;
wire                 sram_icb_rsp_ready;
wire                 sram_icb_rsp_err  ;
wire [`MemBus]       sram_icb_rsp_rdata;
//s2
wire                 sysp_icb_cmd_valid;
wire                 sysp_icb_cmd_ready;
wire [`MemAddrBus]   sysp_icb_cmd_addr ;
wire                 sysp_icb_cmd_read ;
wire [`MemBus]       sysp_icb_cmd_wdata;
wire [3:0]           sysp_icb_cmd_wmask;
wire                 sysp_icb_rsp_valid;
wire                 sysp_icb_rsp_ready;
wire                 sysp_icb_rsp_err  ;
wire [`MemBus]       sysp_icb_rsp_rdata;
//s3
wire                 plic_icb_cmd_valid;
wire                 plic_icb_cmd_ready;
wire [`MemAddrBus]   plic_icb_cmd_addr ;
wire                 plic_icb_cmd_read ;
wire [`MemBus]       plic_icb_cmd_wdata;
wire [3:0]           plic_icb_cmd_wmask;
wire                 plic_icb_rsp_valid;
wire                 plic_icb_rsp_ready;
wire                 plic_icb_rsp_err  ;
wire [`MemBus]       plic_icb_rsp_rdata;
//s4
// wire                 sdrd_icb_cmd_valid;
// wire                 sdrd_icb_cmd_ready;
// wire [`MemAddrBus]   sdrd_icb_cmd_addr ;
// wire                 sdrd_icb_cmd_read ;
// wire [`MemBus]       sdrd_icb_cmd_wdata;
// wire [3:0]           sdrd_icb_cmd_wmask;
// wire                 sdrd_icb_rsp_valid;
// wire                 sdrd_icb_rsp_ready;
// wire                 sdrd_icb_rsp_err  ;
// wire [`MemBus]       sdrd_icb_rsp_rdata;

// dds icb signals
wire                 dds_icb_cmd_valid;
wire                 dds_icb_cmd_ready;
wire [`MemAddrBus]   dds_icb_cmd_addr ;
wire                 dds_icb_cmd_read ;
wire [`MemBus]       dds_icb_cmd_wdata;
wire [3:0]           dds_icb_cmd_wmask;
wire                 dds_icb_rsp_valid;
wire                 dds_icb_rsp_ready;
wire                 dds_icb_rsp_err  ;
wire [`MemBus]       dds_icb_rsp_rdata;
// dso icb signals  
wire                 dso_icb_cmd_valid;
wire                 dso_icb_cmd_ready;
wire [`MemAddrBus]   dso_icb_cmd_addr ;
wire                 dso_icb_cmd_read ;
wire [`MemBus]       dso_icb_cmd_wdata;
wire [3:0]           dso_icb_cmd_wmask;
wire                 dso_icb_rsp_valid;
wire                 dso_icb_rsp_ready;
wire                 dso_icb_rsp_err  ;
wire [`MemBus]       dso_icb_rsp_rdata;
// la icb signals 
wire                 la_icb_cmd_valid;
wire                 la_icb_cmd_ready;
wire [`MemAddrBus]   la_icb_cmd_addr ;
wire                 la_icb_cmd_read ;
wire [`MemBus]       la_icb_cmd_wdata;
wire [3:0]           la_icb_cmd_wmask;
wire                 la_icb_rsp_valid;
wire                 la_icb_rsp_ready;
wire                 la_icb_rsp_err  ;
wire [`MemBus]       la_icb_rsp_rdata;

  

//其他信号
wire halt_req;
wire jtag_rst_en;
wire [4:0]core_ex_trap_id;//中断源ID
wire [3:0]irq_fpioa_eli;
wire [15:0]plic_irq_port;


//
// dso hdmi signal 
wire   dso_pix_clk  ;
wire   dso_vs_out   ;
wire   dso_hs_out   ;
wire   dso_de_out   ;
wire   [7:0] dso_r_out ;   
wire   [7:0] dso_g_out ;   
wire   [7:0] dso_b_out ;   
wire  dso_rstn_out;   
wire  dso_iic_tx_scl; 
wire  dso_iic_tx_sda; 
wire  dso_led_int;    

// la hdmi signal 
wire   la_pix_clk  ;
wire   la_vs_out   ;
wire   la_hs_out   ;
wire   la_de_out   ;
wire   [7:0] la_r_out ;   
wire   [7:0] la_g_out ;   
wire   [7:0] la_b_out ; 
wire  la_rstn_out;   
wire  la_iic_tx_scl; 
wire  la_iic_tx_sda; 
wire  la_led_int;   

//           定义线网
//*********************************

//小麻雀内核
core inst_core
(
    .clk              (clk),
    .rst_n            (rst_n),
    .halt_req_i       (halt_req),
    .hx_valid         (hx_valid),
    .soft_rst         (soft_rst_en),

//外部中断
    .core_ex_trap_valid_i   (core_ex_trap_valid),
    .core_ex_trap_id_i      (core_ex_trap_id),
    .core_ex_trap_ready_o   (core_ex_trap_ready),
    .core_ex_trap_cplet_o   (),
    .core_ex_trap_cplet_id_o(),

//m1 内核
    .core_icb_cmd_valid (core_icb_cmd_valid),
    .core_icb_cmd_ready (core_icb_cmd_ready),
    .core_icb_cmd_addr  (core_icb_cmd_addr ),
    .core_icb_cmd_read  (core_icb_cmd_read ),
    .core_icb_cmd_wdata (core_icb_cmd_wdata),
    .core_icb_cmd_wmask (core_icb_cmd_wmask),
    .core_icb_rsp_valid (core_icb_rsp_valid),
    .core_icb_rsp_ready (core_icb_rsp_ready),
    .core_icb_rsp_err   (core_icb_rsp_err  ),
    .core_icb_rsp_rdata (core_icb_rsp_rdata),
//s0 iram指令存储器
    .iram_icb_cmd_valid (iram_icb_cmd_valid),
    .iram_icb_cmd_ready (iram_icb_cmd_ready),
    .iram_icb_cmd_addr  (iram_icb_cmd_addr ),
    .iram_icb_cmd_read  (iram_icb_cmd_read ),
    .iram_icb_cmd_wdata (iram_icb_cmd_wdata),
    .iram_icb_cmd_wmask (iram_icb_cmd_wmask),
    .iram_icb_rsp_valid (iram_icb_rsp_valid),
    .iram_icb_rsp_ready (iram_icb_rsp_ready),
    .iram_icb_rsp_err   (iram_icb_rsp_err  ),
    .iram_icb_rsp_rdata (iram_icb_rsp_rdata)
);

`ifdef JTAG_DBG_MODULE
//JTAG模块
jtag_top inst_jtag_top
(
    .clk              (clk),
    .jtag_rst_n       (rst_n),
    .jtag_pin_TCK     (JTAG_TCK),
    .jtag_pin_TMS     (JTAG_TMS),
    .jtag_pin_TDI     (JTAG_TDI),
    .jtag_pin_TDO     (JTAG_TDO),
    .reg_we_o         (),
    .reg_addr_o       (),
    .reg_wdata_o      (),
    .reg_rdata_i      (32'b0),
    //m0 jtag
    .jtag_icb_cmd_valid (jtag_icb_cmd_valid),
    .jtag_icb_cmd_ready (jtag_icb_cmd_ready),
    .jtag_icb_cmd_addr  (jtag_icb_cmd_addr ),
    .jtag_icb_cmd_read  (jtag_icb_cmd_read ),
    .jtag_icb_cmd_wdata (jtag_icb_cmd_wdata),
    .jtag_icb_cmd_wmask (jtag_icb_cmd_wmask),
    .jtag_icb_rsp_valid (jtag_icb_rsp_valid),
    .jtag_icb_rsp_ready (jtag_icb_rsp_ready),
    .jtag_icb_rsp_err   (jtag_icb_rsp_err  ),
    .jtag_icb_rsp_rdata (jtag_icb_rsp_rdata),
    .halt_req_o       (halt_req),
    .reset_req_o      (jtag_rst_en)
);
`else
    assign halt_req = 1'b0;
    assign jtag_rst_en = 1'b0;
    assign jtag_icb_cmd_valid = 1'b0;
    assign jtag_icb_cmd_addr  = 32'b0;
    assign jtag_icb_cmd_read  = 1'b0;
    assign jtag_icb_cmd_wdata = 32'b0;
    assign jtag_icb_cmd_wmask = 4'b0;
    assign jtag_icb_rsp_ready = 1'b1;
	assign JTAG_TDO = 1'b0;
`endif

//s1 sram外设
sram inst_sram
(
    .clk              (clk),
    .rst_n            (rst_n),

    .sram_icb_cmd_valid (sram_icb_cmd_valid),
    .sram_icb_cmd_ready (sram_icb_cmd_ready),
    .sram_icb_cmd_addr  (sram_icb_cmd_addr ),
    .sram_icb_cmd_read  (sram_icb_cmd_read ),
    .sram_icb_cmd_wdata (sram_icb_cmd_wdata),
    .sram_icb_cmd_wmask (sram_icb_cmd_wmask),
    .sram_icb_rsp_valid (sram_icb_rsp_valid),
    .sram_icb_rsp_ready (sram_icb_rsp_ready),
    .sram_icb_rsp_err   (sram_icb_rsp_err  ),
    .sram_icb_rsp_rdata (sram_icb_rsp_rdata)
);

//s2 sys_perip系统外设
sys_perip inst_sys_perip
(
    .clk               (clk),
    .rst_n             (rst_n),

    .fpioa             (fpioa),

    .irq_fpioa_eli  (irq_fpioa_eli),    //FPIOA端口外部连线中断
    .irq_spi0_end   (irq_spi0_end),           //SPI收发结束中断
    .irq_timer0_of  (irq_timer0_of),      //定时器溢出中断
    .irq_uart0_tx   (irq_uart0_tx),  //uart tx发送完成中断
    .irq_uart0_rx   (irq_uart0_rx),   //uart rx接收数据中断
    .irq_uart1_tx   (irq_uart1_tx),  //uart tx发送完成中断
    .irq_uart1_rx   (irq_uart1_rx),   //uart rx接收数据中断

    .sysp_icb_cmd_valid (sysp_icb_cmd_valid),
    .sysp_icb_cmd_ready (sysp_icb_cmd_ready),
    .sysp_icb_cmd_addr  (sysp_icb_cmd_addr ),
    .sysp_icb_cmd_read  (sysp_icb_cmd_read ),
    .sysp_icb_cmd_wdata (sysp_icb_cmd_wdata),
    .sysp_icb_cmd_wmask (sysp_icb_cmd_wmask),
    .sysp_icb_rsp_valid (sysp_icb_rsp_valid),
    .sysp_icb_rsp_ready (sysp_icb_rsp_ready),
    .sysp_icb_rsp_err   (sysp_icb_rsp_err  ),
    .sysp_icb_rsp_rdata (sysp_icb_rsp_rdata)
);

//s3 PLIC
assign plic_irq_port[0] = 1'b0;//中断源ID0 保留，不可以使用
assign plic_irq_port[1] = irq_fpioa_eli[0];
assign plic_irq_port[2] = irq_fpioa_eli[1];
assign plic_irq_port[3] = irq_fpioa_eli[2];
assign plic_irq_port[4] = irq_fpioa_eli[3];
assign plic_irq_port[5] = irq_uart0_tx;
assign plic_irq_port[6] = irq_uart0_rx;
assign plic_irq_port[7] = irq_uart1_tx;
assign plic_irq_port[8] = irq_uart1_rx;
assign plic_irq_port[9] = irq_timer0_of;
assign plic_irq_port[10] = irq_spi0_end;
assign plic_irq_port[11] = 1'b0;
assign plic_irq_port[12] = 1'b0;
assign plic_irq_port[13] = 1'b0;
assign plic_irq_port[14] = 1'b0;
assign plic_irq_port[15] = 1'b0;
plic inst_plic
(
    .clk                  (clk),
    .rst_n                (rst_n),

    .plic_icb_cmd_valid   (plic_icb_cmd_valid),
    .plic_icb_cmd_ready   (plic_icb_cmd_ready),
    .plic_icb_cmd_addr    (plic_icb_cmd_addr ),
    .plic_icb_cmd_read    (plic_icb_cmd_read ),
    .plic_icb_cmd_wdata   (plic_icb_cmd_wdata),
    .plic_icb_cmd_wmask   (plic_icb_cmd_wmask),
    .plic_icb_rsp_valid   (plic_icb_rsp_valid),
    .plic_icb_rsp_ready   (plic_icb_rsp_ready),
    .plic_icb_rsp_err     (plic_icb_rsp_err  ),
    .plic_icb_rsp_rdata   (plic_icb_rsp_rdata),

    .plic_irq_port        (plic_irq_port),

    .core_ex_trap_valid_o (core_ex_trap_valid),
    .core_ex_trap_id_o    (core_ex_trap_id),
    .core_ex_trap_ready_i (core_ex_trap_ready)
);

// //s4
// sdrd inst_sdrd
// (
//     .clk                (clk),
//     .rst_n              (rst_n),

//     .sdrd_icb_cmd_valid (sdrd_icb_cmd_valid),
//     .sdrd_icb_cmd_ready (sdrd_icb_cmd_ready),
//     .sdrd_icb_cmd_addr  (sdrd_icb_cmd_addr),
//     .sdrd_icb_cmd_read  (sdrd_icb_cmd_read),
//     .sdrd_icb_cmd_wdata (sdrd_icb_cmd_wdata),
//     .sdrd_icb_cmd_wmask (sdrd_icb_cmd_wmask),
//     .sdrd_icb_rsp_valid (sdrd_icb_rsp_valid),
//     .sdrd_icb_rsp_ready (sdrd_icb_rsp_ready),
//     .sdrd_icb_rsp_err   (sdrd_icb_rsp_err),
//     .sdrd_icb_rsp_rdata (sdrd_icb_rsp_rdata),

//     .sd_clk             (sd_clk),
//     .sd_cmd             (sd_cmd),
//     .sd_dat             (sd_dat)
// );
wire locked;
wire ad_clk;

pll u_pll (
  .clkin1  (clk),  //50MHz
  .clkout0 (dac_clk),   //120MHz
  .clkout1 (ad_clk),   //30MHz
  .pll_lock(locked)
);

//s4
icb_top_dds inst_icb_top_dds
(
  .sys_clk(clk),
  .sys_rst_n(rst_n),
  .dac_clk(dac_clk),
  
  .dds_icb_cmd_valid (dds_icb_cmd_valid),
  .dds_icb_cmd_ready (dds_icb_cmd_ready),
  .dds_icb_cmd_addr  (dds_icb_cmd_addr),
  .dds_icb_cmd_read  (dds_icb_cmd_read),
  .dds_icb_cmd_wdata (dds_icb_cmd_wdata),
  .dds_icb_cmd_wmask (dds_icb_cmd_wmask),
  .dds_icb_rsp_valid (dds_icb_rsp_valid),
  .dds_icb_rsp_ready (dds_icb_rsp_ready),
  .dds_icb_rsp_err   (dds_icb_rsp_err),
  .dds_icb_rsp_rdata (dds_icb_rsp_rdata),
  
  .dac_data(dac_data) 
);

wire   i_vs_hdmi ;
wire   i_hs_hdmi ;
wire   i_de_hdmi ;
wire   [7:0] i_r_hdmi ;
wire   [7:0] i_g_hdmi ;
wire   [7:0] i_b_hdmi ;

//ETH DAC send
reg            tx_start_en   ;
wire    [31:0] tx_data       ;
wire    [15:0] tx_byte_num   ;
wire           tx_done       ;
wire           tx_req        ;
wire  [9:0]    fifo_rdusedw  ; //fifo存储的数据量
reg            send_busy     ;
wire           gmii_tx_clk   ;
//ETH ADC recv
wire          rec_pkt_done ; //UDP单包数据接收完成信号
wire          rec_en       ; //UDP接收的数据使能信号
wire  [31:0]  rec_data     ; //UDP接收的数据
wire  [15:0]  rec_byte_num ; //UDP接收的有效字节数 单位:byte
wire          gmii_rx_clk  ;
wire [7:0]    ad_data_1    ;

 eth_udp_full u_eth_udp_full(
  .sys_clk      (clk), //系统时钟
  .sys_rst_n    (rst_n), //系统复位信号，低电平有效
  .eth_rxc      (eth_rxc), //RGMII接收数据时钟
  .eth_rx_ctl   (eth_rx_ctl), //RGMII输入数据有效信号
  .eth_rxd      (eth_rxd), //RGMII输入数据
  .eth_txc      (eth_txc), //RGMII发送数据时钟
  .eth_tx_ctl   (eth_tx_ctl), //RGMII输出数据有效信号
  .eth_txd      (eth_txd), //RGMII输出数据
  .eth_rst_n    (eth_rst_n), //以太网芯片复位信号，低电平有效
  .rec_pkt_done  (rec_pkt_done), //以太网单包数据接收完成信号
  .rec_en        (rec_en      ), //以太网接收的数据使能信号
  .rec_data      (rec_data    ), //以太网接收的数据
  .rec_byte_num  (rec_byte_num), //以太网接收的有效字节数 单位:byte
  .tx_start_en  (tx_start_en), //以太网开始发送信号
  .tx_data      (tx_data), //以太网待发送数据
  .tx_byte_num  (tx_byte_num), //以太网发送的有效字节数 单位:byte
  .tx_done      (tx_done), //以太网发送完成信号
  .tx_req       (tx_req),  //读数据请求信号
  .gmii_tx_clk  (gmii_tx_clk),
  .gmii_rx_clk   (gmii_rx_clk )
);

async_fifo_send u_async_fifo_send (
  .wr_clk(dac_clk),                    // input
  .wr_rst(~rst_n),                    // input
  .wr_en(1'b1),                       // input
  .wr_data(dac_data),                 // input [7:0]
  .wr_full(),                         // output
  .wr_water_level(),                  // output [11:0]
  .almost_full(),                     // output
  .rd_clk(gmii_tx_clk),               // input
  .rd_rst(~rst_n),                    // input
  .rd_en(tx_req),                     // input
  .rd_data(tx_data),                  // output [31:0]
  .rd_empty(),                        // output
  .rd_water_level(fifo_rdusedw),      // output [9:0]
  .almost_empty()                     // output
);
assign tx_byte_num = 16'd1024;

always @(posedge gmii_tx_clk or negedge rst_n) begin
	if(!rst_n) begin
		tx_start_en <= 1'b0;
	end else if(!send_busy && fifo_rdusedw >= tx_byte_num[15:2]) begin
		tx_start_en <= 1'b1;
	end else begin
		tx_start_en <= 1'b0;
	end
end

always @(posedge gmii_tx_clk or negedge rst_n) begin
	if(!rst_n) begin
		send_busy <= 1'b0;
	end else if(tx_start_en) begin
		send_busy <= 1'b1;
	end else if(tx_done) begin
		send_busy <= 1'b0;
	end
end

async_fifo_recv u_async_fifo_recv (
	.wr_clk         (gmii_rx_clk),         // input
	.wr_rst         (~rst_n),          // input
	.wr_en          (rec_en),              // input
	.wr_data        (rec_data),            // input [31:0]
	.wr_full        (),                    // output
    .wr_water_level (),                    // output [9:0]
	.almost_full    (),                    // output
	.rd_clk         (ad_clk),              // input
	.rd_rst         (~rst_n),          // input
	.rd_en          (1'b1),                // input
	.rd_data        (ad_data_1),             // output [7:0]
	.rd_empty       (),                    // output
	.rd_water_level (),                    // output [11:0]
	.almost_empty   ()                     // output
	);

reg dso_chnl_sel;

//s6
icb_top_dso inst_icb_top_dso(
    .clk                               (clk                       ),
    .rst_n                             (rst_n                     ),
    .dso_icb_cmd_valid                 (dso_icb_cmd_valid         ),
    .dso_icb_cmd_ready                 (dso_icb_cmd_ready         ),
    .dso_icb_cmd_addr                  (dso_icb_cmd_addr          ),
    .dso_icb_cmd_read                  (dso_icb_cmd_read          ),
    .dso_icb_cmd_wdata                 (dso_icb_cmd_wdata         ),
    .dso_icb_cmd_wmask                 (dso_icb_cmd_wmask         ),
    .dso_icb_rsp_valid                 (dso_icb_rsp_valid         ),
    .dso_icb_rsp_ready                 (dso_icb_rsp_ready         ),
    .dso_icb_rsp_err                   (dso_icb_rsp_err           ),
    .dso_icb_rsp_rdata                 (dso_icb_rsp_rdata         ),
// 
  .i_vs_hdmi                         (i_vs_hdmi                    ),
  .i_hs_hdmi                         (i_hs_hdmi                    ),
  .i_de_hdmi                         (i_de_hdmi                    ),
  .i_r_hdmi                          (i_r_hdmi                     ),
  .i_g_hdmi                          (i_g_hdmi                     ),
  .i_b_hdmi                          (i_b_hdmi                     ),


  // hdmi out
    .pix_clk                           (pix_clk                   ),
    .vs_out                            (dso_vs_out                    ),
    .hs_out                            (dso_hs_out                    ),
    .de_out                            (dso_de_out                    ),
    .r_out                             (dso_r_out                     ),
    .g_out                             (dso_g_out                     ),
    .b_out                             (dso_b_out                     ),
  // ad dso_
    .ad_clk                            (ad_clk                    ),
    .ad_data                           (dso_chnl_sel ? ad_data_1 : ad_data),

    .rstn_out                          (dso_rstn_out                  ),
    .iic_tx_scl                        (dso_iic_tx_scl                ),
    .iic_tx_sda                        (dso_iic_tx_sda                ),
    .led_int                           (dso_led_int                   ) 

);

// s7
icb_top_la inst_icb_top_la(
    .sys_clk                           (clk                       ),
    .sys_rst_n                         (rst_n                     ),
    .la_icb_cmd_valid                  (la_icb_cmd_valid          ),
    .la_icb_cmd_ready                  (la_icb_cmd_ready          ),
    .la_icb_cmd_addr                   (la_icb_cmd_addr           ),
    .la_icb_cmd_read                   (la_icb_cmd_read           ),
    .la_icb_cmd_wdata                  (la_icb_cmd_wdata          ),
    .la_icb_cmd_wmask                  (la_icb_cmd_wmask          ),
    .la_icb_rsp_valid                  (la_icb_rsp_valid          ),
    .la_icb_rsp_ready                  (la_icb_rsp_ready          ),
    .la_icb_rsp_err                    (la_icb_rsp_err            ),
    .la_icb_rsp_rdata                  (la_icb_rsp_rdata          ),
    .spi_data                          (fpioa[3:1]                ), 
    .i_vs_hdmi                         (i_vs_hdmi                    ),
    .i_hs_hdmi                         (i_hs_hdmi                    ),
    .i_de_hdmi                         (i_de_hdmi                    ),
    .i_r_hdmi                          (i_r_hdmi                     ),
    .i_g_hdmi                          (i_g_hdmi                     ),
    .i_b_hdmi                          (i_b_hdmi                     ),
    .key0(1'b0),
    .key1(1'b0),
    .pix_clk                           (pix_clk                   ),
    .vs_out                            (la_vs_out                    ),
    .hs_out                            (la_hs_out                    ),
    .de_out                            (la_de_out                    ),
    .r_out                             (la_r_out                     ),
    .g_out                             (la_g_out                     ),
    .b_out                             (la_b_out                     ),

    .rstn_out                          (la_rstn_out                  ),
    .iic_tx_scl                        (la_iic_tx_scl                ),
    .iic_tx_sda                        (la_iic_tx_sda                )

);

wire key0_flag;
wire key1_flag;
key_filter 
#(
    .CNT_MAX      (20'd999_999 )       //计数器计数最大值
)
u0_key_filter
(
    .sys_clk      (clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (rst_n)   ,   //全局复位
    .key_in       (key[0]  )   ,   //按键输入信号

    .key_flag     (key0_flag)       //按键消抖后标志信号
);


always@(posedge clk)
begin
   if(rst_n == 1'b0)
       dso_chnl_sel <= 1'b0;
   else if(key0_flag == 1'b1)
       dso_chnl_sel <= ~dso_chnl_sel;
end

key_filter 
#(
    .CNT_MAX      (20'd999_999 )       //计数器计数最大值
)
u1_key_filter
(
    .sys_clk      (clk  )   ,   //系统时钟50Mhz
    .sys_rst_n    (rst_n)   ,   //全局复位
    .key_in       (key[1]  )   ,   //按键输入信号

    .key_flag     (key1_flag     )       //按键消抖后标志信号
);



hdmi_top u_hdmi_top (
   .sys_clk    (  clk     ), // input
   .rstn_out   (  rstn_out    ), // output
   .iic_tx_scl (  iic_tx_scl  ), // output
   .iic_tx_sda (  iic_tx_sda  ), // inout
   .led_int    (  led_int     ), // output

   .pix_clk    (  pix_clk     ), // output
   .vs_out     (  i_vs_hdmi    ), // output
   .hs_out     (  i_hs_hdmi    ), // output
   .de_out     (  i_de_hdmi    ), // output
   .r_out      (  i_r_hdmi     ), // output
   .g_out      (  i_g_hdmi     ), // output
   .b_out      (  i_b_hdmi     )  // output
);



reg dso_enable;

always@(posedge clk)
begin
   if(rst_n == 1'b0)
       dso_enable <= 1'b1;
   else if(key1_flag == 1'b1)
       dso_enable <= ~dso_enable;
end
// wire dso_enable =1'b0;
// hdmi输出二选一
// 默认开启为dso  0为dso 1为la  
assign vs_out   =  dso_enable ? dso_vs_out  : la_vs_out;
assign hs_out   =  dso_enable ? dso_hs_out  : la_hs_out;
assign de_out   =  dso_enable ? dso_de_out  : la_de_out;
assign r_out    =  dso_enable ? dso_r_out   : la_r_out;
assign g_out    =  dso_enable ? dso_g_out   : la_g_out;
assign b_out    =  dso_enable ? dso_b_out   : la_b_out;

//2主8从ICB总线桥
icb_2m8s inst_icb_2m8s
(
    .clk              (clk),
    
    .m0_icb_cmd_valid (jtag_icb_cmd_valid),
    .m0_icb_cmd_ready (jtag_icb_cmd_ready),
    .m0_icb_cmd_addr  (jtag_icb_cmd_addr ),
    .m0_icb_cmd_read  (jtag_icb_cmd_read ),
    .m0_icb_cmd_wdata (jtag_icb_cmd_wdata),
    .m0_icb_cmd_wmask (jtag_icb_cmd_wmask),
    .m0_icb_rsp_valid (jtag_icb_rsp_valid),
    .m0_icb_rsp_ready (jtag_icb_rsp_ready),
    .m0_icb_rsp_err   (jtag_icb_rsp_err  ),
    .m0_icb_rsp_rdata (jtag_icb_rsp_rdata),

    .m1_icb_cmd_valid (core_icb_cmd_valid),
    .m1_icb_cmd_ready (core_icb_cmd_ready),
    .m1_icb_cmd_addr  (core_icb_cmd_addr ),
    .m1_icb_cmd_read  (core_icb_cmd_read ),
    .m1_icb_cmd_wdata (core_icb_cmd_wdata),
    .m1_icb_cmd_wmask (core_icb_cmd_wmask),
    .m1_icb_rsp_valid (core_icb_rsp_valid),
    .m1_icb_rsp_ready (core_icb_rsp_ready),
    .m1_icb_rsp_err   (core_icb_rsp_err  ),
    .m1_icb_rsp_rdata (core_icb_rsp_rdata),

    .s0_icb_cmd_valid (iram_icb_cmd_valid),
    .s0_icb_cmd_ready (iram_icb_cmd_ready),
    .s0_icb_cmd_addr  (iram_icb_cmd_addr ),
    .s0_icb_cmd_read  (iram_icb_cmd_read ),
    .s0_icb_cmd_wdata (iram_icb_cmd_wdata),
    .s0_icb_cmd_wmask (iram_icb_cmd_wmask),
    .s0_icb_rsp_valid (iram_icb_rsp_valid),
    .s0_icb_rsp_ready (iram_icb_rsp_ready),
    .s0_icb_rsp_err   (iram_icb_rsp_err  ),
    .s0_icb_rsp_rdata (iram_icb_rsp_rdata),

    .s1_icb_cmd_valid (sram_icb_cmd_valid),
    .s1_icb_cmd_ready (sram_icb_cmd_ready),
    .s1_icb_cmd_addr  (sram_icb_cmd_addr ),
    .s1_icb_cmd_read  (sram_icb_cmd_read ),
    .s1_icb_cmd_wdata (sram_icb_cmd_wdata),
    .s1_icb_cmd_wmask (sram_icb_cmd_wmask),
    .s1_icb_rsp_valid (sram_icb_rsp_valid),
    .s1_icb_rsp_ready (sram_icb_rsp_ready),
    .s1_icb_rsp_err   (sram_icb_rsp_err  ),
    .s1_icb_rsp_rdata (sram_icb_rsp_rdata),

    .s2_icb_cmd_valid (sysp_icb_cmd_valid),
    .s2_icb_cmd_ready (sysp_icb_cmd_ready),
    .s2_icb_cmd_addr  (sysp_icb_cmd_addr ),
    .s2_icb_cmd_read  (sysp_icb_cmd_read ),
    .s2_icb_cmd_wdata (sysp_icb_cmd_wdata),
    .s2_icb_cmd_wmask (sysp_icb_cmd_wmask),
    .s2_icb_rsp_valid (sysp_icb_rsp_valid),
    .s2_icb_rsp_ready (sysp_icb_rsp_ready),
    .s2_icb_rsp_err   (sysp_icb_rsp_err  ),
    .s2_icb_rsp_rdata (sysp_icb_rsp_rdata),

    .s3_icb_cmd_valid (plic_icb_cmd_valid),
    .s3_icb_cmd_ready (plic_icb_cmd_ready),
    .s3_icb_cmd_addr  (plic_icb_cmd_addr ),
    .s3_icb_cmd_read  (plic_icb_cmd_read ),
    .s3_icb_cmd_wdata (plic_icb_cmd_wdata),
    .s3_icb_cmd_wmask (plic_icb_cmd_wmask),
    .s3_icb_rsp_valid (plic_icb_rsp_valid),
    .s3_icb_rsp_ready (plic_icb_rsp_ready),
    .s3_icb_rsp_err   (plic_icb_rsp_err  ),
    .s3_icb_rsp_rdata (plic_icb_rsp_rdata),

    .s4_icb_cmd_valid (dds_icb_cmd_valid),
    .s4_icb_cmd_ready (dds_icb_cmd_ready),
    .s4_icb_cmd_addr  (dds_icb_cmd_addr ),
    .s4_icb_cmd_read  (dds_icb_cmd_read ),
    .s4_icb_cmd_wdata (dds_icb_cmd_wdata),
    .s4_icb_cmd_wmask (dds_icb_cmd_wmask),
    .s4_icb_rsp_valid (dds_icb_rsp_valid),
    .s4_icb_rsp_ready (dds_icb_rsp_ready),
    .s4_icb_rsp_err   (dds_icb_rsp_err  ),
    .s4_icb_rsp_rdata (dds_icb_rsp_rdata),

    .s5_icb_cmd_valid (eth_icb_cmd_valid ),
    .s5_icb_cmd_ready (eth_icb_cmd_ready ),
    .s5_icb_cmd_addr  (eth_icb_cmd_addr  ),
    .s5_icb_cmd_read  (eth_icb_cmd_read  ),
    .s5_icb_cmd_wdata (eth_icb_cmd_wdata ),
    .s5_icb_cmd_wmask (eth_icb_cmd_wmask ),
    .s5_icb_rsp_valid (eth_icb_rsp_valid ),
    .s5_icb_rsp_ready (eth_icb_rsp_ready ),
    .s5_icb_rsp_err   (eth_icb_rsp_err   ),
    .s5_icb_rsp_rdata (eth_icb_rsp_rdata ),
    // .s5_icb_cmd_valid (s5_icb_cmd_valid ),
    // .s5_icb_cmd_ready (s5_icb_cmd_ready ),
    // .s5_icb_cmd_addr  (s5_icb_cmd_addr  ),
    // .s5_icb_cmd_read  (s5_icb_cmd_read  ),
    // .s5_icb_cmd_wdata (s5_icb_cmd_wdata ),
    // .s5_icb_cmd_wmask (s5_icb_cmd_wmask ),
    // .s5_icb_rsp_valid (s5_icb_rsp_valid ),
    // .s5_icb_rsp_ready (s5_icb_rsp_ready ),
    // .s5_icb_rsp_err   (s5_icb_rsp_err   ),
    // .s5_icb_rsp_rdata (s5_icb_rsp_rdata ),

    .s6_icb_cmd_valid (dso_icb_cmd_valid),
    .s6_icb_cmd_ready (dso_icb_cmd_ready),
    .s6_icb_cmd_addr  (dso_icb_cmd_addr ),
    .s6_icb_cmd_read  (dso_icb_cmd_read ),
    .s6_icb_cmd_wdata (dso_icb_cmd_wdata),
    .s6_icb_cmd_wmask (dso_icb_cmd_wmask),
    .s6_icb_rsp_valid (dso_icb_rsp_valid),
    .s6_icb_rsp_ready (dso_icb_rsp_ready),
    .s6_icb_rsp_err   (dso_icb_rsp_err  ),
    .s6_icb_rsp_rdata (dso_icb_rsp_rdata),

    .s7_icb_cmd_valid (la_icb_cmd_valid),
    .s7_icb_cmd_ready (la_icb_cmd_ready),
    .s7_icb_cmd_addr  (la_icb_cmd_addr ),
    .s7_icb_cmd_read  (la_icb_cmd_read ),
    .s7_icb_cmd_wdata (la_icb_cmd_wdata),
    .s7_icb_cmd_wmask (la_icb_cmd_wmask),
    .s7_icb_rsp_valid (la_icb_rsp_valid),
    .s7_icb_rsp_ready (la_icb_rsp_ready),
    .s7_icb_rsp_err   (la_icb_rsp_err  ),
    .s7_icb_rsp_rdata (la_icb_rsp_rdata)
);

//复位控制器
rstc inst_rstc
(
    .clk         (clk),
    .hard_rst_n  (hard_rst_n),
    .soft_rst_en (soft_rst_en),
    .jtag_rst_en (jtag_rst_en),
    .rst_n       (rst_n)
);
assign core_rst_n = rst_n;
//处理器活动指示，只要指令流不停，灯就在闪
reg [clogb2(`CPU_CLOCK_HZ/4)-1:0]hx_cnt;//计数器
reg active_reg;//状态翻转
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        hx_cnt <= 0;
        active_reg <= 1'b1;
    end 
    else begin
        if (hx_valid == 1'b1) begin
            if(hx_cnt < `CPU_CLOCK_HZ/4) begin
                hx_cnt <= hx_cnt + 1'b1;
            end
            else begin
                hx_cnt <= 0;
                active_reg <= ~active_reg;
            end
        end
    end
end
assign core_active = active_reg;//硬连线

//计算log2，得到地址位宽，如clogb2(RAM_DEPTH-1)
function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction

endmodule