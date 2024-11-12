module freq_div(
   input           iSysClk,
   input           iRst,
   input   [3:0]   freq_sel,
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
         4'h0: div_num = 20'd500000;   //100Hz
         4'h1: div_num = 20'd100000;   //500Hz
         4'h2: div_num = 20'd50000;    //1kHz
         4'h3: div_num = 20'd10000;    //5kHz
         4'h4: div_num = 20'd5000;     //10kHz
         4'h5: div_num = 20'd2000;     //25kHz
         4'h6: div_num = 20'd1000;     //50kHz
         4'h7: div_num = 20'd500;      //100kHz
         4'h8: div_num = 20'd200;      //250kHz
         4'h9: div_num = 20'd100;      //500kHz
         4'ha: div_num = 20'd50;       //1MHz 
         4'hb: div_num = 20'd25;       //2MHz
         4'hc: div_num = 20'd10;       //5MHz
         4'hd: div_num = 20'd5;        //10MHz
         4'he: div_num = 20'd2;        //25MHz
         4'hf: div_num = 20'd1;        //50MHz
      endcase
   end
endmodule