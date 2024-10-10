
/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module picosoc (
  input        clk_50m,
  input        resetn,
  //interrupt
  input        irq_5,
  input        irq_6,
  input        irq_7,
  //uart
  output       ser_tx,
  input        ser_rx,
  //led
  output [7:0] led,
  //spi
  output       spi_clk,
  output       spi_mosi,
  input        spi_miso,
  output       spi_cs
);
  wire        mem_valid  /* synthesis syn_keep = 1 */;
  wire        mem_instr  /* synthesis syn_keep = 1 */;
  wire        mem_ready  /* synthesis syn_keep = 1 */;
  wire [31:0] mem_addr  /* synthesis syn_keep = 1 */;
  wire [31:0] mem_wdata  /* synthesis syn_keep = 1 */;
  wire [ 3:0] mem_wstrb  /* synthesis syn_keep = 1 */;
  wire [31:0] mem_rdata  /* synthesis syn_keep = 1 */;
  //clk && rst-----------------------------------------------------------------------------
  wire        sys_clk;
  wire        pll_lock;
  pll u_pll (
    .clkin1  (clk_50m),
    .pll_lock(pll_lock),
    .clkout0 (sys_clk)
  );

  wire   reset_n0;
  reg    reset_n/* synthesis syn_maxfan=3 */;
  reg [5:0] reset_cnt = 0;
  wire resetn0 = &reset_cnt;

  always @(posedge clk_50m) begin
    reset_cnt <= reset_cnt + !resetn0;
  end

  assign reset_n0 = resetn0 && resetn && pll_lock;

  always @(posedge sys_clk) begin
    reset_n <= reset_n0;
  end
  //core------------------------------------------------------------------------------------
  parameter integer MEM_WORDS = 1024;
  parameter [31:0] STACKADDR = (4 * MEM_WORDS);
  parameter [31:0] PROGADDR_RESET = 32'h0000_1000;

  reg [31:0] irq;
  always @* begin
    irq = 0;
    irq[5] = ~irq_5;
    irq[6] = ~irq_6;
    irq[7] = ~irq_7;
  end

  picorv32 #(
    .STACKADDR(STACKADDR),
    .PROGADDR_RESET(PROGADDR_RESET),
    .PROGADDR_IRQ(32'h0000_0000),
    .BARREL_SHIFTER(1),
    .COMPRESSED_ISA(1),
    .ENABLE_MUL(1),
    .ENABLE_DIV(1),
    .ENABLE_IRQ(1),
    .ENABLE_IRQ_QREGS(0)
  ) cpu (
    .clk      (sys_clk),
    .resetn   (reset_n),
    .mem_valid(mem_valid),
    .mem_instr(mem_instr),
    .mem_ready(mem_ready),
    .mem_addr (mem_addr),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb),
    .mem_rdata(mem_rdata),
    .irq      (irq)
  );
  //cmd-------------------------------------------------------------------------------------
  parameter integer CMD_NUM = 8192;
  parameter [31:0] perp_addr = (4 * CMD_NUM);  //32'h8000
  reg ram_ready;
  reg [31:0] ram_rdata;
  //0-1023 sram, 1024-8191 cmd
  reg [31:0] memory[0:CMD_NUM-1]  /* synthesis syn_ramstyle = "block_ram" */;
  initial begin
    $readmemh("ram.hex", memory, 1024);
  end

  wire ram_en;
  assign ram_en = mem_valid && !mem_ready && mem_addr < perp_addr;

  always @(posedge sys_clk) begin
    ram_ready <= 0;
    if (ram_en) ram_ready <= 1;
  end

  always @(posedge sys_clk) begin
    if (ram_en) ram_rdata <= memory[mem_addr>>2];
  end

  always @(posedge sys_clk) begin
    if (ram_en) begin
      if (mem_wstrb[0]) memory[mem_addr>>2][7:0] <= mem_wdata[7:0];
      if (mem_wstrb[1]) memory[mem_addr>>2][15:8] <= mem_wdata[15:8];
      if (mem_wstrb[2]) memory[mem_addr>>2][23:16] <= mem_wdata[23:16];
      if (mem_wstrb[3]) memory[mem_addr>>2][31:24] <= mem_wdata[31:24];
    end
  end
  //UART------------------------------------------------------------------------------------
  wire simpleuart_reg_div_sel = mem_valid && (mem_addr == perp_addr);
  wire [31:0] simpleuart_reg_div_do;

  wire        simpleuart_reg_dat_sel = mem_valid && (mem_addr == (perp_addr + 32'h10))/* synthesis syn_keep = 1 */;
  wire [31:0] simpleuart_reg_dat_do  /* synthesis syn_keep = 1 */;
  wire simpleuart_reg_dat_wait;

  simpleuart simpleuart (
    .clk   (sys_clk),
    .resetn(reset_n),

    .ser_tx(ser_tx),
    .ser_rx(ser_rx),

    .reg_div_we(simpleuart_reg_div_sel ? mem_wstrb : 4'b0000),
    .reg_div_di(mem_wdata),
    .reg_div_do(simpleuart_reg_div_do),

    .reg_dat_we  (simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b0),
    .reg_dat_re  (simpleuart_reg_dat_sel && !mem_wstrb),
    .reg_dat_di  (mem_wdata),
    .reg_dat_do  (simpleuart_reg_dat_do),
    .reg_dat_wait(simpleuart_reg_dat_wait)
  );
  //GPIO-------------------------------------------------------------------------------------
  wire gpio_out_sel = mem_valid && (mem_addr == (perp_addr + 32'h20));
  wire [31:0] gpio_out_data;

  wire gpio_in_sel = mem_valid && (mem_addr == (perp_addr + 32'h30));
  wire [31:0] gpio_in_data;

  gpio gpio (
    .clk   (sys_clk),
    .resetn(reset_n),

    .gpio_data    (mem_wdata),
    .gpio_out_we  (gpio_out_sel ? mem_wstrb : 4'b0000),
    .gpio_out_data(gpio_out_data),

    .ex_data     (32'haa55),
    .gpio_in_we  (gpio_in_sel ? 4'b1111 : 4'b0000),  //just 32bit
    .gpio_in_data(gpio_in_data)
  );

  //SPI--------------------------------------------------------------------------------------
  wire spi_ready;
  wire [31:0] spi_rdata;
  nmi2spi #(
    .perp_addr(perp_addr)
  ) spi (
    .clk     (sys_clk),
    .rst_n   (reset_n),
    .valid   (mem_valid && mem_addr >= perp_addr + 32'h40 && mem_addr < perp_addr + 32'h50),
    .ready   (spi_ready),
    .addr    (mem_addr),
    .wdata   (mem_wdata),
    .rdata   (spi_rdata),
    .spi_clk (spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_cs  (spi_cs)
  );

  //BUS Control Signal---------------------------------------------------------------------------
  assign mem_ready = ram_ready || simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait) || gpio_out_sel || gpio_in_sel || spi_ready;

  assign mem_rdata = ram_ready ? ram_rdata : simpleuart_reg_div_sel ? simpleuart_reg_div_do : simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 
                       gpio_out_sel ? gpio_out_data : gpio_in_sel ? gpio_in_data : spi_ready ? spi_rdata : 32'h 0000_0000;

  assign led = (gpio_out_sel) ? gpio_out_data[7:0] : led;

endmodule


