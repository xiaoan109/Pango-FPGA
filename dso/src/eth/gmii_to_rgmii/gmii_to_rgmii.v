`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// ʵ��ƽ̨: Ұ��FPGAϵ�п�����
// ��˾    : http://www.embedfire.com
// ��̳    : http://www.firebbs.cn
// �Ա�    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module gmii_to_rgmii
(
    //��̫��GMII�ӿ�
    output             gmii_rx_clk , //GMII����ʱ��
    output             gmii_rx_dv  , //GMII����������Ч�ź�
    output      [7:0]  gmii_rxd    , //GMII��������
    output             gmii_tx_clk , //GMII����ʱ��
    input              gmii_tx_en  , //GMII��������ʹ���ź�
    input       [7:0]  gmii_txd    , //GMII��������
    //��̫��RGMII�ӿ�
    input              rgmii_rxc   , //RGMII����ʱ��
    input              rgmii_rx_ctl, //RGMII�������ݿ����ź�
    input       [3:0]  rgmii_rxd   , //RGMII��������
    output             rgmii_txc   , //RGMII����ʱ��
    output             rgmii_tx_ctl, //RGMII�������ݿ����ź�
    output      [3:0]  rgmii_txd     //RGMII��������
    );

wire gmii_rx_clk_phased;
wire gmii_tx_clk_phased;
//*****************************************************
//**                    main code
//*****************************************************

assign gmii_tx_clk = gmii_rx_clk;
assign gmii_tx_clk_phased = gmii_rx_clk_phased;

//RGMII����
rgmii_rx u_rgmii_rx(
    .gmii_rx_clk        (gmii_rx_clk ),
	.gmii_rx_clk_phased (gmii_rx_clk_phased),
    .rgmii_rxc          (rgmii_rxc   ),
    .rgmii_rx_ctl       (rgmii_rx_ctl),
    .rgmii_rxd          (rgmii_rxd   ),
    .gmii_rx_dv         (gmii_rx_dv  ),
    .gmii_rxd           (gmii_rxd    )
    );

//RGMII����
rgmii_tx u_rgmii_tx(
    .gmii_tx_clk        (gmii_tx_clk ),
	.gmii_tx_clk_phased (gmii_tx_clk_phased),
    .gmii_tx_en         (gmii_tx_en  ),
    .gmii_txd           (gmii_txd    ),
				        
    .rgmii_txc          (rgmii_txc   ),
    .rgmii_tx_ctl       (rgmii_tx_ctl),
    .rgmii_txd          (rgmii_txd   )
    );

endmodule