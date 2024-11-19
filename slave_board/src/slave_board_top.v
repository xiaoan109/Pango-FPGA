module slave_board_top (
  input  wire       sys_clk,     //!系统时钟50MHz
  input  wire       sys_rst_n,   //!系统复位，低电平有效
  //以太网RGMII接口
  input              eth_rxc   , //!RGMII接收数据时钟
  input              eth_rx_ctl, //!RGMII输入数据有效信号
  input       [3:0]  eth_rxd   , //!RGMII输入数据
  output             eth_txc   , //!RGMII发送数据时钟
  output             eth_tx_ctl, //!RGMII输出数据有效信号
  output      [3:0]  eth_txd   , //!RGMII输出数据
  output             eth_rst_n , //!以太网芯片复位信号，低电平有效
  //adc
  output wire       ad_clk,    //!ADC采样时钟
  input  wire [7:0] ad_data,   //!ADC采样数据
  //dac
  output wire       da_clk,  //!输入DAC模块时钟
  output wire [7:0] da_data  //!输入DAC模块数据
);

  pll u_pll (
    .clkin1  (sys_clk),  //50MHz
    .clkout0 (da_clk),   //120MHz
    .clkout1 (ad_clk),   //30MHz
    .pll_lock(locked)
  );


// //开发板MAC地址
// parameter  BOARD_MAC = 48'h12_34_56_78_9a_bc;
// //开发板IP地址
// parameter  BOARD_IP  = {8'd192,8'd168,8'd0,8'd234};
// //目的MAC地址
// parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
// //目的IP地址
// parameter  DES_IP    =  {8'd192,8'd168,8'd0,8'd145};

//开发板MAC地址
parameter  BOARD_MAC = 48'hff_ff_ff_ff_ff_ff;
//开发板IP地址
parameter  BOARD_IP  = {8'd192,8'd168,8'd0,8'd145};
//目的MAC地址
parameter  DES_MAC   = 48'h12_34_56_78_9a_bc;
//目的IP地址
parameter  DES_IP    = {8'd192,8'd168,8'd0,8'd234};

//ETH DAC recv
wire          rec_pkt_done   ; //UDP单包数据接收完成信号
wire          rec_en         ; //UDP接收的数据使能信号
wire  [31:0]  rec_data       ; //UDP接收的数据
wire  [15:0]  rec_byte_num   ; //UDP接收的有效字节数 单位:byte
wire          gmii_rx_clk    ;
//ETH ADC send
reg            tx_start_en   ;
wire    [31:0] tx_data       ;
wire    [15:0] tx_byte_num   ;
wire           tx_done       ;
wire           tx_req        ;
wire  [9:0]    fifo_rdusedw  ; //fifo存储的数据量
reg            send_busy     ;
wire           gmii_tx_clk   ;

eth_udp_full #(
    .BOARD_MAC     (BOARD_MAC   ), //参数例化
    .BOARD_IP      (BOARD_IP    ),
    .DES_MAC       (DES_MAC     ),
    .DES_IP        (DES_IP      )
    ) u_eth_udp_full(
    .sys_clk       (sys_clk     ), //系统时钟
    .sys_rst_n     (sys_rst_n   ), //系统复位信号，低电平有效
    //以太网RGMII接口
    .eth_rxc       (eth_rxc     ), //RGMII接收数据时钟
    .eth_rx_ctl    (eth_rx_ctl  ), //RGMII输入数据有效信号
    .eth_rxd       (eth_rxd     ), //RGMII输入数据
    .eth_txc       (eth_txc     ), //RGMII发送数据时钟
    .eth_tx_ctl    (eth_tx_ctl  ), //RGMII输出数据有效信号
    .eth_txd       (eth_txd     ), //RGMII输出数据
    .eth_rst_n     (eth_rst_n   ), //以太网芯片复位信号，低电平有效
	//用户接口
    .rec_pkt_done  (rec_pkt_done), //以太网单包数据接收完成信号
    .rec_en        (rec_en      ), //以太网接收的数据使能信号
    .rec_data      (rec_data    ), //以太网接收的数据
    .rec_byte_num  (rec_byte_num), //以太网接收的有效字节数 单位:byte
	.tx_start_en   (tx_start_en), //以太网开始发送信号
    .tx_data       (tx_data), //以太网待发送数据
    .tx_byte_num   (tx_byte_num), //以太网发送的有效字节数 单位:byte
    .tx_done       (tx_done), //以太网发送完成信号
    .tx_req        (tx_req),  //读数据请求信号
	//GMII时钟
	.gmii_rx_clk   (gmii_rx_clk ),
    .gmii_tx_clk   (gmii_tx_clk)
    );

async_fifo_recv u_async_fifo_recv (
  .wr_clk         (gmii_rx_clk),         // input
  .wr_rst         (~sys_rst_n),          // input
  .wr_en          (rec_en),              // input
  .wr_data        (rec_data),            // input [31:0]
  .wr_full        (),                    // output
  .wr_water_level (),                    // output [9:0]
  .almost_full    (),                    // output
  .rd_clk         (da_clk),              // input
  .rd_rst         (~sys_rst_n),          // input
  .rd_en          (1'b1),                // input
  .rd_data        (da_data),             // output [7:0]
  .rd_empty       (),                    // output
  .rd_water_level (),                    // output [11:0]
  .almost_empty   ()                     // output
);
	
async_fifo_send u_async_fifo_send (
  .wr_clk        (ad_clk),               // input
  .wr_rst        (~sys_rst_n),           // input
  .wr_en         (1'b1),                 // input
  .wr_data       (ad_data),              // input [7:0]
  .wr_full       (),                     // output
  .wr_water_level(),                     // output [11:0]
  .almost_full   (),                     // output
  .rd_clk        (gmii_tx_clk),          // input
  .rd_rst        (~sys_rst_n),           // input
  .rd_en         (tx_req),               // input
  .rd_data       (tx_data),              // output [31:0]
  .rd_empty      (),                     // output
  .rd_water_level(fifo_rdusedw),         // output [9:0]
  .almost_empty  ()                      // output
);
assign tx_byte_num = 16'd1024;

always @(posedge gmii_tx_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		tx_start_en <= 1'b0;
	end else if(!send_busy && fifo_rdusedw >= tx_byte_num[15:2]) begin
		tx_start_en <= 1'b1;
	end else begin
		tx_start_en <= 1'b0;
	end
end

always @(posedge gmii_tx_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		send_busy <= 1'b0;
	end else if(tx_start_en) begin
		send_busy <= 1'b1;
	end else if(tx_done) begin
		send_busy <= 1'b0;
	end
end


endmodule
