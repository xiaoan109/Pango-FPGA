// +FHEADER =====================================================================
// FilePath       : \pangoPRJ\RISC-V\rtl\SparrowRV\rtl\soc\icb_top_la.v
// Author         : zkwang2001 1922601163@qq.com
// CreateDate     : 24-10-30
// LastEditors    : zkwang2001 1922601163@qq.com
// LastEditTime   : 24-11-11
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
module icb_top_la(
  input wire sys_clk,
  input wire sys_rst_n,

  input  wire                 la_icb_cmd_valid,//cmd有效
  output wire                 la_icb_cmd_ready,//cmd准备好
  input  wire [31:0]          la_icb_cmd_addr ,//cmd地址
  input  wire                 la_icb_cmd_read ,//cmd读使能
  input  wire [31:0]          la_icb_cmd_wdata,//cmd写数据
  input  wire [3:0]           la_icb_cmd_wmask,//cmd写选通  未使用
  output reg                  la_icb_rsp_valid,//rsp有效
  input  wire                 la_icb_rsp_ready,//rsp准备好
  output wire                 la_icb_rsp_err  ,//rsp错误
  output wire [31:0]          la_icb_rsp_rdata,//rsp读数据

  input wire       pix_clk,     //pixclk
  output wire       vs_out,
  output wire       hs_out,
  output wire       de_out,
  output wire [7:0] r_out,
  output wire [7:0] g_out,
  output wire [7:0] b_out,
  input [2:0] spi_data, 
  input i_vs_hdmi ,
  input i_hs_hdmi ,
  input i_de_hdmi ,
  input [7:0] i_r_hdmi  ,
  input [7:0] i_g_hdmi  ,
  input [7:0] i_b_hdmi  ,
  input               key0,
  input               key1,

  output wire       rstn_out,
  output wire       iic_tx_scl,
  inout  wire       iic_tx_sda
  // output wire       led_int

);

  // ctrl regs 
  // name  | addr | func  
  // reg0  | 0x00 | data_in  
  // reg1  | 0x04 | trigger_en
  // reg2  | 0x08 | chn_sel
  // reg3  | 0x0c | mode_sel
  // reg4  | 0x10 | freq_sel
  // reg5  | 0x14 | pre_num  
  // reg6  | 0x18 | uart_en
  // reg7  | 0x1c | spi_en  
  // reg8  | 0x20 | interval
  wire finished; 
  reg [31:0] reg0,reg1,reg2,reg3,reg4,reg5,reg6,reg7,reg8;
    
  wire [7:0] data_in  = reg0[7:0];
  wire trigger_en = reg1[0];
  wire [2:0] chn_sel = reg2[2:0];
  wire [2:0] mode_sel = reg3[2:0];
  wire [3:0] freq_sel = reg4[3:0];
  wire [9:0] pre_num = reg5[9:0];
  wire uart_en = reg6[0];
  wire spi_en = reg7[0];
  wire [5:0] interval = reg8[5:0];

  wire icb_whsk = la_icb_cmd_valid & ~la_icb_cmd_read;
  wire icb_rhsk = la_icb_cmd_valid & la_icb_cmd_read;

  assign la_icb_rsp_err=1'b0;
  assign la_icb_cmd_ready=1'b1;

  //写响应
    always@(posedge sys_clk)begin
      if(sys_rst_n==1'b0)begin
        reg0<=32'd0;  
        reg1<=32'd0;
        reg2<=32'd0;
        reg3<=32'd0;
        reg4<=32'd0;
        reg5<=32'd0;
        reg6<=32'd0;
        reg7<=32'd0;
        reg8<=32'd1;
      end else if(icb_whsk == 1'b1)begin
        case(la_icb_cmd_addr[7:0])
          32'h00:reg0<=la_icb_cmd_wdata;
          32'h04:reg1<=la_icb_cmd_wdata;
          32'h08:reg2<=la_icb_cmd_wdata;
          32'h0c:reg3<=la_icb_cmd_wdata;
          32'h10:reg4<=la_icb_cmd_wdata;
          32'h14:reg5<=la_icb_cmd_wdata;
          32'h18:reg6<=la_icb_cmd_wdata;
          32'h1c:reg7<=la_icb_cmd_wdata;  
          32'h20:reg8<=la_icb_cmd_wdata;  
          default:;
        endcase         
      end
      else if(finished==1'b1)begin
        reg0<=reg0;
        reg1<=32'd0;
        reg2<=reg2;
        reg3<=reg3;
        reg4<=reg4;
        reg5<=reg5;
        reg6<=reg6;
        reg7<=reg7;
        reg8<=reg8;
      end
    end

  //读响应
    always @(posedge sys_clk) begin
      if (~sys_rst_n)
          la_icb_rsp_valid <= 1'b0;
      else begin
          if (icb_rhsk)
              la_icb_rsp_valid <=1'b1;
          else if (la_icb_rsp_valid & la_icb_rsp_ready)
              la_icb_rsp_valid <=1'b0;
          else
              la_icb_rsp_valid <= la_icb_rsp_valid;
      end
    end

    reg [31:0] rdata; 
    always@(posedge sys_clk) begin
      if(icb_rhsk) begin
        case(la_icb_cmd_addr[7:0])
          32'h00:rdata<=reg0;
          32'h04:rdata<=reg1;
          32'h08:rdata<=reg2;
          32'h0c:rdata<=reg3;
          32'h10:rdata<=reg4;
          32'h14:rdata<=reg5;
          default:;
        endcase
      end 
    end

    assign la_icb_rsp_rdata=rdata;  


     top_analyser u_top_analyser (
      .sys_clk(sys_clk),
      .sys_rst_n(sys_rst_n),
      // .rstn_out(rstn_out),
      // .iic_tx_scl(iic_tx_scl),
      // .iic_tx_sda(iic_tx_sda),
      // .led_int(led_int),
      .i_vs_hdmi                         (i_vs_hdmi                    ),
      .i_hs_hdmi                         (i_hs_hdmi                    ),
      .i_de_hdmi                         (i_de_hdmi                    ),
      .i_r_hdmi                          (i_r_hdmi                     ),
      .i_g_hdmi                          (i_g_hdmi                     ),
      .i_b_hdmi                          (i_b_hdmi                     ),

      .pix_clk(pix_clk),
      .o_hs_wave(hs_out),
      .o_vs_wave(vs_out),
      .o_de_wave(de_out),
      .r_out(r_out),
      .g_out(g_out),
      .b_out(b_out),
      .key0(key0),
      .key1(key1),
      .pre_num(pre_num),
      .finished(finished),
      .data_in(data_in),
      .trigger_en(trigger_en),
      .cpu_chn_sel(chn_sel),
      .cpu_mode_sel(mode_sel),
      .uart_en(uart_en),
      .interval(interval),
      .spi_data(spi_data),
      .spi_en(spi_en),
      .freq_sel(freq_sel)
   );

endmodule

