`define ETH_SLAVE
module dds_dso_top (
  input  wire       sys_clk,     //!系统时钟50MHz
  input  wire       sys_rst_n,   //!系统复位，低电平有效
`ifdef ETH_SLAVE
  //以太网RGMII接口
  input              eth_rxc   , //RGMII接收数据时钟
  input              eth_rx_ctl, //RGMII输入数据有效信号
  input       [3:0]  eth_rxd   , //RGMII输入数据
  output             eth_txc   , //RGMII发送数据时钟
  output             eth_tx_ctl, //RGMII输出数据有效信号
  output      [3:0]  eth_txd   , //RGMII输出数据
  output             eth_rst_n , //以太网芯片复位信号，低电平有效
`endif
  //hdmi iic
  output wire       iic_tx_scl, //!HDMI芯片配置IIC时钟
  inout  wire       iic_tx_sda, //!HDMI芯片配置IIC数据
  //hdmi init done
  output wire       led_int,   //!HDMI芯片配置完成指示
  //hdmi_out
  output wire       rstn_out,  //!HDMI复位信号
  output wire       pix_clk,   //!HDMI像素时钟
  output wire       vs_out,    //!HDMI场同步信号
  output wire       hs_out,    //!HDMI行同步信号
  output wire       de_out,    //!HDMI数据有效信号
  output wire [7:0] r_out,     //!HDMI数据R通道
  output wire [7:0] g_out,     //!HDMI数据G通道
  output wire [7:0] b_out,     //!HDMI数据B通道
  //adc
  output wire       ad_clk,    //!ADC采样时钟
  input  wire [7:0] ad_data,   //!ADC采样数据
  //key
  input wire [3:0] key,  //输入4位按键
  //dac
  output wire       da_clk,  //!输入DAC模块时钟
  output wire [7:0] da_data  //!输入DAC模块数据
);

  parameter CNT_MAX = 20'd999_999;  //计数器计数最大值

  wire [ 3:0] wave_select;
  wire [ 8:0] amp_ctl;
  wire [31:0] freq_ctl;
  wire [31:0] min_ctl;
  wire [11:0] phase_ctl;
  wire        key_flag;
  wire        locked;

  wire [ 7:0] trig_level;  //触发电平
  wire [ 9:0] deci_rate;  //抽样率
  wire        wave_run;
  wire        trig_edge;
  wire [ 4:0] v_scale;
  wire        fft_en;
  wire        fir_en;
  wire [11:0] trig_line;

  wire [19:0] ad_freq;  //AD脉冲信号的频率
  wire [ 7:0] ad_vpp;  //AD输入信号峰峰值
  wire [ 7:0] ad_max;  //AD输入信号最大值
  wire [ 7:0] ad_min;  //AD输入信号最小值

  wire vs_hdmi;
  wire hs_hdmi;
  wire de_hdmi;
  wire [7:0] r_hdmi;
  wire [7:0] g_hdmi;
  wire [7:0] b_hdmi;

  pll u_pll (
    .clkin1  (sys_clk),  //50MHz
    .clkout0 (da_clk),   //118.8MHz
    .clkout1 (ad_clk),   //29.7MHz
    .pll_lock(locked)
  );


`ifdef ETH_SLAVE

//开发板MAC地址
parameter  BOARD_MAC = 48'h12_34_56_78_9a_bc;
//开发板IP地址
parameter  BOARD_IP  = {8'd192,8'd168,8'd0,8'd234};
//目的MAC地址
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址
parameter  DES_IP    = {8'd192,8'd168,8'd0,8'd145};

wire          rec_pkt_done /* synthesis PAP_MARK_DEBUG="1" */; //UDP单包数据接收完成信号
wire          rec_en       /* synthesis PAP_MARK_DEBUG="1" */; //UDP接收的数据使能信号
wire  [31:0]  rec_data     /* synthesis PAP_MARK_DEBUG="1" */; //UDP接收的数据
wire  [15:0]  rec_byte_num /* synthesis PAP_MARK_DEBUG="1" */; //UDP接收的有效字节数 单位:byte
wire          gmii_rx_clk;

eth_udp_recv #(
    .BOARD_MAC     (BOARD_MAC   ), //参数例化
    .BOARD_IP      (BOARD_IP    ),
    .DES_MAC       (DES_MAC     ),
    .DES_IP        (DES_IP      )
    ) u_eth_udp_recv(
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
	//GMII时钟
	.gmii_rx_clk   (gmii_rx_clk )
    );
	
