// +FHEADER =====================================================================
// FilePath       : \LA_final\source\freq_div.v
// Author         : zkwang2001 1922601163@qq.com
// CreateDate     : 24-11-24
// LastEditors    : zkwang2001 1922601163@qq.com
// LastEditTime   : 24-11-25
// Version        :
// Description    : 
//                  
// 
// Parameter       :
//                  
// 
// IO Port         :
//                  
// 
// Modification History
//    Date   |   Author   |   Version   |   Change Description
// ==============================================================================
//  23-08-24 |     NJU    |     0.1     | Original Version
//                  
// 
// -FHEADER =====================================================================
module freq_div(
   input           iSysClk,
   input           iRst,
   input   [3:0]   freq_sel,
   output reg  [31:0]  samp_freq, 
   output          clken
);
   reg        clk_div;
   reg [19:0] div_cnt;
   reg [19:0] div_num;
   wire       clk_50M;

   assign clk_50M = (freq_sel == 4'b1111);
   assign clken   = clk_50M ? iSysClk : clk_div;

   always @(posedge iSysClk or negedge iRst) begin
      if (~iRst) begin
         div_cnt <= 20'b0;
         clk_div   <= 1'b0;
      end
      else if (div_cnt == div_num/2 - 1) begin
         div_cnt <= 20'b0;
         clk_div   <= ~clk_div;
      end
      else begin
         div_cnt <= div_cnt + 1'b1;
      end
   end

   always @(freq_sel) begin
      case(freq_sel)
         4'h0: begin div_num = 20'd500000;   samp_freq = 32'd100;     end    //100Hz
         4'h1: begin div_num = 20'd100000;   samp_freq = 32'd500;     end    //500Hz
         4'h2: begin div_num = 20'd50000;    samp_freq = 32'd1000;     end     //1kHz
         4'h3: begin div_num = 20'd10000;    samp_freq = 32'd5000;     end     //5kHz
         4'h4: begin div_num = 20'd5000;   samp_freq = 32'd10000;     end      //10kHz
         4'h5: begin div_num = 20'd2000;   samp_freq = 32'd25000;     end      //25kHz
         4'h6: begin div_num = 20'd1000;   samp_freq = 32'd50000;    end      //50kHz
         4'h7: begin div_num = 20'd500;    samp_freq = 32'd100000;     end       //100kHz
         4'h8: begin div_num = 20'd200;    samp_freq = 32'd250000;     end       //250kHz
         4'h9: begin div_num = 20'd100;    samp_freq = 32'd500000;     end       //500kHz
         4'ha: begin div_num = 20'd50;   samp_freq = 32'd1000000;     end        //1MHz 
         4'hb: begin div_num = 20'd25;   samp_freq = 32'd2000000;     end        //2MHz
         4'hc: begin div_num = 20'd10;   samp_freq = 32'd5000000;     end        //5MHz
         4'hd: begin div_num = 20'd5;    samp_freq = 32'd10000000;     end         //10MHz
         4'he: begin div_num = 20'd2;    samp_freq = 32'd25000000;     end         //25MHz
         4'hf: begin div_num = 20'd1;    samp_freq = 32'd50000000;    end         //50MHz
      endcase
   end
endmodule