`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// 实验平台: 野火FPGA系列开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module udp(
    input                rst_n       , //复位信号，低电平有效
    //GMII接口
    input                gmii_rx_clk , //GMII接收数据时钟
    input                gmii_rx_dv  , //GMII输入数据有效信号
    input        [7:0]   gmii_rxd    , //GMII输入数据
    input                gmii_tx_clk , //GMII发送数据时钟
    output               gmii_tx_en  , //GMII输出数据有效信号
    output       [7:0]   gmii_txd    , //GMII输出数据
    //用户接口
    output               rec_pkt_done, //以太网单包数据接收完成信号
    output               rec_en      , //以太网接收的数据使能信号
    output       [31:0]  rec_data    , //以太网接收的数据
    output       [15:0]  rec_byte_num, //以太网接收的有效字节数 单位:byte
    input                tx_start_en , //以太网开始发送信号
    input        [31:0]  tx_data     , //以太网待发送数据
    input        [15:0]  tx_byte_num , //以太网发送的有效字节数 单位:byte
    output               tx_done     , //以太网发送完成信号
    output               tx_req        //读数据请求信号
    );

//parameter define
//开发板MAC地址
parameter BOARD_MAC = 48'h12_34_56_78_9a_bc;   //最终具体的MAC地址和IP地址由顶层传入，这里只需要定义就好
//开发板IP地址
parameter BOARD_IP  = {8'd0,8'd0,8'd0,8'd0};
//目的MAC地址
parameter  DES_MAC  = 48'h2c_f0_5d_32_f1_07;
//目的IP地址
parameter  DES_IP   = {8'd0,8'd0,8'd0,8'd0};

//wire define
wire          crc_en  ; //CRC开始校验使能
wire          crc_clr ; //CRC数据复位信号
wire  [7:0]   crc_d8  ; //输入待校验8位数据

wire  [31:0]  crc_data; //CRC校验数据
wire  [31:0]  crc_next; //CRC下次校验完成数据

//*****************************************************
//**                    main code
//*****************************************************

assign  crc_d8 = gmii_txd;

//以太网接收模块
udp_rx
   #(
    .BOARD_MAC       (BOARD_MAC),         //参数例化
    .BOARD_IP        (BOARD_IP )
    )
   u_udp_rx(
    .clk             (gmii_rx_clk ),
    .rst_n           (rst_n       ),
    .gmii_rx_dv      (gmii_rx_dv  ),
    .gmii_rxd        (gmii_rxd    ),
    .rec_pkt_done    (rec_pkt_done),
    .rec_en          (rec_en      ),
    .rec_data        (rec_data    ),
    .rec_byte_num    (rec_byte_num)
    );

//以太网发送模块
udp_tx
   #(
    .BOARD_MAC       (BOARD_MAC ),         //参数例化
    .BOARD_IP        (BOARD_IP  ),
    .DES_MAC         (DES_MAC   ),
    .DES_IP          (DES_IP    )
    )
   u_udp_tx(
    .clk             (gmii_tx_clk),
    .rst_n           (rst_n      ),
    .tx_start_en     (tx_start_en),
    .tx_data         (tx_data    ),
    .tx_byte_num     (tx_byte_num),
    .crc_data        (crc_data   ),
    .crc_next        (crc_next[31:24]),
    .tx_done         (tx_done    ),
    .tx_req          (tx_req     ),
    .gmii_tx_en      (gmii_tx_en ),
    .gmii_txd        (gmii_txd   ),
    .crc_en          (crc_en     ),
    .crc_clr         (crc_clr    )
    );

//以太网发送CRC校验模块
crc32_d8   u_crc32_d8(
    .clk             (gmii_tx_clk),
    .rst_n           (rst_n      ),
    .data            (crc_d8     ),
    .crc_en          (crc_en     ),
    .crc_clr         (crc_clr    ),
    .crc_data        (crc_data   ),
    .crc_next        (crc_next   )
    );

endmodule