eth_recv_dds u_eth_recv_dds(
	.eth_rx_clk   (gmii_rx_clk ),
	.rst_n        (sys_rst_n   ),
	//用户接口
    .rec_pkt_done (rec_pkt_done), //以太网单包数据接收完成信号
    .rec_en       (rec_en      ), //以太网接收的数据使能信号
    .rec_data     (rec_data    ), //以太网接收的数据
    .rec_byte_num (rec_byte_num), //以太网接收的有效字节数 单位:byte
	//dds配置
	.wave_select  (wave_select ) ,   //输出波形选择
    .amp_ctl      (amp_ctl     ) ,   //幅值
    .freq_ctl     (freq_ctl    ) ,   //频率
    .min_ctl      (min_ctl     ) ,   //最小分辨率
    .phase_ctl    (phase_ctl   )     //相位
   );
`else
  key_control u_key_control (
    .sys_clk  (sys_clk),    //系统时钟,50MHz
    .sys_rst_n(sys_rst_n),  //复位信号,低电平有效
    .key      (key),        //输入4位按键

    .wave_select(wave_select)  //输出波形选择
  );
assign amp_ctl = 9'd256;
assign freq_ctl = 32'd3615292;
assign min_ctl = 32'd0;
assign phase_ctl = 12'd1024;
`endif

dds_top u_dds_top (
    .sys_clk        (da_clk     ),   //dac_clk
    .sys_rst_n      (sys_rst_n  ),   //复位信号,低电平有效
    .wave_select    (wave_select),   //输出波形选择
    .amp_ctl        (amp_ctl    ),   //幅值
    .freq_ctl       (freq_ctl   ),   //频率
    .min_ctl        (min_ctl    ),   //最小分辨率
    .phase_ctl      (phase_ctl  ),   //相位
    .data_out       (da_data    )    //波形输出
);

  hdmi_top u_hdmi_top (
	.sys_clk   (sys_clk),     // input system clock 50MHz
	.rstn_out  (rstn_out),
	.iic_tx_scl(iic_tx_scl),
	.iic_tx_sda(iic_tx_sda),
    .led_int   (led_int),
    //hdmi_out
    .pix_clk   (pix_clk),     //pixclk
    .vs_out    (vs_hdmi),
    .hs_out    (hs_hdmi),
    .de_out    (de_hdmi),
    .r_out     (r_hdmi ),
    .g_out     (g_hdmi ),
    .b_out     (b_hdmi)

);


  assign trig_level = 8'd127;
  assign deci_rate = 10'd1;
  assign trig_edge = 1'b1;
  assign v_scale = {1'b1, 4'd2};
  assign wave_run = 1'b1;
  assign fft_en = 1'b0;
  assign fir_en = 1'b1;
  assign trig_line = 12'd512;

  dso_top u_dso_top (
    .sys_clk   (sys_clk),     // input system clock 50MHz
    .sys_rst_n (sys_rst_n),
    // .rstn_out  (rstn_out),
    // .iic_tx_scl(iic_tx_scl),
    // .iic_tx_sda(iic_tx_sda),
    // .led_int   (led_int),

	.i_vs_hdmi(vs_hdmi),
	.i_hs_hdmi(hs_hdmi),
	.i_de_hdmi(de_hdmi),
	.i_r_hdmi(r_hdmi),
	.i_g_hdmi(g_hdmi),
	.i_b_hdmi(b_hdmi),

    .pix_clk(pix_clk),  //pixclk
    .vs_out (vs_out),
    .hs_out (hs_out),
    .de_out (de_out),
    .r_out  (r_out),
    .g_out  (g_out),
    .b_out  (b_out),

    .ad_clk    (ad_clk),
    .ad_data   (ad_data),
    //ctrl regs
    .trig_level(trig_level),  //触发电平
    .deci_rate (deci_rate),   //抽样率
    .wave_run  (wave_run),
    .trig_edge (trig_edge),
    .v_scale   (v_scale),
    .fft_en    (fft_en),
    .fir_en    (fir_en),
    .trig_line (trig_line),
    //measure regs
    .ad_freq   (ad_freq),     //AD脉冲信号的频率
    .ad_vpp    (ad_vpp),      //AD输入信号峰峰值
    .ad_max    (ad_max),      //AD输入信号最大值
    .ad_min    (ad_min)       //AD输入信号最小值

  );
endmodule
