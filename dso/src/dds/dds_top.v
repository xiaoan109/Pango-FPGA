module dds_top (
    input   wire            sys_clk     ,   //dac_clk
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   wave_select ,   //输出波形选择
    input   wire    [8:0]   amp_ctl,   //幅值
    input   wire    [31:0]  freq_ctl  ,   //频率
    input   wire    [31:0]  min_ctl  ,   //最小分辨率
    input   wire    [11:0]  phase_ctl  ,   //相位
    output  wire    [7:0]   data_out        //波形输出
);



//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
parameter   sin_wave    =   4'b0001     ,   //正弦波
            squ_wave    =   4'b0010     ,   //方波
            tri_wave    =   4'b0100     ,   //三角波
            saw_wave    =   4'b1000     ;   //锯齿波
parameter   FREQ_CTRL   =   32'd42949   ,   //相位累加器单次累加值
            PHASE_CTRL  =   12'd1024    ;   //相位偏移量

//reg   define
reg     [31:0]  fre_add     ;   //相位累加器
reg     [11:0]  rom_addr_reg;   //相位调制后的相位码
reg     [13:0]  rom_addr    ;   //ROM读地址

wire [7:0] rd_data;
wire [31:0] tmp_data;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//fre_add:相位累加器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fre_add <=  32'd0;
    else
        // fre_add <=  fre_add + FREQ_CTRL;
        fre_add <=  fre_add + freq_ctl;
// 控制最小分辨率
wire [31:0] fre_add_shift;
assign fre_add_shift = fre_add << min_ctl;
//rom_addr:ROM读地址
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            rom_addr        <=  14'd0;
            rom_addr_reg    <=  11'd0;
        end
    else
    case(wave_select)
        sin_wave:
            begin
                rom_addr_reg    <=  fre_add_shift[31:20] + phase_ctl;
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
        squ_wave:
            begin
                rom_addr_reg    <=  fre_add_shift[31:20] + phase_ctl;
                rom_addr        <=  rom_addr_reg + 14'd4096;
            end     //方波
        tri_wave:
            begin
                rom_addr_reg    <=  fre_add_shift[31:20] + phase_ctl;
                rom_addr        <=  rom_addr_reg + 14'd8192;
            end     //三角波
        saw_wave:
        begin
                rom_addr_reg    <=  fre_add_shift[31:20] + phase_ctl;
                rom_addr        <=  rom_addr_reg + 14'd12288;
            end     //锯齿波
        default:
            begin
                rom_addr_reg    <=  fre_add_shift[31:20] + phase_ctl;
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
    endcase

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//------------------------- rom_wave_inst ------------------------
rom_wave    rom_wave_inst 
(
  .addr     (rom_addr       ),  //rom的读地址       
  .clk      (sys_clk        ),  //读时钟       
  .rst      (1'b0           ),  //复位信号，高电平有效       
  .rd_data  (rd_data       )   //读出波形数据  
);

assign tmp_data = (rd_data - 8'd128) * amp_ctl;
assign data_out = tmp_data[15:8] + 8'd128;
endmodule
