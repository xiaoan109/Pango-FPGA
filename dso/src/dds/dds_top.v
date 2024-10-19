module dds_top (
  input wire       sys_clk,     //系统时钟,50MHz
  input wire       sys_rst_n,   //复位信号,低电平有效
  input wire [3:0] wave_select, //波形选择

  output wire       dac_clk,  //输入DAC模块时钟
  output wire [7:0] dac_data  //输入DAC模块波形数据
);
  //parameter define
  parameter FREQ_CTRL = 32'd42949,  //相位累加器单次累加值
  PHASE_CTRL = 12'd1024;  //相位偏移量
  //********************************************************************//
  //****************** Parameter and Internal Signal *******************//
  //********************************************************************//
  //wire  define
  wire pll_lock;

  //dac_clka:DAC模块时钟
  pll_dac u_pll_dac (
    .clkin1  (sys_clk),   // input
    .pll_lock(pll_lock),  // output
    .clkout0 (dac_clk)    // output 125MHz
  );
  // assign dac_clk = ~sys_clk;

  //********************************************************************//
  //*************************** Instantiation **************************//
  //********************************************************************//
  //-------------------------- dds_inst -----------------------------
  dds #(
    .FREQ_CTRL (FREQ_CTRL),
    .PHASE_CTRL(PHASE_CTRL)
  ) dds_inst (
    .sys_clk    (dac_clk),     //系统时钟,50MHz
    .sys_rst_n  (sys_rst_n),   //复位信号,低电平有效
    .wave_select(wave_select), //输出波形选择

    .data_out(dac_data)  //波形输出
  );

endmodule
