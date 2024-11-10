module eth_udp_send(
    input              sys_clk     , //系统时钟
    input              sys_rst_n   , //系统复位信号，低电平有效
    //以太网RGMII接口
    input              eth_rxc     , //RGMII接收数据时钟
    input              eth_rx_ctl  , //RGMII输入数据有效信号
    input       [3:0]  eth_rxd     , //RGMII输入数据
    output             eth_txc     , //RGMII发送数据时钟
    output             eth_tx_ctl  , //RGMII输出数据有效信号
    output      [3:0]  eth_txd     , //RGMII输出数据
    output             eth_rst_n   , //以太网芯片复位信号，低电平有效
	//用户接口
    input              tx_start_en , //以太网开始发送信号
    input       [31:0] tx_data     , //以太网待发送数据
    input       [15:0] tx_byte_num , //以太网发送的有效字节数 单位:byte
    output             tx_done     , //以太网发送完成信号
    output             tx_req      ,  //读数据请求信号
	//GMII时钟
	output             gmii_tx_clk
    );

/* //parameter define
//开发板MAC地址
parameter  BOARD_MAC = 48'h12_34_56_78_9a_bc;
//开发板IP地址
parameter  BOARD_IP  = {8'd169,8'd254,8'd1,8'd23};
//目的MAC地址
parameter  DES_MAC   = 48'h2c_f0_5d_32_f1_07;
//目的IP地址
parameter  DES_IP    = {8'd192,8'd168,8'd103,8'd17}; */

 //开发板MAC地址
parameter  BOARD_MAC = 48'h12_34_56_78_9a_bc;
//开发板IP地址
parameter  BOARD_IP  = {8'd192,8'd168,8'd0,8'd234};
//目的MAC地址
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址     
parameter  DES_IP    = {8'd192,8'd168,8'd0,8'd145}; 

//wire define
wire          gmii_rx_clk; //GMII接收时钟
wire          gmii_rx_dv ; //GMII接收数据有效信号
wire  [7:0]   gmii_rxd   ; //GMII接收数据
wire          gmii_tx_clk; //GMII发送时钟
wire          gmii_tx_en ; //GMII发送数据使能信号
wire  [7:0]   gmii_txd   ; //GMII发送数据

wire          rec_pkt_done  ; //UDP单包数据接收完成信号
wire          rec_en        ; //UDP接收的数据使能信号
wire  [31:0]  rec_data      ; //UDP接收的数据
wire  [15:0]  rec_byte_num  ; //UDP接收的有效字节数 单位:byte
wire          udp_tx_done   ; //UDP发送完成信号
wire          tx_req        ; //UDP读数据请求信号
wire  [31:0]  tx_data       ; //UDP待发送数据
wire  [15:0]  tx_byte_num   ; //UDP发送的有效字节数 单位:byte

wire          push_btn_neg0 ; //按键下降沿
wire          push_btn_neg1 ; //按键下降沿

wire          wr_full       ; //fifo full
wire          rd_empty      ; //fifo empty
wire  [11:0]  fifo_rdusedw  ; //fifo存储的数据量

//reg define
reg           wr_en         ; //fifo写使能
reg   [31:0]  wr_data       ; //fifo写数据
// reg           tx_start_en   ; //UDP发送开启信号



//*****************************************************
//**                    main code
//*****************************************************

assign eth_rst_n = sys_rst_n;

//GMII接口与RGMII接口 互转
gmii_to_rgmii u_gmii_to_rgmii(
    .gmii_rx_clk   (gmii_rx_clk ),  //gmii接收
    .gmii_rx_dv    (gmii_rx_dv  ),
    .gmii_rxd      (gmii_rxd    ),
    .gmii_tx_clk   (gmii_tx_clk ),  //gmii发送
    .gmii_tx_en    (gmii_tx_en  ),
    .gmii_txd      (gmii_txd    ),

    .rgmii_rxc     (eth_rxc     ),  //rgmii接收
    .rgmii_rx_ctl  (eth_rx_ctl  ),
    .rgmii_rxd     (eth_rxd     ),
    .rgmii_txc     (eth_txc     ),  //rgmii发送
    .rgmii_tx_ctl  (eth_tx_ctl  ),
    .rgmii_txd     (eth_txd     )
    );

