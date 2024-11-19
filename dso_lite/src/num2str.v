module num2str #(
  parameter DATA_WIDTH    = 32,
  parameter MAX_NUM       = 8,
  parameter LEADING_ZEROS = 0
) (
  input  wire                  clk,
  input  wire                  rst_n,
  input  wire [DATA_WIDTH-1:0] data_in,
  output reg  [ MAX_NUM*8-1:0] data_out
);

  localparam NUM_OFFSET = 48;

  reg [2:0] cnt;
  reg [DATA_WIDTH-1:0] reg_data;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 3'b0;
    end else begin
      cnt <= cnt + 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_data <= 'b0;
    end else if (cnt == 0) begin
      reg_data <= data_in;
    end else begin
      reg_data <= reg_data / 10;
    end
  end

  genvar i;
  generate
    for (i = 0; i < MAX_NUM; i = i + 1) begin : gen_num
      always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          data_out[i*8+:8] <= 8'hff;
        end else if (LEADING_ZEROS == 0 && data_in == 0) begin
          data_out[i*8+:8] <= i == 0 ? NUM_OFFSET : 8'hff;
        end else if ((cnt == (i + 1) % 8)) begin
          if (LEADING_ZEROS == 0 && reg_data == 0) begin
            data_out[i*8+:8] <= 8'hff;
          end else begin
            data_out[i*8+:8] <= reg_data % 10 + NUM_OFFSET;
          end
        end
      end
    end
  endgenerate



endmodule
