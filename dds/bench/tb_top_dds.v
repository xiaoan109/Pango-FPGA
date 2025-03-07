`timescale  1ns/1ns
module  tb_top_dds();

//**************************************************************//
//*************** Parameter and Internal Signal ****************//
//**************************************************************//
parameter   CNT_1MS  = 20'd19000   ,
            CNT_11MS = 21'd69000   ,
            CNT_41MS = 22'd149000  ,
            CNT_51MS = 22'd199000  ,
            CNT_60MS = 22'd249000  ;

//wire  define
wire            dac_clk     ;
wire    [7:0]   dac_data    ;
//
reg vld;
reg [31:0] addr;
reg  [31:0] data_in;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;
reg     [21:0]  tb_cnt      ;
reg             key_in      ;
reg     [1:0]   cnt_key     ;
reg     [3:0]   key         ;


//defparam  define
defparam    top_dds_inst.key_control_inst.CNT_MAX = 24;

//**************************************************************//
//************************** Main Code *************************//
//**************************************************************//
//sys_rst_n,sys_clk,key
initial
    begin
        sys_clk     =   1'b0;
        sys_rst_n   <=   1'b0;       
        key <= 4'b0000;
        
        #200;
        sys_rst_n   <=   1'b1;
    end

always #10 sys_clk = ~sys_clk;

//tb_cnt:按键过程计数器，通过该计数器的计数时间来模拟按键的抖动过程
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        tb_cnt <= 22'b0;
    else    if(tb_cnt == CNT_60MS)
        tb_cnt <= 22'b0;
    else    
        tb_cnt <= tb_cnt + 1'b1;

//key_in:产生输入随机数，模拟按键的输入情况
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key_in <= 1'b1;
    else    if((tb_cnt >= CNT_1MS && tb_cnt <= CNT_11MS)
                || (tb_cnt >= CNT_41MS && tb_cnt <= CNT_51MS))
        key_in <= {$random} % 2;
    else    if(tb_cnt >= CNT_11MS && tb_cnt <= CNT_41MS)
        key_in <= 1'b0;
    else
        key_in <= 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_key <=  2'd0;
    else    if(tb_cnt == CNT_60MS)
        cnt_key <=  cnt_key + 1'b1;
    else
        cnt_key <=  cnt_key;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key     <=  4'b1111;
    else
        case(cnt_key)
            0:      key <=  {3'b111,key_in};
            1:      key <=  {2'b11,key_in,1'b1};
            2:      key <=  {1'b1,key_in,2'b11};
            3:      key <=  {key_in,3'b111};
            default:key <=  4'b1111;
        endcase


  initial begin 
      repeat(10) @(posedge sys_clk);
      @(posedge sys_clk);
      vld <= 1;
      addr <= 32'h00;
      data_in <= 32'd128;
      @(posedge sys_clk);
      vld <= 0;
      repeat(10000) @(posedge sys_clk);

      @(posedge sys_clk);
      vld <= 1;
      addr <= 32'h0c;
      data_in <= 32'd512;
      @(posedge sys_clk);
      vld <= 0;

  end

//**************************************************************//
//************************ Instantiation ***********************//
//**************************************************************//
//------------- top_dds_inst -------------
top_dds top_dds_inst
(
    .sys_clk    (sys_clk    ),
    .sys_rst_n  (sys_rst_n  ),
    .key        (key        ),
    .vld        (vld        ),  
    .addr       (addr),
    .data_in    (data_in    ),
    .dac_clk    (dac_clk    ),
    .dac_data   (dac_data   )
);

GTP_GRS GRS_INST 
(
    .GRS_N(1'b1)

);

endmodule
