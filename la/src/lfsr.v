module lfsr(
   input          sys_clk,
   input          sys_rst_n,
   output  [7:0]  test_data
   );

   reg [7:0] lfsr;   //f(x) = x^8 + x^6 + x^5 + x^4 + 1
   wire      feedback;

   assign feedback  = lfsr[7];
   assign test_data = lfsr;

   always @(posedge sys_clk or negedge sys_rst_n) begin
      if (~sys_rst_n) begin
         lfsr <= 8'b0;
      end
      else begin
         lfsr[0] <= feedback;
         lfsr[1] <= lfsr[0];
         lfsr[2] <= lfsr[1];
         lfsr[3] <= lfsr[2];
         lfsr[4] <= lfsr[3] ~^ feedback;
         lfsr[5] <= lfsr[4] ~^ feedback;
         lfsr[6] <= lfsr[5] ~^ feedback;
         lfsr[7] <= lfsr[6];
      end
   end
endmodule