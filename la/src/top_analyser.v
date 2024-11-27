module top_analyser(
   input               sys_clk,
   input               sys_rst_n,
   input               key0,
   input               key1,
   input               key2,
   input               key3,
   input    [2:0]      spi_data, 
   input               i_vs_hdmi ,
   input               i_hs_hdmi ,
   input               i_de_hdmi ,
   input    [7:0]      i_r_hdmi  ,
   input    [7:0]      i_g_hdmi  ,
   input    [7:0]      i_b_hdmi  ,
   //hdmi_out
   input               pix_clk,
   output              o_hs_wave,
   output              o_vs_wave,
   output              o_de_wave,
   output   [7:0]      r_out,
   output   [7:0]      g_out,
   output   [7:0]      b_out,
   //params from cpu
   input    [7:0]      data_in,
   input               trigger_en,
   input    [9:0]      pre_num,
   input    [2:0]      cpu_chn_sel,   
   input    [2:0]      cpu_mode_sel,  
   // input    [2:0]      cpu_chn_sel_1,
   // input    [2:0]      cpu_chn_sel_2,
   // input    [2:0]      cpu_mode_sel_1,
   // input    [2:0]      cpu_mode_sel_2,
   input wire cal_freq_open,
   input [31:0] data_freq, // 数据波特率
   input          trigger_logic,
   input    [3:0]      freq_sel,
   input               uart_en,
   input               spi_en,
   input uart_data_valid,

   output              finished
   );

   wire     [7:0]      wr_data;
   wire                wr_en;
   wire     [9:0]      wr_addr;
   wire     [9:0]      rd_addr;
   wire     [9:0]      start_addr;
   wire                wr_over;
   wire     [9:0]      rdaddress;

   wire                o_hs_grid;
   wire                o_vs_grid;
   wire                o_de_grid;
   wire     [23:0]     o_data_grid;

   wire                o_hs_hdmi;
   wire                o_vs_hdmi;
   wire                o_de_hdmi;
   wire     [7:0]      o_r_hdmi;
   wire     [7:0]      o_g_hdmi;
   wire     [7:0]      o_b_hdmi;

   wire                o_hs_ui;
   wire                o_vs_ui;
   wire                o_de_ui;
   wire     [23:0]     o_data_ui;
         
   wire                clken;
   wire                right_shift;
   wire                left_shift;
   wire                zoom_in;
   wire                zoom_out;

wire [2:0] mode_sel1;
wire [2:0] mode_sel2;
wire [2:0] mode_sel3;
wire [2:0] mode_sel4;
wire [2:0] mode_sel5;
wire [2:0] mode_sel6;
wire [2:0] mode_sel7;
wire [2:0] mode_sel8;

