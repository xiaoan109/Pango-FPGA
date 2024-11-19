`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// 实验平台: 野火FPGA系列开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module rgmii_rx(
    //以太网RGMII接口
    input                   rgmii_rxc   ,      //RGMII接收时钟
    input                   rgmii_rx_ctl,      //RGMII接收数据控制信号
    input       [3:0]       rgmii_rxd   ,      //RGMII接收数据

    //以太网GMII接口
    output                  gmii_rx_clk ,      //GMII接收时钟
	output                  gmii_rx_clk_phased,//GMII接收时钟，偏移45度
    output                  gmii_rx_dv  ,      //GMII接收数据有效信号
    output      [7:0]       gmii_rxd           //GMII接收数据
    );

//*****************************************************
//**                    main code                    **
//*****************************************************

clk_phase u_clk_phase
(
    .clkin1   (rgmii_rxc            ),  //以太网接收时钟
    .clkout0  (gmii_rx_clk          ),  //经过相位偏移后的时钟
	.clkout1  (gmii_rx_clk_phased   ),  //经过相位偏移后的时钟（45度）
    .pll_rst  (1'b0                 ),  //pll复位
    .pll_lock (pll_lock             )   //pll时钟稳定标识
);

wire [5:0] nc1;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr1(         
    .DI              (rgmii_rxd[0]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd[4],gmii_rxd[0],nc1})
);

wire [5:0] nc2;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr2(
    .DI              (rgmii_rxd[1]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd[5],gmii_rxd[1],nc2})
);

wire [5:0] nc3;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr3(
    .DI              (rgmii_rxd[2]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd[6],gmii_rxd[2],nc3})
);

wire [5:0] nc4;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr4(
    .DI              (rgmii_rxd[3]),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({gmii_rxd[7],gmii_rxd[3],nc4})
);

wire [5:0] nc5;
GTP_ISERDES #(
    .ISERDES_MODE    ("IDDR"),  //"IDDR","IMDDR","IGDES4","IMDES4","IGDES7","IGDES8","IMDES8"
    .GRS_EN          ("TRUE"),  //"TRUE"; "FALSE"
    .LRS_EN          ("TRUE")   //"TRUE"; "FALSE"
) igddr5(
    .DI              (rgmii_rx_ctl),
    .ICLK            (1'd0        ),
    .DESCLK          (gmii_rx_clk ),
    .RCLK            (gmii_rx_clk ),
    .WADDR           (3'd0        ),
    .RADDR           (3'd0        ),
    .RST             (1'b0        ),
    .DO              ({rgmii_rx_ctl_s,gmii_rx_dv,nc5})
);

endmodule