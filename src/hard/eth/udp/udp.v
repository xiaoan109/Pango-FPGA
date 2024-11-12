`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// ʵ��ƽ̨: Ұ��FPGAϵ�п�����
// ��˾    : http://www.embedfire.com
// ��̳    : http://www.firebbs.cn
// �Ա�    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module udp(
    input                rst_n       , //��λ�źţ��͵�ƽ��Ч
    //GMII�ӿ�
    input                gmii_rx_clk , //GMII��������ʱ��
    input                gmii_rx_dv  , //GMII����������Ч�ź�
    input        [7:0]   gmii_rxd    , //GMII��������
    input                gmii_tx_clk , //GMII��������ʱ��
    output               gmii_tx_en  , //GMII���������Ч�ź�
    output       [7:0]   gmii_txd    , //GMII�������
    //�û��ӿ�
    output               rec_pkt_done, //��̫���������ݽ�������ź�
    output               rec_en      , //��̫�����յ�����ʹ���ź�
    output       [31:0]  rec_data    , //��̫�����յ�����
    output       [15:0]  rec_byte_num, //��̫�����յ���Ч�ֽ��� ��λ:byte
    input                tx_start_en , //��̫����ʼ�����ź�
    input        [31:0]  tx_data     , //��̫������������
    input        [15:0]  tx_byte_num , //��̫�����͵���Ч�ֽ��� ��λ:byte
    output               tx_done     , //��̫����������ź�
    output               tx_req        //�����������ź�
    );

//parameter define
//������MAC��ַ
parameter BOARD_MAC = 48'h12_34_56_78_9a_bc;   //���վ����MAC��ַ��IP��ַ�ɶ��㴫�룬����ֻ��Ҫ����ͺ�
//������IP��ַ
parameter BOARD_IP  = {8'd0,8'd0,8'd0,8'd0};
//Ŀ��MAC��ַ
parameter  DES_MAC  = 48'h2c_f0_5d_32_f1_07;
//Ŀ��IP��ַ
parameter  DES_IP   = {8'd0,8'd0,8'd0,8'd0};

//wire define
wire          crc_en  ; //CRC��ʼУ��ʹ��
wire          crc_clr ; //CRC���ݸ�λ�ź�
wire  [7:0]   crc_d8  ; //�����У��8λ����

wire  [31:0]  crc_data; //CRCУ������
wire  [31:0]  crc_next; //CRC�´�У���������

//*****************************************************
//**                    main code
//*****************************************************

assign  crc_d8 = gmii_txd;

//��̫������ģ��
udp_rx
   #(
    .BOARD_MAC       (BOARD_MAC),         //��������
    .BOARD_IP        (BOARD_IP )
    )
   u_udp_rx(
    .clk             (gmii_rx_clk ),
    .rst_n           (rst_n       ),
    .gmii_rx_dv      (gmii_rx_dv  ),
    .gmii_rxd        (gmii_rxd    ),
    .rec_pkt_done    (rec_pkt_done),
    .rec_en          (rec_en      ),
    .rec_data        (rec_data    ),
    .rec_byte_num    (rec_byte_num)
    );

//��̫������ģ��
udp_tx
   #(
    .BOARD_MAC       (BOARD_MAC ),         //��������
    .BOARD_IP        (BOARD_IP  ),
    .DES_MAC         (DES_MAC   ),
    .DES_IP          (DES_IP    )
    )
   u_udp_tx(
    .clk             (gmii_tx_clk),
    .rst_n           (rst_n      ),
    .tx_start_en     (tx_start_en),
    .tx_data         (tx_data    ),
    .tx_byte_num     (tx_byte_num),
    .crc_data        (crc_data   ),
    .crc_next        (crc_next[31:24]),
    .tx_done         (tx_done    ),
    .tx_req          (tx_req     ),
    .gmii_tx_en      (gmii_tx_en ),
    .gmii_txd        (gmii_txd   ),
    .crc_en          (crc_en     ),
    .crc_clr         (crc_clr    )
    );

//��̫������CRCУ��ģ��
crc32_d8   u_crc32_d8(
    .clk             (gmii_tx_clk),
    .rst_n           (rst_n      ),
    .data            (crc_d8     ),
    .crc_en          (crc_en     ),
    .crc_clr         (crc_clr    ),
    .crc_data        (crc_data   ),
    .crc_next        (crc_next   )
    );

endmodule