wire [31:0] samp_freq;



   assign o_hs_hdmi = i_hs_hdmi ;
   assign o_vs_hdmi = i_vs_hdmi ;
   assign o_de_hdmi = i_de_hdmi ;
   assign o_r_hdmi  = i_r_hdmi  ;
   assign o_g_hdmi  = i_g_hdmi  ;
   assign o_b_hdmi  = i_b_hdmi  ;

   //非uart spi等时选择cpu传输的数据
   wire   data_in_en;
   assign data_in_en = ~uart_en & ~spi_en;


   // //通道选择
   // wire [2:0]  chn_sel_1;
   // wire [2:0]  chn_sel_2;
   wire [2:0] chn_sel;

  //  assign      chn_sel = {3{uart_en}} & 3'b000              // uart 开启
  //                        | {3{data_in_en}} & cpu_chn_sel;   // cpu
  assign chn_sel = cpu_chn_sel;
   // assign      chn_sel_1 = {3{uart_en}} & 3'b100              // uart 开启
   //                       | {3{spi_en}} & 3'b101               // spi 开启
   //                       | {3{data_in_en}} & cpu_chn_sel_1;   // cpu  
   
   // assign      chn_sel_2 = {3{data_in_en}} & cpu_chn_sel_2;

   // //模式选择
   // wire [2:0]  mode_sel_1;
   // wire [2:0]  mode_sel_2;
   wire [2:0] mode_sel;

   assign     mode_sel = {3{uart_en}} & 3'b100             // uart 开启
                         | {3{data_in_en}} & cpu_mode_sel; // cpu

   // assign      mode_sel_1 = {3{uart_en}} & 3'b011             // uart 开启
   //                        | {3{spi_en}} & 3'b011              // spi 开启
   //                        | {3{data_in_en}} & cpu_mode_sel_1; // cpu
   
   // assign      mode_sel_2 = {3{data_in_en}} & cpu_mode_sel_2;

   //采样数据选择               
   wire [7:0]  sample_data;
   wire        tx_data;
   assign      sample_data =  {8{uart_en}} & {7'b0,tx_data} 
                           // | {8{iic_en}}  & {3'b0,iic_data,4'b0}
                           |  {8{data_in_en}} & data_in;

  wire [9:0] o_ram_addr;
  wire [7:0] o_q;

////////////////////////////////////////////////
    wire [9:0] prot_start_addr;
    assign prot_start_addr = start_addr+pre_num;
    wire [9:0] prot_rd_addr;
    wire prot_data_valid;
    reg [9:0] o_ram_addr_r;
    reg [9:0] o_ram_addr_rr;
    always @(posedge pix_clk) begin
      if(~sys_rst_n) begin
        o_ram_addr_r <= 10'b0;
        o_ram_addr_rr <= 10'b0;
      end else begin
        o_ram_addr_r <= o_ram_addr;
        o_ram_addr_rr <= o_ram_addr_r;
      end
    end
    wire pos_o_ram_addr;
    assign pos_o_ram_addr = o_ram_addr_rr != o_ram_addr_r;

    assign prot_data_valid = prot_rd_addr ==o_ram_addr_r && pos_o_ram_addr;

    reg prot_data_valid_r;
    always @(posedge pix_clk) begin
      if(~sys_rst_n) begin
        prot_data_valid_r <= 1'b0;
      end else if(prot_data_valid) begin
        prot_data_valid_r <= ~prot_data_valid_r;
      end
    end

    reg prot_data_valid_rr;
    always @(posedge pix_clk) begin
      if(~sys_rst_n) begin
        prot_data_valid_rr <= 1'b0;
      end else  begin
        prot_data_valid_rr <= prot_data_valid_r;
      end
    end

    wire edge_prot_data_valid;/* synthesis PAP_MARK_DEBUG="true" */
    assign edge_prot_data_valid = prot_data_valid_rr^prot_data_valid_r;

    wire [9:0] prot_data_out;
    wire prot_data_out_valid;

    reg [9:0] ui_data;
    always @(posedge pix_clk) begin
      if(~sys_rst_n) begin
        ui_data <= 8'b0;
      end else if(prot_data_out_valid) begin
        ui_data <= prot_data_out;
      end
    end

//////////////////////////////////////////


   la_wave_display u_la_wave_display (
      .rst_n         (  sys_rst_n                     ), // input
      .pclk          (  pix_clk                       ), // input
      .sys_clk       (  sys_clk                       ), // input
      .wave_color    (  24'hff0000                    ), // input
      .wr_data       (  wr_data                       ), // input
      .wr_en         (  wr_en                         ), // input
      .wr_addr       (  wr_addr                       ), // input
      .start_addr    (  start_addr                    ), // input
      .i_hs          (  o_hs_grid                     ), // input
      .i_vs          (  o_vs_grid                     ), // input
      .i_de          (  o_de_grid                     ), // input
      .i_data        (  o_data_grid                   ), // input
      .trigger_en    (  trigger_en                    ), // input
      .right_shift   (  right_shift                   ), // input
      .left_shift    (  left_shift                    ), // input
      .zoom_in       (  zoom_in                       ), // input
      .zoom_out      (  zoom_out                      ), // input
      .pre_num       (  pre_num                       ), // input
      .o_ram_addr(o_ram_addr),
      .o_q(o_q),
      .o_hs          (  o_hs_wave                     ), // output
      .o_vs          (  o_vs_wave                     ), // output
      .o_de          (  o_de_wave                     ), // output
      .o_data        (  {r_out,g_out,b_out}           )  // output
   );

   la_ui_display u_la_ui_display (
      .rst_n         (  sys_rst_n                     ), // input
      .pclk          (  pix_clk                       ), // input
      .i_hs          (  o_hs_hdmi                     ), // input
      .i_vs          (  o_vs_hdmi                     ), // input
      .i_de          (  o_de_hdmi                     ), // input
      .i_data        (  {o_r_hdmi,o_g_hdmi,o_b_hdmi}  ), // input
      // .mode_sel_1    (  mode_sel_1                    ), // input
      // .mode_sel_2    (  mode_sel_2                    ), // input
      // .chn_sel_1     (  chn_sel_1                     ), // input
      // .chn_sel_2     (  chn_sel_2                     ), // input
      .data_close(1'b0), // 开启数据显示
      .data(ui_data),
      .mode_sel1     (  mode_sel1                     ), // input
      .mode_sel2     (  mode_sel2                     ), // input
      .mode_sel3     (  mode_sel3                     ), // input
      .mode_sel4     (  mode_sel4                     ), // input
      .mode_sel5     (  mode_sel5                     ), // input
      .mode_sel6     (  mode_sel6                     ), // input
      .mode_sel7     (  mode_sel7                     ), // input
      .mode_sel8     (  mode_sel8                     ), // input

      .trigger_logic (  trigger_logic                 ), // input
      .freq_sel      (  freq_sel                      ), // input
      .uart_en       (  uart_en                       ), // input
      .spi_en        (  spi_en                        ), // input
      .iic_en        (  iic_en                        ), // input
      .o_hs          (  o_hs_ui                       ), // output
      .o_vs          (  o_vs_ui                       ), // output
      .o_de          (  o_de_ui                       ), // output
      .o_data        (  o_data_ui                     )  // output
   ); 
   
   la_grid_display u_grid_display (
      .rst_n         (  sys_rst_n                     ), // input
      .pclk          (  pix_clk                       ), // input
      .i_hs          (  o_hs_ui                       ), // input
      .i_vs          (  o_vs_ui                       ), // input
      .i_de          (  o_de_ui                       ), // input
      .i_data        (  o_data_ui                     ), // input
      .o_hs          (  o_hs_grid                     ), // output
      .o_vs          (  o_vs_grid                     ), // output
      .o_de          (  o_de_grid                     ), // output
      .o_data        (  o_data_grid                   )  // output
   ); 

   sample_ctrl u_sample_ctrl( 
      .iSysClk       (  sys_clk                       ),   // input
      .iRst          (  sys_rst_n                     ),   // input
      .clk_en        (  clken                         ),   // input
      .trigger_en    (  trigger_en                    ),   // input
      .chn_sel     (  chn_sel                     ),   // input
      // .chn_sel_2     (  chn_sel_2                     ),   // input
      .mode_sel    (  mode_sel                    ),   // input
      // .mode_sel    (  mode_sel_2                    ),   // input
      .data_in       (  sample_data                   ),   // input
      .pre_num       (  pre_num                       ),   // input
      .trigger_logic (  trigger_logic                 ),   // input
      .start_addr    (  start_addr                    ),   // output
      .finished      (  finished                      ),   // output
      .wr_addr       (  wr_addr                       ),   // output
      .wr_data       (  wr_data                       ),   // output
      .mode_sel1     (  mode_sel1                     ), // output
      .mode_sel2     (  mode_sel2                     ), // output
      .mode_sel3     (  mode_sel3                     ), // output
      .mode_sel4     (  mode_sel4                     ), // output
      .mode_sel5     (  mode_sel5                     ), // output
      .mode_sel6     (  mode_sel6                     ), // output
      .mode_sel7     (  mode_sel7                     ), // output
      .mode_sel8     (  mode_sel8                     ), // output
      .wr_en         (  wr_en                         )    // output
   ); 

//  测量数据时钟频率

  wire [19:0]  cal_freq;
  freq_measure u_freq_measure (
    .clk_fs(sys_clk),
    .rst_n (sys_rst_n),

    .clk_fx(sample_data[0]),  // 被测时钟信号
    .data_fx(cal_freq)  // 被测时钟频率输出
  );

  // reg [19:0] cal_freq_r;
  // always@(posedge sys_clk) begin
  //   if(~sys_rst_n) begin
  //     cal_freq_r <= 20'b0;
  //   end else begin
  //     cal_freq_r <= cal_freq;
  //   end
  // end

  wire [31:0] prot_freq ; /* synthesis PAP_MARK_DEBUG="true" */
  assign prot_freq = cal_freq_open ? {12'b0,cal_freq} : data_freq;

    prot_parse u_prot_parse (
    .clk             ( pix_clk          ), // input
    .rst_n           ( sys_rst_n          ), // input
    .samp_freq       ( samp_freq                  ), // input
    .data_freq       (  prot_freq        ), // input
    .start           ( finished          ), // input
    .start_addr      (  prot_start_addr                  ), // input
    .data_in_valid   (    edge_prot_data_valid               ), // input
    .data_in         (    o_q[chn_sel]                ), // input
    .rd_addr         (       prot_rd_addr             ), // output
    .data_out        (    prot_data_out                ), // output
    .data_out_valid_w  (      prot_data_out_valid              )  // output
  ); 



   freq_div u_freq_div (   
      .iSysClk       (  sys_clk                       ), // input
      .iRst          (  sys_rst_n                     ), // input
      .freq_sel      (  freq_sel                      ), // input
      .samp_freq          (samp_freq             ),
      .clken         (  clken                         )  // output
   ); 



   uart_tx u_uart_tx (  
      .sys_clk       (  sys_clk                       ), // input
      .sys_rst_n     (  sys_rst_n                     ), // input
      .pi_data       (  data_in                       ), // input
      .pi_flag       (  uart_data_valid                       ), // input
      .tx            (  tx_data                       )  // output
   );    

  key_filter u0_key_filter (  
    .sys_clk         (  sys_clk                       ), // input
    .sys_rst_n       (  sys_rst_n                     ), // input
    .key_in          (  key0                          ), // input
    .key_flag        (  left_shift                    )  // output
  );  

  key_filter u1_key_filter (  
    .sys_clk         (  sys_clk                       ), // input
    .sys_rst_n       (  sys_rst_n                     ), // input
    .key_in          (  key1                          ), // input
    .key_flag        (  right_shift                   )  // output
  );

  key_filter u2_key_filter (  
    .sys_clk         (  sys_clk                       ), // input
    .sys_rst_n       (  sys_rst_n                     ), // input
    .key_in          (  key2                          ), // input
    .key_flag        (  zoom_out                      )  // output
  );
  
  key_filter u3_key_filter (  
    .sys_clk         (  sys_clk                       ), // input
    .sys_rst_n       (  sys_rst_n                     ), // input
    .key_in          (  key3                          ), // input
    .key_flag        (  zoom_in                       )  // output
  ); 

endmodule