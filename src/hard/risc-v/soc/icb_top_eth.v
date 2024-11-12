// +FHEADER =====================================================================
// FilePath       : \pangoPRJ\RISC-V\rtl\SparrowRV\rtl\soc\icb_top_eth.v
// Author         : zkwang2001 1922601163@qq.com
// CreateDate     : 24-11-10
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
module icb_top_eth(
    input wire sys_clk, 
    input wire sys_rst_n, 


    input  wire                         eth_icb_cmd_valid          ,//cmd有效
    output wire                         eth_icb_cmd_ready          ,//cmd准备好
    input  wire        [  31:0]         eth_icb_cmd_addr           ,//cmd地址
    input  wire                         eth_icb_cmd_read           ,//cmd读使能
    input  wire        [  31:0]         eth_icb_cmd_wdata          ,//cmd写数据
    input  wire        [   3:0]         eth_icb_cmd_wmask          ,//cmd写选通  未使用
    output reg                          eth_icb_rsp_valid          ,//rsp有效
    input  wire                         eth_icb_rsp_ready          ,//rsp准备好
    output wire                         eth_icb_rsp_err            ,//rsp错误
    output wire        [  31:0]         eth_icb_rsp_rdata          ,//rsp读数据

   input              eth_rxc     , //RGMII接收数据时钟
   input              eth_rx_ctl  , //RGMII输入数据有效信号
   input       [3:0]  eth_rxd     , //RGMII输入数据
   output             eth_txc     , //RGMII发送数据时钟
   output             eth_tx_ctl  , //RGMII输出数据有效信号
   output      [3:0]  eth_txd     , //RGMII输出数据
   output             eth_rst_n    //以太网芯片复位信号，低电平有效

);
  
  //name | addr | func
  //-------dds----------- 
  //reg0 | 0x00 | wave_select
  //reg1 | 0x04 | amp_ctl
  //reg2 | 0x08 | freq_ctl
  //reg3 | 0x0c | min_ctl
  //reg4 | 0x10 | phase_ctl
  //reg5 | 0x14 | dds_ctrl_en
  //-------dso-----------
  //
  reg [31:0] reg0, reg1, reg2, reg3, reg4, reg5;
  wire dds_ctrl_en;
  wire icb_whsk = eth_icb_cmd_valid & ~eth_icb_cmd_read;//写握手
  wire icb_rhsk = eth_icb_cmd_valid & eth_icb_cmd_read;//读握手
  assign eth_icb_cmd_ready = 1'b1;
  assign eth_icb_rsp_err   = 1'b0;


  // 写响应
    always@(posedge sys_clk ) begin
      if(sys_rst_n == 1'b0)
      begin
          reg0 <= 32'd0;
          reg1 <= 32'd0;
          reg2 <= 32'd0;
          reg3 <= 32'd0;
          reg4 <= 32'd0;
          reg5 <= 32'd0;
      end
      else if (icb_whsk == 1'b1)
      begin
          case(eth_icb_cmd_addr[7:0])
              32'h00: reg0 <= eth_icb_cmd_wdata;
              32'h04: reg1 <= eth_icb_cmd_wdata;
              32'h08: reg2 <= eth_icb_cmd_wdata;
              32'h0c: reg3 <= eth_icb_cmd_wdata;
              32'h10: reg4 <= eth_icb_cmd_wdata;
              32'h14: reg5 <= eth_icb_cmd_wdata;
              default:;
          endcase
      end
      else begin
          reg0 <= reg0;
          reg1 <= reg1;
          reg2 <= reg2;
          reg3 <= reg3;
          reg4 <= reg4;
          reg5 <= 1'b0;
      end
    end


  //读响应控制
  always @(posedge sys_clk)
  if (~sys_rst_n)
      eth_icb_rsp_valid <= 1'b0;
  else begin
      if (icb_rhsk)
          eth_icb_rsp_valid <=1'b1;
      else if (eth_icb_rsp_valid & eth_icb_rsp_ready)
          eth_icb_rsp_valid <=1'b0;
      else
          eth_icb_rsp_valid <= eth_icb_rsp_valid;
  end


  reg [31:0] rdata;
  always@(posedge sys_clk) begin
    if(icb_rhsk) begin
      case(eth_icb_cmd_addr[7:0])
        32'h00: rdata <= reg0;
        32'h04: rdata <= reg1;
        32'h08: rdata <= reg2;
        32'h0c: rdata <= reg3;
        32'h10: rdata <= reg4;
        32'h14: rdata <= reg5;
        default:  rdata <= 32'd0;
      endcase
    end
  end
  assign eth_icb_rsp_rdata = rdata;

wire [ 3:0] wave_select;
wire [ 8:0] amp_ctl    ;
wire [31:0] freq_ctl   ;
wire [31:0] min_ctl    ;
wire [11:0] phase_ctl  ;

assign  wave_select = reg0[ 3:0];
assign  amp_ctl     = reg1[ 8:0];
assign  freq_ctl    = reg2[31:0];
assign  min_ctl     = reg3[31:0];
assign  phase_ctl   = reg4[11:0];
assign  dds_ctrl_en = reg5[0];
  wire eth_txc    ;
  wire eth_tx_ctl ;
  wire [3:0] eth_txd    ;
  wire eth_rst_n  ;

  wire           tx_start_en ;
  wire    [31:0] tx_data     ;
  wire    [15:0] tx_byte_num ;
  wire           tx_done     ;
  wire           tx_req      ;

 eth_udp_send u_eth_udp_send(
    .sys_clk      (sys_clk), //系统时钟
    .sys_rst_n    (sys_rst_n), //系统复位信号，低电平有效
    .eth_rxc      (eth_rxc), //RGMII接收数据时钟
    .eth_rx_ctl   (eth_rx_ctl), //RGMII输入数据有效信号
    .eth_rxd      (eth_rxd), //RGMII输入数据
    .eth_txc      (eth_txc), //RGMII发送数据时钟
    .eth_tx_ctl   (eth_tx_ctl), //RGMII输出数据有效信号
    .eth_txd      (eth_txd), //RGMII输出数据
    .eth_rst_n    (eth_rst_n), //以太网芯片复位信号，低电平有效
    .tx_start_en  (tx_start_en), //以太网开始发送信号
    .tx_data      (tx_data), //以太网待发送数据
    .tx_byte_num  (tx_byte_num), //以太网发送的有效字节数 单位:byte
    .tx_done      (tx_done), //以太网发送完成信号
    .tx_req       (tx_req),  //读数据请求信号
	  .gmii_tx_clk  (gmii_tx_clk)
    );

   eth_send_dds u_eth_send_dds(
	  .eth_tx_clk  (gmii_tx_clk),
	  .rst_n       (sys_rst_n),
    .tx_start_en (tx_start_en), //以太网开始发送信号
    .tx_data     (tx_data), //以太网待发送数据
    .tx_byte_num (tx_byte_num), //以太网发送的有效字节数 单位:byte
    .tx_done     (tx_done), //以太网发送完成信号
    .tx_req      (tx_req),  //读数据请求信号

	  .dds_ctrl_en (dds_ctrl_en),
	  .wave_select (wave_select),   //输出波形选择
    .amp_ctl     (amp_ctl),   //幅值
    .freq_ctl    (freq_ctl),   //频率
    .min_ctl     (min_ctl),   //最小分辨率
    .phase_ctl   (phase_ctl)    //相位

   );




endmodule
