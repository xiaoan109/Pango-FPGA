`timescale  1ns/1ns
/////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2023/04/07
// Module Name   : top_dds
// Project Name  : top_dds
// Target Devices: PGL22G-6MBG324
// Tool Versions : Pango Design Suite 2022.2
// Description   : DDS信号发生器顶层模块
// 
// Revision      : 
// Additional Comments:
// 
// 实验平台: 野火_紫光PGL22G_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  top_dds
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   key         ,   //输入4位按键

    input  wire                 dds_icb_cmd_valid,//cmd有效
    output wire                 dds_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   dds_icb_cmd_addr ,//cmd地址
    input  wire                 dds_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       dds_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           dds_icb_cmd_wmask,//cmd写选通  未使用
    output reg                  dds_icb_rsp_valid,//rsp有效
    input  wire                 dds_icb_rsp_ready,//rsp准备好
    output wire                 dds_icb_rsp_err  ,//rsp错误
    output wire [`MemBus]       dds_icb_rsp_rdata,//rsp读数据
    input wire dac_clk, //DAC模块时钟
    // output  wire            dac_clk     ,   //输入DAC模块时钟
    output  wire    [7:0]   dac_data        //输入DAC模块波形数据
);


wire [31:0] addr;
wire [31:0] data_in;

wire icb_whsk = dds_icb_cmd_valid & ~dds_icb_cmd_read;//写握手
wire icb_rhsk = dds_icb_cmd_valid & dds_icb_cmd_read;//读握手

assign dds_icb_cmd_ready = 1'b1;  
assign dds_icb_rsp_err   = 1'b0;
assign addr = dds_icb_cmd_addr;
assign data_in = dds_icb_cmd_wdata;
// reg define
reg [31:0] reg1,reg2,reg3,reg4;
//  NAME |  ADDR |  FUNC 
//  reg1 |  0x00 |  幅值
//  reg2 |  0x04 |  频率
//  reg3 |  0x08 |  最小分辨率
//  reg4 |  0x0c |  相位

always@(posedge sys_clk ) begin
    if(sys_rst_n == 1'b0)
    begin
        reg1 <= 32'd256;
        reg2 <= 32'd42949;
        reg3 <= 32'd0;
        reg4 <= 12'd1024;
    end
    else if (icb_whsk == 1'b1)
    begin
        case(addr[7:0])
            32'h00: reg1 <= data_in;
            32'h04: reg2 <= data_in;
            32'h08: reg3 <= data_in;
            32'h0c: reg4 <= data_in;
            default:;
        endcase
    end
end

//读响应控制
always @(posedge sys_clk)
if (~sys_rst_n)
    dds_icb_rsp_valid <= 1'b0;
else begin
    if (icb_rhsk)
        dds_icb_rsp_valid <=1'b1;
    else if (dds_icb_rsp_valid & dds_icb_rsp_ready)
        dds_icb_rsp_valid <=1'b0;
    else
        dds_icb_rsp_valid <= dds_icb_rsp_valid;
end

reg [31:0] rdata;
always@(posedge sys_clk) begin
  if(icb_rhsk) begin
    case(addr[7:0])
      32'h00:rdata <= reg1;
      32'h04:rdata <= reg2;
      32'h08:rdata <= reg3;
      32'h0c:rdata <= reg4;
      default:rdata <= 32'h0;
    endcase
  end
end
assign dds_icb_rsp_rdata = rdata; 

wire [8:0] amp_ctl;
wire [31:0] freq_ctl;
wire [31:0] min_ctl;
wire [11:0] phase_ctl;


assign amp_ctl = reg1;
assign freq_ctl = reg2;
assign min_ctl = reg3;
assign phase_ctl = reg4;

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    [3:0]   wave_select ;   //波形选择

//dac_clka:DAC模块时钟
// assign  dac_clk  = ~sys_clk;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//-------------------------- dds_inst -----------------------------
dds     dds_inst
(
    .sys_clk        (dac_clk    ),   //系统时钟,50MHz
    .sys_rst_n      (sys_rst_n  ),   //复位信号,低电平有效
    .wave_select    (wave_select),   //输出波形选择
    .amp_ctl        (amp_ctl       ),   //幅值
    .freq_ctl       (freq_ctl       ),   //频率
    .min_ctl        (min_ctl       ),   //最小分辨率
    .phase_ctl      (phase_ctl       ),   //相位
    .data_out       (dac_data   )    //波形输出
);

//----------------------- key_control_inst ------------------------
key_control key_control_inst
(
    .sys_clk        (sys_clk    ),   //系统时钟,50MHz
    .sys_rst_n      (sys_rst_n  ),   //复位信号,低电平有效
    .key            (key        ),   //输入4位按键

    .wave_select    (wave_select)    //输出波形选择
 );

endmodule
