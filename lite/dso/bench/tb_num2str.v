module tb_num2str ();

  parameter DATA_WIDTH = 32;
  parameter MAX_NUM = 8;

  reg                   clk;
  reg                   rst_n;
  reg  [DATA_WIDTH-1:0] data_in;
  wire [ MAX_NUM*8-1:0] data_out;

  initial begin
    clk = 1'b0;
    forever begin
      #10 clk = !clk;
    end
  end

  initial begin
    rst_n   = 1'b0;
    data_in = 1'b0;

    repeat (10) @(posedge clk);
    rst_n <= 1'b1;
    repeat (10) @(posedge clk);
    data_in <= 32'd12345678;
    repeat (10) @(posedge clk);
    $stop;
  end

  num2str #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_NUM   (MAX_NUM)
  ) u_num2str (
    .clk     (clk),
    .rst_n   (rst_n),
    .data_in (data_in),
    .data_out(data_out)
  );
endmodule
