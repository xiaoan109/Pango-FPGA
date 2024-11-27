module la_ui_display (
  input         rst_n,
  input         pclk,
  input         i_hs,
  input         i_vs,
  input         i_de,
  input  [23:0] i_data,
  // input  [2:0]  mode_sel_1,
  input  [2:0]  mode_sel1,
  input  [2:0]  mode_sel2,
  input  [2:0]  mode_sel3,
  input  [2:0]  mode_sel4,
  input  [2:0]  mode_sel5,
  input  [2:0]  mode_sel6,
  input  [2:0]  mode_sel7,
  input  [2:0]  mode_sel8,
  input data_close,
  input [9:0] data,
  // input  [2:0]  chn_sel_1,
  input    trigger_logic,
  input  [3:0]  freq_sel,
  input         uart_en,
  input         spi_en,
  input         iic_en,
  output        o_hs,
  output        o_vs,
  output        o_de,
  output [23:0] o_data
);

//  设置每个通道的触发模式
// 1 低电平
// 2 高电平
// 3 上升沿
// 4 下降沿
// 5 边沿
// 6 无触发
// 0 default


  wire   [23:0] CH1_data_out;
  wire          CH1_vs_out;
  wire          CH1_hs_out;
  wire          CH1_de_out;
   
  wire   [23:0] CH2_data_out;
  wire          CH2_vs_out;
  wire          CH2_hs_out;
  wire          CH2_de_out;
   
  wire   [23:0] CH3_data_out;
  wire          CH3_vs_out;
  wire          CH3_hs_out;
  wire          CH3_de_out;
   
  wire   [23:0] CH4_data_out;
  wire          CH4_vs_out;
  wire          CH4_hs_out;
  wire          CH4_de_out;
   
  wire   [23:0] CH5_data_out;
  wire          CH5_vs_out;
  wire          CH5_hs_out;
  wire          CH5_de_out;
   
  wire   [23:0] CH6_data_out;
  wire          CH6_vs_out;
  wire          CH6_hs_out;
  wire          CH6_de_out;
   
  wire   [23:0] CH7_data_out;
  wire          CH7_vs_out;
  wire          CH7_hs_out;
  wire          CH7_de_out;
   
  wire   [23:0] CH8_data_out;
  wire          CH8_vs_out;
  wire          CH8_hs_out;
  wire          CH8_de_out;

  wire   [23:0] mode_data_out;
  wire          mode_vs_out;
  wire          mode_hs_out; 
  wire          mode_de_out;

  wire   [23:0] trig_CHN_data_out;
  wire          trig_CHN_vs_out;
  wire          trig_CHN_hs_out;
  wire          trig_CHN_de_out;

  wire   [23:0] trig_logic_data_out;
  wire          trig_logic_vs_out;
  wire          trig_logic_hs_out;
  wire          trig_logic_de_out;

  wire   [23:0] sample_freq_data_out;
  wire          sample_freq_vs_out;
  wire          sample_freq_hs_out;
  wire          sample_freq_de_out;

  wire   [23:0] work_mode_data_out;
  wire          work_mode_vs_out;
  wire          work_mode_hs_out;
  wire          work_mode_de_out;
   
  wire   [20:0] osd_addr_req;
  wire   [12:0] osd_rd_addr    [0:20];
  wire   [15:0] osd_rd_data    [0:20];

  char_display #(
    .X_START(360),
    .Y_START(104),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u0_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (i_hs),
    .i_vs      (i_vs),
    .i_de      (i_de),
    .i_data    (i_data),
    .i_char_arr("CH1"),
    .o_hs      (CH1_hs_out),
    .o_vs      (CH1_vs_out),
    .o_de      (CH1_de_out),
    .o_data    (CH1_data_out),
    .o_addr_req(osd_addr_req[0]),
    .o_rd_addr (osd_rd_addr[0]),
    .i_rd_data (osd_rd_data[0])
  );

  char_display #(
    .X_START(360),
    .Y_START(224),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u1_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH1_hs_out),
    .i_vs      (CH1_vs_out),
    .i_de      (CH1_de_out),
    .i_data    (CH1_data_out),
    .i_char_arr("CH2"),
    .o_hs      (CH2_hs_out),
    .o_vs      (CH2_vs_out),
    .o_de      (CH2_de_out),
    .o_data    (CH2_data_out),
    .o_addr_req(osd_addr_req[1]),
    .o_rd_addr (osd_rd_addr[1]),
    .i_rd_data (osd_rd_data[1])
  );

  char_display #(
    .X_START(360),
    .Y_START(344),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u2_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH2_hs_out),
    .i_vs      (CH2_vs_out),
    .i_de      (CH2_de_out),
    .i_data    (CH2_data_out),
    .i_char_arr("CH3"),
    .o_hs      (CH3_hs_out),
    .o_vs      (CH3_vs_out),
    .o_de      (CH3_de_out),
    .o_data    (CH3_data_out),
    .o_addr_req(osd_addr_req[2]),
    .o_rd_addr (osd_rd_addr[2]),
    .i_rd_data (osd_rd_data[2])
  );

  char_display #(
    .X_START(360),
    .Y_START(464),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u3_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH3_hs_out),
    .i_vs      (CH3_vs_out),
    .i_de      (CH3_de_out),
    .i_data    (CH3_data_out),
    .i_char_arr("CH4"),
    .o_hs      (CH4_hs_out),
    .o_vs      (CH4_vs_out),
    .o_de      (CH4_de_out),
    .o_data    (CH4_data_out),
    .o_addr_req(osd_addr_req[3]),
    .o_rd_addr (osd_rd_addr[3]),
    .i_rd_data (osd_rd_data[3])
  );

  char_display #(
    .X_START(360),
    .Y_START(584),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u4_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH4_hs_out),
    .i_vs      (CH4_vs_out),
    .i_de      (CH4_de_out),
    .i_data    (CH4_data_out),
    .i_char_arr("CH5"),
    .o_hs      (CH5_hs_out),
    .o_vs      (CH5_vs_out),
    .o_de      (CH5_de_out),
    .o_data    (CH5_data_out),
    .o_addr_req(osd_addr_req[4]),
    .o_rd_addr (osd_rd_addr[4]),
    .i_rd_data (osd_rd_data[4])
  );

  char_display #(
    .X_START(360),
    .Y_START(704),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u5_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH5_hs_out),
    .i_vs      (CH5_vs_out),
    .i_de      (CH5_de_out),
    .i_data    (CH5_data_out),
    .i_char_arr("CH6"),
    .o_hs      (CH6_hs_out),
    .o_vs      (CH6_vs_out),
    .o_de      (CH6_de_out),
    .o_data    (CH6_data_out),
    .o_addr_req(osd_addr_req[5]),
    .o_rd_addr (osd_rd_addr[5]),
    .i_rd_data (osd_rd_data[5])
  );


  char_display #(
    .X_START(360),
    .Y_START(824),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u6_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH6_hs_out),
    .i_vs      (CH6_vs_out),
    .i_de      (CH6_de_out),
    .i_data    (CH6_data_out),
    .i_char_arr("CH7"),
    .o_hs      (CH7_hs_out),
    .o_vs      (CH7_vs_out),
    .o_de      (CH7_de_out),
    .o_data    (CH7_data_out),
    .o_addr_req(osd_addr_req[6]),
    .o_rd_addr (osd_rd_addr[6]),
    .i_rd_data (osd_rd_data[6])
  );

  char_display #(
    .X_START(360),
    .Y_START(944),
    .X_NUM  (3),
    .Y_NUM  (1)
  ) u7_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH7_hs_out),
    .i_vs      (CH7_vs_out),
    .i_de      (CH7_de_out),
    .i_data    (CH7_data_out),
    .i_char_arr("CH8"),
    .o_hs      (CH8_hs_out),
    .o_vs      (CH8_vs_out),
    .o_de      (CH8_de_out),
    .o_data    (CH8_data_out),
    .o_addr_req(osd_addr_req[7]),
    .o_rd_addr (osd_rd_addr[7]),
    .i_rd_data (osd_rd_data[7])
  );

  wire   [23:0] CH1_mode_data_out;
  wire          CH1_mode_vs_out;
  wire          CH1_mode_hs_out;
  wire          CH1_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(104),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u1_1_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH8_hs_out),
    .i_vs      (CH8_vs_out),
    .i_de      (CH8_de_out),
    .i_data    (CH8_data_out),
    .i_char_arr({"mode:",mode_sel1 == 3'd0 ? "default" :
                         mode_sel1 == 3'd1 ? "low lvl" :
                         mode_sel1 == 3'd2 ? "highlvl" :
                         mode_sel1 == 3'd3 ? "posedge" :
                         mode_sel1 == 3'd4 ? "negedge" : 
                         modelsel1 == 3'd5 ? "anyedge" :
                         modelsel1 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH1_mode_vs_out),
    .o_vs      (CH1_mode_hs_out),
    .o_de      (CH1_mode_de_out),
    .o_data    (CH1_mode_data_out),
    .o_addr_req(osd_addr_req[8]),
    .o_rd_addr (osd_rd_addr[8]),
    .i_rd_data (osd_rd_data[8])
  );


  wire   [23:0] CH2_mode_data_out;
  wire          CH2_mode_vs_out;
  wire          CH2_mode_hs_out;
  wire          CH2_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(224),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u2_2_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH1_mode_vs_out),
    .i_vs      (CH1_mode_hs_out),
    .i_de      (CH1_mode_de_out),
    .i_data    (CH1_mode_data_out),
    .i_char_arr({"mode:",mode_sel2 == 3'd0 ? "default" :
                         mode_sel2 == 3'd1 ? "low lvl" :
                         mode_sel2 == 3'd2 ? "highlvl" :
                         mode_sel2 == 3'd3 ? "posedge" :
                         mode_sel2 == 3'd4 ? "negedge" : 
                         modelsel2 == 3'd5 ? "anyedge" :
                         modelsel2 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH2_mode_vs_out),
    .o_vs      (CH2_mode_hs_out),
    .o_de      (CH2_mode_de_out),
    .o_data    (CH2_mode_data_out),
    .o_addr_req(osd_addr_req[9]),
    .o_rd_addr (osd_rd_addr[9]),
    .i_rd_data (osd_rd_data[9])
  );


  wire   [23:0] CH3_mode_data_out;
  wire          CH3_mode_vs_out;
  wire          CH3_mode_hs_out;
  wire          CH3_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(344),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u3_3_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH2_mode_vs_out),
    .i_vs      (CH2_mode_hs_out),
    .i_de      (CH2_mode_de_out),
    .i_data    (CH2_mode_data_out),
    .i_char_arr({"mode:",mode_sel3 == 3'd0 ? "default" :
                         mode_sel3 == 3'd1 ? "low lvl" :
                         mode_sel3 == 3'd2 ? "highlvl" :
                         mode_sel3 == 3'd3 ? "posedge" :
                         mode_sel3 == 3'd4 ? "negedge" : 
                         modelsel3 == 3'd5 ? "anyedge" :
                         modelsel3 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH3_mode_vs_out),
    .o_vs      (CH3_mode_hs_out),
    .o_de      (CH3_mode_de_out),
    .o_data    (CH3_mode_data_out),
    .o_addr_req(osd_addr_req[10]),
    .o_rd_addr (osd_rd_addr[10]),
    .i_rd_data (osd_rd_data[10])
  );

  wire   [23:0] CH4_mode_data_out;
  wire          CH4_mode_vs_out;
  wire          CH4_mode_hs_out;
  wire          CH4_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(464),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u4_4_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH3_mode_vs_out),
    .i_vs      (CH3_mode_hs_out),
    .i_de      (CH3_mode_de_out),
    .i_data    (CH3_mode_data_out),
    .i_char_arr({"mode:",mode_sel4 == 3'd0 ? "default" :
                         mode_sel4 == 3'd1 ? "low lvl" :
                         mode_sel4 == 3'd2 ? "highlvl" :
                         mode_sel4 == 3'd3 ? "posedge" :
                         mode_sel4 == 3'd4 ? "negedge" : 
                         modelsel4 == 3'd5 ? "anyedge" :
                         modelsel4 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH4_mode_vs_out),
    .o_vs      (CH4_mode_hs_out),
    .o_de      (CH4_mode_de_out),
    .o_data    (CH4_mode_data_out),
    .o_addr_req(osd_addr_req[11]),
    .o_rd_addr (osd_rd_addr[11]),
    .i_rd_data (osd_rd_data[11])
  );

  wire   [23:0] CH5_mode_data_out;
  wire          CH5_mode_vs_out;
  wire          CH5_mode_hs_out;
  wire          CH5_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(584),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u5_5_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH4_mode_vs_out),
    .i_vs      (CH4_mode_hs_out),
    .i_de      (CH4_mode_de_out),
    .i_data    (CH4_mode_data_out),
    .i_char_arr({"mode:",mode_sel5 == 3'd0 ? "default" :
                         mode_sel5 == 3'd1 ? "low lvl" :
                         mode_sel5 == 3'd2 ? "highlvl" :
                         mode_sel5 == 3'd3 ? "posedge" :
                         mode_sel5 == 3'd4 ? "negedge" : 
                         modelsel5 == 3'd5 ? "anyedge" :
                         modelsel5 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH5_mode_vs_out),
    .o_vs      (CH5_mode_hs_out),
    .o_de      (CH5_mode_de_out),
    .o_data    (CH5_mode_data_out),
    .o_addr_req(osd_addr_req[12]),
    .o_rd_addr (osd_rd_addr[12]),
    .i_rd_data (osd_rd_data[12])
  );

  wire   [23:0] CH6_mode_data_out;
  wire          CH6_mode_vs_out;
  wire          CH6_mode_hs_out;
  wire          CH6_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(704),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u6_6_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH5_mode_vs_out),
    .i_vs      (CH5_mode_hs_out),
    .i_de      (CH5_mode_de_out),
    .i_data    (CH5_mode_data_out),
    .i_char_arr({"mode:",mode_sel6 == 3'd0 ? "default" :
                         mode_sel6 == 3'd1 ? "low lvl" :
                         mode_sel6 == 3'd2 ? "highlvl" :
                         mode_sel6 == 3'd3 ? "posedge" :
                         mode_sel6 == 3'd4 ? "negedge" : 
                         modelsel6 == 3'd5 ? "anyedge" :
                         modelsel6 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH6_mode_vs_out),
    .o_vs      (CH6_mode_hs_out),
    .o_de      (CH6_mode_de_out),
    .o_data    (CH6_mode_data_out),
    .o_addr_req(osd_addr_req[13]),
    .o_rd_addr (osd_rd_addr[13]),
    .i_rd_data (osd_rd_data[13])
  );

  wire   [23:0] CH7_mode_data_out;
  wire          CH7_mode_vs_out;
  wire          CH7_mode_hs_out;
  wire          CH7_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(824),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u7_7_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH6_mode_vs_out),
    .i_vs      (CH6_mode_hs_out),
    .i_de      (CH6_mode_de_out),
    .i_data    (CH6_mode_data_out),
    .i_char_arr({"mode:",mode_sel7 == 3'd0 ? "default" :
                         mode_sel7 == 3'd1 ? "low lvl" :
                         mode_sel7 == 3'd2 ? "highlvl" :
                         mode_sel7 == 3'd3 ? "posedge" :
                         mode_sel7 == 3'd4 ? "negedge" : 
                         modelsel7 == 3'd5 ? "anyedge" :
                         modelsel7 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH7_mode_vs_out),
    .o_vs      (CH7_mode_hs_out),
    .o_de      (CH7_mode_de_out),
    .o_data    (CH7_mode_data_out),
    .o_addr_req(osd_addr_req[14]),
    .o_rd_addr (osd_rd_addr[14]),
    .i_rd_data (osd_rd_data[14])
  );

  wire   [23:0] CH8_mode_data_out;
  wire          CH8_mode_vs_out;
  wire          CH8_mode_hs_out;
  wire          CH8_mode_de_out;

  char_display #(
    .X_START(1560),
    .Y_START(944),
    .X_NUM  (7),
    .Y_NUM  (1)
  ) u8_8_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH7_mode_vs_out),
    .i_vs      (CH7_mode_hs_out),
    .i_de      (CH7_mode_de_out),
    .i_data    (CH7_mode_data_out),
    .i_char_arr({"mode:",mode_sel8 == 3'd0 ? "default" :
                         mode_sel8 == 3'd1 ? "low lvl" :
                         mode_sel8 == 3'd2 ? "highlvl" :
                         mode_sel8 == 3'd3 ? "posedge" :
                         mode_sel8 == 3'd4 ? "negedge" : 
                         modelsel8 == 3'd5 ? "anyedge" :
                         modelsel8 == 3'd6 ? "none   " : "error  "}),
    .o_hs      (CH8_mode_vs_out),
    .o_vs      (CH8_mode_hs_out),
    .o_de      (CH8_mode_de_out),
    .o_data    (CH8_mode_data_out),
    .o_addr_req(osd_addr_req[15]),
    .o_rd_addr (osd_rd_addr[15]),
    .i_rd_data (osd_rd_data[15])
  );

  
  wire   [23:0] data_mode_data_out;
  wire          data_mode_vs_out;
  wire          data_mode_hs_out;
  wire          data_mode_de_out;

  char_display #(
    .X_START(10),
    .Y_START(220),
    .X_NUM  (15),
    .Y_NUM  (1)
  ) udata_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (CH8_mode_vs_out),
    .i_vs      (CH8_mode_hs_out),
    .i_de      (CH8_mode_de_out),
    .i_data    (CH8_mode_data_out),
    .i_char_arr({"data:",data_close ? "XXXXXXXXXX":{data[9] ? "1" : "0",
                                                    data[8] ? "1" : "0",
                                                    data[7] ? "1" : "0",
                                                    data[6] ? "1" : "0",
                                                    data[5] ? "1" : "0", 
                                                    data[4] ? "1" : "0",
                                                    data[3] ? "1" : "0",
                                                    data[2] ? "1" : "0",
                                                    data[1] ? "1" : "0",
                                                    data[0] ? "1" : "0"  }}),
    .o_hs      (data_mode_vs_out),
    .o_vs      (data_mode_hs_out),
    .o_de      (data_mode_de_out),
    .o_data    (data_mode_data_out),
    .o_addr_req(osd_addr_req[16]),
    .o_rd_addr (osd_rd_addr[16]),
    .i_rd_data (osd_rd_data[16])
  );


  wire   [23:0] uart_data_mode_data_out;
  wire          uart_data_mode_vs_out;
  wire          uart_data_mode_hs_out;
  wire          uart_data_mode_de_out;

  char_display #(
    .X_START(10),
    .Y_START(262),
    .X_NUM  (17),
    .Y_NUM  (1)
  ) u_uartdata_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (data_mode_vs_out),
    .i_vs      (data_mode_hs_out),
    .i_de      (data_mode_de_out),
    .i_data    (data_mode_data_out),
    .i_char_arr({"uartdata:",data[9]|| ~data[0] ? "XXXXXXXX":{data[1] ? "1" : "0",
                                                    data[2] ? "1" : "0",
                                                    data[3] ? "1" : "0",
                                                    data[4] ? "1" : "0",
                                                    data[5] ? "1" : "0", 
                                                    data[6] ? "1" : "0",
                                                    data[7] ? "1" : "0",
                                                    data[8] ? "1" : "0"  }}),
    .o_hs      (uart_data_mode_vs_out),
    .o_vs      (uart_data_mode_hs_out),
    .o_de      (uart_data_mode_de_out),
    .o_data    (uart_data_mode_data_out),
    .o_addr_req(osd_addr_req[17]),
    .o_rd_addr (osd_rd_addr[17]),
    .i_rd_data (osd_rd_data[17])
  );


  char_display #(
    .X_START(10),
    .Y_START(94),
    .X_NUM  (15),
    .Y_NUM  (1)
  ) u10_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (uart_data_mode_vs_out),
    .i_vs      (uart_data_mode_hs_out),
    .i_de      (uart_data_mode_de_out),
    .i_data    (uart_data_mode_data_out),
    .i_char_arr({"trig logic:", trigger_logic == 1'b0 ? "and " : "or  "}),
    .o_hs      (trig_logic_hs_out),
    .o_vs      (trig_logic_vs_out),
    .o_de      (trig_logic_de_out),
    .o_data    (trig_logic_data_out),
    .o_addr_req(osd_addr_req[18]),
    .o_rd_addr (osd_rd_addr[18]),
    .i_rd_data (osd_rd_data[18])
  );





  char_display #(
    .X_START(10),
    .Y_START(136),
    .X_NUM  (11),
    .Y_NUM  (1)
  ) u11_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (trig_logic_hs_out),
    .i_vs      (trig_logic_vs_out),
    .i_de      (trig_logic_de_out),
    .i_data    (trig_logic_data_out),
    .i_char_arr({"freq:",freq_sel == 4'h0 ? "100 " :
                         freq_sel == 4'h1 ? "500 " :
                         freq_sel == 4'h2 ? "1000" :
                         freq_sel == 4'h3 ? "5000" :
                         freq_sel == 4'h4 ? "10k " :
                         freq_sel == 4'h5 ? "25k " :
                         freq_sel == 4'h6 ? "50k " :
                         freq_sel == 4'h7 ? "100k" :
                         freq_sel == 4'h8 ? "250k" :
                         freq_sel == 4'h9 ? "500k" :
                         freq_sel == 4'ha ? "1M  " :
                         freq_sel == 4'hb ? "2M  " :
                         freq_sel == 4'hc ? "5M  " :
                         freq_sel == 4'hd ? "10M " :
                         freq_sel == 4'he ? "25M " : "50M ","Hz"}),
    .o_hs      (sample_freq_hs_out),
    .o_vs      (sample_freq_vs_out),
    .o_de      (sample_freq_de_out),
    .o_data    (sample_freq_data_out),
    .o_addr_req(osd_addr_req[19]),
    .o_rd_addr (osd_rd_addr[19]),
    .i_rd_data (osd_rd_data[19])
  );

  char_display #(
    .X_START(10),
    .Y_START(178),
    .X_NUM  (14),
    .Y_NUM  (1)
  ) u12_char_display (
    .rst_n     (rst_n),
    .pclk      (pclk),
    .i_hs      (sample_freq_hs_out),
    .i_vs      (sample_freq_vs_out),
    .i_de      (sample_freq_de_out),
    .i_data    (sample_freq_data_out),
    .i_char_arr({"work mode:",uart_en ? "uart" :
                              spi_en  ? "spi " :
                              iic_en  ? "iic " : "cpu "}),
    .o_hs      (work_mode_hs_out),
    .o_vs      (work_mode_vs_out),
    .o_de      (work_mode_de_out),
    .o_data    (work_mode_data_out),
    .o_addr_req(osd_addr_req[20]),
    .o_rd_addr (osd_rd_addr[20]),
    .i_rd_data (osd_rd_data[20])
  );

  osd_rom_multiport #(
    .PORT_NUM(21)
  ) u_osd_rom_multiport (
    .i_clk(pclk),
    .i_rst_n(rst_n),
    .i_addr_req(osd_addr_req),  // one-hot
    .i_rd_addr({
      osd_rd_addr[20],
      osd_rd_addr[19],
      osd_rd_addr[18],
      osd_rd_addr[17],
      osd_rd_addr[16],
      osd_rd_addr[15],
      osd_rd_addr[14],
      osd_rd_addr[13],
      osd_rd_addr[12],
      osd_rd_addr[11],
      osd_rd_addr[10],
      osd_rd_addr[9],
      osd_rd_addr[8],
      osd_rd_addr[7],
      osd_rd_addr[6],
      osd_rd_addr[5],
      osd_rd_addr[4],
      osd_rd_addr[3],
      osd_rd_addr[2],
      osd_rd_addr[1],
      osd_rd_addr[0]
    }),
    .o_rd_data({
      osd_rd_data[20],
      osd_rd_data[19],
      osd_rd_data[18],
      osd_rd_data[17],
      osd_rd_data[16],
      osd_rd_data[15],
      osd_rd_data[14],
      osd_rd_data[13],
      osd_rd_data[12],
      osd_rd_data[11],
      osd_rd_data[10],
      osd_rd_data[9],
      osd_rd_data[8],
      osd_rd_data[7],
      osd_rd_data[6],
      osd_rd_data[5],
      osd_rd_data[4],
      osd_rd_data[3],
      osd_rd_data[2],
      osd_rd_data[1],
      osd_rd_data[0]
    })
  );

  assign o_hs   = work_mode_hs_out;
  assign o_vs   = work_mode_vs_out;
  assign o_de   = work_mode_de_out;
  assign o_data = work_mode_data_out;

endmodule
