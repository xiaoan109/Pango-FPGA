module pulse_gen(
   input              sys_clk,
   input              sys_rst_n,
   input              finished,  
   output reg         pulse
   );

   reg         [11:0] cnt;

   always @(posedge sys_clk or negedge sys_rst_n) begin
      if (~sys_rst_n) begin
         cnt   <= 11'b0;
         pulse <= 1'b0;
      end
      else if (finished) begin
         pulse <= 1'b0;
         cnt   <= 12'hfff;
      end
      else if (cnt == 12'hffd) begin
         pulse <= 1'b1;
         cnt   <= cnt + 1'b1;
      end
      else if (cnt < 12'hfff) begin
         cnt <= cnt + 1'b1;
      end
      else begin
         cnt   <= cnt;
         pulse <= pulse;
      end
   end
endmodule