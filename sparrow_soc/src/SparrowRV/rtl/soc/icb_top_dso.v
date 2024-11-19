module icb_top_dso(
  input wire clk,
  input wire rst_n,

    input  wire                         dso_icb_cmd_valid          ,//cmd有效
    output wire                         dso_icb_cmd_ready          ,//cmd准备好
    input  wire        [  31:0]         dso_icb_cmd_addr           ,//cmd地址
    input  wire                         dso_icb_cmd_read           ,//cmd读使能
    input  wire        [  31:0]         dso_icb_cmd_wdata          ,//cmd写数据
    input  wire        [   3:0]         dso_icb_cmd_wmask          ,//cmd写选通  未使用
    output reg                          dso_icb_rsp_valid          ,//rsp有效
    input  wire                         dso_icb_rsp_ready          ,//rsp准备好
    output wire                         dso_icb_rsp_err            ,//rsp错误
    output wire        [  31:0]         dso_icb_rsp_rdata          ,//rsp读数据

    input  wire                         ad_clk                     ,//ADC模块时钟
    input  wire        [   7:0]         ad_data                    ,

    input                               i_vs_hdmi                  ,
    input                               i_hs_hdmi                  ,
    input                               i_de_hdmi                  ,
    input              [   7:0]         i_r_hdmi                   ,
    input              [   7:0]         i_g_hdmi                   ,
    input              [   7:0]         i_b_hdmi                   ,

    input wire                         pix_clk                    ,//pixclk
    output wire                         vs_out                     ,
    output wire                         hs_out                     ,
    output wire                         de_out                     ,
    output wire        [   7:0]         r_out                      ,
    output wire        [   7:0]         g_out                      ,
    output wire        [   7:0]         b_out                      ,

    output wire                         rstn_out                   ,
    output wire                         iic_tx_scl                 ,
    inout  wire                         iic_tx_sda                 ,
    output wire                         led_int                     

);

  // ctrl regs 
  // name  | addr | func  
  // reg0  | 0x00 | trig_level  
  // reg1  | 0x04 | deci_rate
  // reg2  | 0x08 | wave_run
  // reg3  | 0x0c | trig_edge
  // reg4  | 0x10 | v_scale
  // reg5  | 0x14 | fft_en
  // reg10 | 0x28 | fir_en
  // reg11 | 0x2c | trig_line

  // measure regs 
  // name  | addr | func  
  // reg6  | 0x18 | ad_freq
  // reg7  | 0x1c | ad_vpp
  // reg8  | 0x20 | ad_max
  // reg9  | 0x24 | ad_min
  // 复位值
  // trig_level = 8'd127;
  // deci_rate = 10'd1;
  // wave_run = 1'b1;
  // trig_edge = 1'b1;
  // v_scale = {1'b1, 4'd2};
  // fft_en = 1'b0;


  reg [31:0] reg0,reg1,reg2,reg3,reg4,reg5,reg6,reg7,reg8,reg9,reg10,reg11;

  wire [7:0] trig_level = reg0[7:0];
  wire [9:0] deci_rate = reg1[9:0];
  wire wave_run = reg2[0];
  wire trig_edge = reg3[0];
  wire [4:0] v_scale = reg4[4:0];
  wire fft_en = reg5[0];
  wire fir_en = reg10[0];
  wire [11:0] trig_line = reg11[11:0];

  wire [19:0] ad_freq;
  wire [7:0] ad_vpp;
  wire [7:0] ad_max;
  wire [7:0] ad_min;
  

  wire icb_whsk = dso_icb_cmd_valid & ~dso_icb_cmd_read;//写握手
  wire icb_rhsk = dso_icb_cmd_valid & dso_icb_cmd_read;//读握手
  
  assign dso_icb_cmd_ready = 1'b1;
  assign dso_icb_rsp_err   = 1'b0;
