module tb_volt2num ();

  parameter IW = 8;
  parameter FW = 8;
  parameter SCALE = 10 ** FW;  //Do not modify!

  reg                         clk;
  reg                         rst_n;
  reg  [              IW-1:0] v_in;
  wire [              IW-1:0] i_out;
  wire [   $clog2(SCALE)-1:0] f_out;

  initial begin
    clk = 1'b0;
    forever begin
      #10 clk = !clk;
    end
  end

  initial begin
    rst_n = 1'b0;
    v_in  = 'b0;

    repeat (10) @(posedge clk);
    rst_n <= 1'b1;
    repeat (10) begin
      repeat (10) @(posedge clk);
      v_in <= {$random} % (1 << IW);
    end
    repeat (10) @(posedge clk);
    $stop;
  end

  volt2num #(
    .IW(IW),
    .FW(FW)
  ) u_volt2num (
    .clk  (clk),
    .rst_n(rst_n),
    .v_in ({v_in, {FW{1'b0}}}),
    .i_out(i_out),
    .f_out(f_out)
  );
endmodule