//UDP通信
udp
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_udp(
    .rst_n         (sys_rst_n   ),

    .gmii_rx_clk   (gmii_rx_clk ),//gmii接收
    .gmii_rx_dv    (gmii_rx_dv  ),
    .gmii_rxd      (gmii_rxd    ),
    .gmii_tx_clk   (gmii_tx_clk ),//gmii发送
    .gmii_tx_en    (gmii_tx_en  ),
    .gmii_txd      (gmii_txd    ),

    .rec_pkt_done  (rec_pkt_done),  //数据包接收结束
    .rec_en        (rec_en      ),  //四字节接收使能
    .rec_data      (rec_data    ),  //接收数据
    .rec_byte_num  (rec_byte_num),  //接收到的有效数据长度
    .tx_start_en   (tx_start_en ),  //发送使能
    .tx_data       (tx_data     ),  //发送数据
    .tx_byte_num   (tx_byte_num ),  //发送长度
    .tx_done       (udp_tx_done ),  //发送结束
    .tx_req        (tx_req      )   //四字节发送使能
    );

// ax_debounce u0_ax_debounce (
	// .clk           (sys_clk      ), 
	// .rst_n         (sys_rst_n    ), 
	// .button_in     (push_btn0    ),
	// .button_posedge(             ),
	// .button_negedge(push_btn_neg0),
	// .button_out    (             )
	// );

// ax_debounce u1_ax_debounce (
	// .clk           (sys_clk      ), 
	// .rst_n         (sys_rst_n    ), 
	// .button_in     (push_btn1    ),
	// .button_posedge(             ),
	// .button_negedge(push_btn_neg1),
	// .button_out    (             )
	// );

// assign tx_byte_num = 16'd16;

// always @(posedge sys_clk or negedge sys_rst_n) begin
	// if(!sys_rst_n) begin
		// wr_en <= 1'b0;
		// wr_data <= 32'b0;
	// end else if(push_btn_neg0) begin
		// wr_en <= 1'b1;
		// wr_data <= "ABCD";
	// end else if(fifo_rdusedw >= tx_byte_num[15:2]) begin
		// wr_en <= 1'b0;
		// wr_data <= 32'b0;
	// end
// end

// always @(posedge gmii_tx_clk or negedge sys_rst_n) begin
	// if(!sys_rst_n) begin
		// tx_start_en <= 1'b0;
	// end else if(push_btn_neg1 && fifo_rdusedw >= tx_byte_num[15:2]) begin
		// tx_start_en <= 1'b1;
	// end else begin
		// tx_start_en <= 1'b0;
	// end
// end
		

//异步FIFO
// async_fifo_2048x32b u_async_fifo_2048x32b (
	// .wr_clk        (sys_clk     ),   // input
	// .wr_rst        (!sys_rst_n  ),   // input
	// .wr_en         (wr_en       ),   // input
	// .wr_data       (wr_data     ),   // input [31:0]
	// .wr_full       (wr_full     ),   // output
	// .wr_water_level(            ),   // output [11:0]
	// .almost_full   (            ),   // output
	// .rd_clk        (gmii_tx_clk ),   // input
	// .rd_rst        (!sys_rst_n  ),   // input
	// .rd_en         (tx_req      ),   // input
	// .rd_data       (tx_data     ),   // output [31:0]
	// .rd_empty      (rd_empty    ),   // output
	// .rd_water_level(fifo_rdusedw),   // output [11:0]
	// .almost_empty  (            )    // output
	// );

endmodule