// 写响应
  always@(posedge clk ) begin
    if(rst_n == 1'b0)
    begin
        reg0 <= 32'd127;
        reg1 <= 32'd1;
        reg2 <= 1'b1;
        reg3 <= 1'b1;
        reg4 <= 5'b10010;
        reg5 <= 1'b0;
        reg10 <= 32'b0;
        reg11 <= 32'd512;
    end
    else if (icb_whsk == 1'b1)
    begin
        case(dso_icb_cmd_addr[7:0])
            32'h00: reg0 <= dso_icb_cmd_wdata;
            32'h04: reg1 <= dso_icb_cmd_wdata;
            32'h08: reg2 <= dso_icb_cmd_wdata;
            32'h0c: reg3 <= dso_icb_cmd_wdata;
            32'h10: reg4 <= dso_icb_cmd_wdata;
            32'h14: reg5 <= dso_icb_cmd_wdata;
            32'h28: reg10 <= dso_icb_cmd_wdata;
            32'h2c: reg11 <= dso_icb_cmd_wdata;
            default:;
        endcase
    end
  end

  //读响应控制
  always @(posedge clk)
  if (~rst_n)
      dso_icb_rsp_valid <= 1'b0;
  else begin
      if (icb_rhsk)
          dso_icb_rsp_valid <=1'b1;
      else if (dso_icb_rsp_valid & dso_icb_rsp_ready)
          dso_icb_rsp_valid <=1'b0;
      else
          dso_icb_rsp_valid <= dso_icb_rsp_valid;
  end

  always@(*) begin
      reg6 = ad_freq;
      reg7 = ad_vpp;
      reg8 = ad_max;
      reg9 = ad_min;
    end

  reg [31:0] rdata;
  always@(posedge clk) begin
    if(icb_rhsk) begin
      case(dso_icb_cmd_addr[7:0])
        32'h00: rdata <= reg0;
        32'h04: rdata <= reg1;
        32'h08: rdata <= reg2;
        32'h0c: rdata <= reg3;
        32'h10: rdata <= reg4;
        32'h14: rdata <= reg5;
        32'h18: rdata <= reg6;
        32'h1c: rdata <= reg7;
        32'h20: rdata <= reg8;
        32'h24: rdata <= reg9;
        default:  rdata <= 32'd0;
      endcase
    end
  end
  assign dso_icb_rsp_rdata = rdata;

  dso_top u_dso_top (
    .sys_clk                           (clk                       ),// input system clock 50MHz
    .sys_rst_n                         (rst_n                     ),


    .pix_clk                           (pix_clk                   ),//pixclk
    .vs_out                            (vs_out                    ),
    .hs_out                            (hs_out                    ),
    .de_out                            (de_out                    ),
    .r_out                             (r_out                     ),
    .g_out                             (g_out                     ),
    .b_out                             (b_out                     ),

    .i_vs_hdmi                         (i_vs_hdmi                 ),
    .i_hs_hdmi                         (i_hs_hdmi                 ),
    .i_de_hdmi                         (i_de_hdmi                 ),
    .i_r_hdmi                          (i_r_hdmi                  ),
    .i_g_hdmi                          (i_g_hdmi                  ),
    .i_b_hdmi                          (i_b_hdmi                  ),

    .ad_clk                            (ad_clk                    ),
    .ad_data                           (ad_data                   ),
    //ctrl regs
    .trig_level                        (trig_level                ),//触发电平
    .deci_rate                         (deci_rate                 ),//抽样率
    .wave_run                          (wave_run                  ),
    .trig_edge                         (trig_edge                 ),
    .v_scale                           (v_scale                   ),
    .fft_en                            (fft_en                    ),
    .fir_en                            (fir_en                    ),
    .trig_line                         (trig_line                 ),

    //measure regs
    .ad_freq                           (ad_freq                   ),//AD脉冲信号的频率 
    .ad_vpp                            (ad_vpp                    ),//AD输入信号峰峰值  
    .ad_max                            (ad_max                    ),//AD输入信号最大值  
    .ad_min                            (ad_min                    ) //AD输入信号最小值  

  );



endmodule
