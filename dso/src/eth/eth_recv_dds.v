module eth_recv_dds(
	input              eth_rx_clk  ,
	input              rst_n       ,
	//用户接口
    input              rec_pkt_done, //以太网单包数据接收完成信号
    input              rec_en      , //以太网接收的数据使能信号
    input       [31:0] rec_data    , //以太网接收的数据
    input       [15:0] rec_byte_num, //以太网接收的有效字节数 单位:byte
	//dds配置
	output      [ 3:0] wave_select ,   //输出波形选择
    output      [ 8:0] amp_ctl     ,   //幅值
    output      [31:0] freq_ctl    ,   //频率
    output      [31:0] min_ctl     ,   //最小分辨率
    output      [11:0] phase_ctl       //相位
   );
   
	reg [ 3:0]  wave_reg     ;
	reg [ 8:0]  amp_reg      ;
	reg [31:0]  freq_reg     ;
	reg [31:0]  min_reg      ; 
	reg [11:0]  phase_reg    ;
   
	reg [ 2:0]  eth_word_cnt ;
   
	always @(posedge eth_rx_clk or negedge rst_n) begin
		if(!rst_n) begin
			eth_word_cnt <= 3'b0;
		end else if(rec_en) begin
			eth_word_cnt <= rec_pkt_done ? 3'b0 : eth_word_cnt + 3'b1;
		end
	end
			
   
	always @(posedge eth_rx_clk or negedge rst_n) begin
		if(!rst_n) begin
			wave_reg  <= 4'b0;
			amp_reg   <= 9'd256;
			freq_reg  <= 32'd3615292;
			min_reg   <= 32'd0;
			phase_reg <= 12'd1024;
   	end else if(rec_en) begin
			wave_reg  <= eth_word_cnt == 3'd0 ? rec_data[3:0]  : wave_reg;
			amp_reg   <= eth_word_cnt == 3'd1 ? rec_data[8:0]  : amp_reg      ;
			freq_reg  <= eth_word_cnt == 3'd2 ? rec_data       : freq_reg     ;
			min_reg   <= eth_word_cnt == 3'd3 ? rec_data       : min_reg      ;
			phase_reg <= eth_word_cnt == 3'd4 ? rec_data[11:0] : phase_reg    ;
		end
	end
	
	assign wave_select   =  wave_reg  ;
	assign amp_ctl       =  amp_reg   ;
	assign freq_ctl      =  freq_reg  ;
	assign min_ctl       =  min_reg   ;
	assign phase_ctl     =  phase_reg ;
	
	
endmodule