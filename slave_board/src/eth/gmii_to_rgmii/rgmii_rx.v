`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// ʵ��ƽ̨: Ұ��FPGAϵ�п�����
// ��˾    : http://www.embedfire.com
// ��̳    : http://www.firebbs.cn
// �Ա�    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module rgmii_rx(
    //��̫��RGMII�ӿ�
    input                   rgmii_rxc   ,      //RGMII����ʱ��
    input                   rgmii_rx_ctl,      //RGMII�������ݿ����ź�
    input       [3:0]       rgmii_rxd   ,      //RGMII��������

    //��̫��GMII�ӿ�
    output                  gmii_rx_clk ,      //GMII����ʱ��
	output                  gmii_rx_clk_phased,//GMII����ʱ�ӣ�ƫ��45��
    output                  gmii_rx_dv  ,      //GMII����������Ч�ź�
    output      [7:0]       gmii_rxd           //GMII��������
    );

//*****************************************************
//**                    main code                    **
//*****************************************************

clk_phase u_clk_phase
(
    .clkin1   (rgmii_rxc            ),  //��̫������ʱ��
    .clkout0  (gmii_rx_clk          ),  //������λƫ�ƺ��ʱ��
	.clkout1  (gmii_rx_clk_phased   ),  //������λƫ�ƺ��ʱ�ӣ�45�ȣ�
    .pll_rst  (1'b0                 ),  //pll��λ
    .pll_lock (pll_lock             )   //pllʱ���ȶ���ʶ
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