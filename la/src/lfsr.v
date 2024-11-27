module lfsr(
   input          sys_clk,
   input          sys_rst_n,
    output data_clk,
   output reg  [7:0]  test_data
   );

   // reg [7:0] lfsr;   //f(x) = x^8 + x^6 + x^5 + x^4 + 1
   // wire      feedback;

   // assign feedback  = lfsr[7];
   // assign test_data = lfsr;

   // always @(posedge sys_clk or negedge sys_rst_n) begin
   //    if (~sys_rst_n) begin
   //       lfsr <= 8'b0;
   //    end
   //    else begin
   //       lfsr[0] <= feedback;
   //       lfsr[1] <= lfsr[0];
   //       lfsr[2] <= lfsr[1];
   //       lfsr[3] <= lfsr[2];
   //       lfsr[4] <= lfsr[3] ~^ feedback;
   //       lfsr[5] <= lfsr[4] ~^ feedback;
   //       lfsr[6] <= lfsr[5] ~^ feedback;
   //       lfsr[7] <= lfsr[6];
   //    end
   // end

   reg [31:0]cnt;
   always @(posedge sys_clk or negedge sys_rst_n) begin
      if (~sys_rst_n) begin
         cnt <= 32'b0;
      end
      else if (cnt == 32'd1000) begin
         cnt <= 32'b0;
      end
      else begin
         cnt <= cnt + 1'b1;
      end
   end

   reg data_clk;
    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(~sys_rst_n) begin
           data_clk <= 1'b1;         
       // end else if (cnt ==32'd250 || cnt ==32'd500  || cnt ==32'd750|| cnt ==32'd1000) begin
        end else if ( cnt ==32'd500  ||  cnt ==32'd1000) begin
            data_clk <= ~data_clk;        
        end
    end

   always @(posedge sys_clk or negedge sys_rst_n) begin
      if (~sys_rst_n) begin
         test_data <= 8'b10001000;
      end
      else if (cnt==32'd1000-1) begin
         test_data <= {test_data[6:0],test_data[7]};
      end
   end

endmodule