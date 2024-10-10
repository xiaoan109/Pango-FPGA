//-------------------------------------
// Programmer's model
// 0x00 W     reg_cs              chip select
// 0x04 W     reg_txd[7:0]        Data Write Register
// 0x08 R     reg_rxd[7:0]        Data Read Register 
//-------------------------------------
module nmi2spi #(
  parameter [31:0] perp_addr = 32'b0
) (
  input wire clk,
  input wire rst_n,
  input wire valid,
  output wire ready,
  input wire [31:0] addr,
  input wire [31:0] wdata,
  output wire [31:0] rdata,

  output wire spi_clk,
  output wire spi_mosi,
  input  wire spi_miso,
  output wire spi_cs
);

  reg reg_cs;
  reg [7:0] reg_txd;
  reg reg_tx_dv;
  wire wire_tx_ready;
  wire wire_rx_dv;
  wire [7:0] wire_rxd;
  reg [7:0] reg_rxd;
  reg reg_rx_dv;

  wire reg_cs_sel;
  wire reg_tx_sel;
  wire reg_rx_sel;

  assign reg_cs_sel = valid && (addr == perp_addr + 32'h40);
  assign reg_tx_sel = valid && (addr == perp_addr + 32'h44);
  assign reg_rx_sel = valid && (addr == perp_addr + 32'h48);

  always @(posedge clk) begin
    if (!rst_n) begin
      reg_cs <= 1'b1;
    end else if (reg_cs_sel) begin
      reg_cs <= wdata[0];
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      reg_txd <= 8'b0;
    end else if (reg_tx_sel) begin
      reg_txd <= wdata[7:0];
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      reg_tx_dv <= 1'b0;
    end else begin
      reg_tx_dv <= reg_tx_sel;
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      reg_rxd   <= 8'b0;
      reg_rx_dv <= 1'b0;
    end else if (reg_rx_sel && reg_rx_dv) begin
      reg_rxd   <= 8'b0;
      reg_rx_dv <= 1'b0;
    end else if (wire_rx_dv) begin
      reg_rxd   <= wire_rxd;
      reg_rx_dv <= 1'b1;
    end
  end

  assign rdata = reg_rx_sel ? {24'b0, reg_rxd} : 32'b0;

  assign ready = reg_cs_sel || (reg_tx_sel && wire_tx_ready) || (reg_rx_sel && reg_rx_dv);



  SPI_Master #(
    .SPI_MODE(0),
    .CLKS_PER_HALF_BIT(2)  // divide clk by 4
  ) u_SPI_Master (
    // Control/Data Signals,
    .i_Rst_L(rst_n),
    .i_Clk  (clk),

    // TX (MOSI) Signals
    .i_TX_Byte (reg_txd),       // Byte to transmit on MOSI
    .i_TX_DV   (reg_tx_dv),     // Data Valid Pulse with i_TX_Byte
    .o_TX_Ready(wire_tx_ready), // Transmit Ready for Byte

    // RX (MISO) Signals
    .o_RX_DV  (wire_rx_dv),  // Data Valid pulse (1 clock cycle)
    .o_RX_Byte(wire_rxd),    // Byte received on MISO

    // SPI Interface
    .o_SPI_Clk (spi_clk),
    .i_SPI_MISO(spi_miso),
    .o_SPI_MOSI(spi_mosi)
  );

  assign spi_cs = reg_cs;

endmodule
