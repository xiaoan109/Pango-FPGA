`include "defines.v"
module iram (
    input wire clk,
    input wire rst_n,
    input wire [`InstAddrBus] pc_n_i,//读地址
    input wire iram_rd_i,//读使能
    output reg [`InstAddrBus] pc_o,//指令地址
    output wire[`InstBus] inst_o,//指令

    output reg iram_rstn_o,//iram模块阻塞

    //ICB Slave iram
    input  wire                 iram_icb_cmd_valid,//cmd有效
    output wire                 iram_icb_cmd_ready,//cmd准备好
    input  wire [`MemAddrBus]   iram_icb_cmd_addr ,//cmd地址
    input  wire                 iram_icb_cmd_read ,//cmd读使能
    input  wire [`MemBus]       iram_icb_cmd_wdata,//cmd写数据
    input  wire [3:0]           iram_icb_cmd_wmask,//cmd写选通
    output reg                  iram_icb_rsp_valid,//rsp有效
    input  wire                 iram_icb_rsp_ready,//rsp准备好
    output wire                 iram_icb_rsp_err  ,//rsp错误
    output wire [`MemBus]       iram_icb_rsp_rdata//rsp读数据
);
/* iram是指令存储器，位于处理器内核，由2部分构成
 * 
 * 1. 用户指令存储区
 * 起始地址: 0x0000_0000
 * 长度: 由宏定义文件配置
 * 用途: 存储需要执行的指令
 * 
 * 2. 在系统编程ISP区
 * 起始地址: 0x0800_0000
 * 长度: 
 * 用途: 复位后PC指向此处，完成数据搬移、UART烧录
 * 
*/
wire [31:0] rst_addr = `RstPC;//复位地址
wire [`MemAddrBus]addra = iram_rstn_o ? rst_addr[31:2] : pc_n_i[31:2];
wire [`MemBus]douta,doutia;
assign inst_o = douta;

//AXI4L总线交互
wire  [`MemAddrBus]addrb;
wire  web,enb;
wire  [3:0] wemb;
wire [`MemBus]doutb,doutib;
wire [`MemBus]dinb;
wire icb_whsk = iram_icb_cmd_valid & ~iram_icb_cmd_read;//写握手
wire icb_rhsk = iram_icb_cmd_valid & iram_icb_cmd_read;//读握手

//PC复位
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        iram_rstn_o <= 1'b1;
        pc_o <= `RstPC;
    end 
    else begin
        iram_rstn_o <= 1'b0;
        if(iram_rd_i) begin
            pc_o <= pc_n_i;
        end
        else begin
            pc_o <= pc_o;
        end
    end
end

always @(posedge clk or negedge rst_n)//读响应控制
if (~rst_n)
    iram_icb_rsp_valid <=1'b0;
else begin
    if (icb_rhsk)
        iram_icb_rsp_valid <=1'b1;
    else if (iram_icb_rsp_valid & iram_icb_rsp_ready)
        iram_icb_rsp_valid <=1'b0;
    else
        iram_icb_rsp_valid <= iram_icb_rsp_valid;
end

assign iram_icb_cmd_ready = 1'b1;
assign iram_icb_rsp_err = addrb > (`IRamSize-1);
assign iram_icb_rsp_rdata = doutb;
assign addrb = iram_icb_cmd_addr[31:2];
`ifdef LIMIT_IRAM_L1K_W
assign web = icb_whsk && (iram_icb_cmd_addr>=1024);
`else
assign web = icb_whsk;
`endif
assign wemb = iram_icb_cmd_wmask;
assign dinb = iram_icb_cmd_wdata;
assign enb = iram_icb_cmd_valid;
dpram #(
    .RAM_DEPTH(`IRamSize)
) inst_appram (
    .clk    (clk),
    .addra  (addra[clogb2(`IRamSize-1)-1:0]),
    .addrb  (addrb[clogb2(`IRamSize-1)-1:0]),
    .dinb   (dinb),
    .web    (web),
    .wemb   (wemb),
    .ena    (iram_rd_i | iram_rstn_o),
    .enb    (enb),
    .douta  (douta),
    .doutb  (doutb)
);


function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction



endmodule