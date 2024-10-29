module debug_sg(
   input             sys_clk,
   input             sys_rst_n,
   output reg [7:0]  test_data
   );

   parameter CLK_DIV = 50;
   reg        [31:0] cnt;

   always @(posedge sys_clk or negedge sys_rst_n) begin
      if (~sys_rst_n) begin
         cnt <= 32'b0;
         test_data <= 8'b0;
      end
      else begin
         if (cnt == CLK_DIV/2 - 1) begin
            cnt       <= 32'b0;
            test_data <= ~test_data;
         end
         else begin
            cnt <= cnt + 1'b1;
         end
      end
   end
endmodule