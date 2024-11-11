module eth_send_dds(
	input             eth_tx_clk  ,
	input             rst_n       ,
	//用户接口
    output            tx_start_en , //以太网开始发送信号
    output     [31:0] tx_data     , //以太网待发送数据
    output     [15:0] tx_byte_num , //以太网发送的有效字节数 单位:byte
    input             tx_done     , //以太网发送完成信号
    input             tx_req      ,  //读数据请求信号
	//dds发送使能
	input             dds_ctrl_en ,
	//dds配置
	input      [ 3:0] wave_select ,   //输出波形选择
    input      [ 8:0] amp_ctl     ,   //幅值
    input      [31:0] freq_ctl    ,   //频率
    input      [31:0] min_ctl     ,   //最小分辨率
    input      [11:0] phase_ctl       //相位
   );
   
	reg        dds_ctrl_en_d0    ;
	reg        dds_ctrl_en_d1    ;
	reg [ 2:0] eth_word_cnt      ;
	reg [31:0] tx_data_reg       ;
	// wire      dds_ctrl_en_pos   ;
	
	
	
	always @(posedge eth_tx_clk or negedge rst_n) begin
		if(!rst_n) begin
			dds_ctrl_en_d0 <= 1'b0;
			dds_ctrl_en_d1 <= 1'b1;
		end else begin
			dds_ctrl_en_d0 <= dds_ctrl_en;
			dds_ctrl_en_d1 <= dds_ctrl_en_d0;
		end
	end
	
	assign tx_start_en = !dds_ctrl_en_d1 && dds_ctrl_en_d0;
	
	assign tx_byte_num = 16'd160; //5*8*4
   
   
   always @(posedge eth_tx_clk or negedge rst_n) begin
		if(!rst_n) begin
			eth_word_cnt <= 3'b0;
		end else if(tx_done) begin
			eth_word_cnt <= 3'b0; 
		end else if(tx_req) begin
			eth_word_cnt <= eth_word_cnt + 3'b1;
		end
	end
	
	always @(posedge eth_tx_clk or negedge rst_n) begin
		if(!rst_n) begin
			tx_data_reg <= 32'b0;
		end else if(tx_req) begin
			case(eth_word_cnt)
				3'd0: tx_data_reg <= {28'b0, wave_select};
				3'd1: tx_data_reg <= {23'b0, amp_ctl};
				3'd2: tx_data_reg <= freq_ctl;
				3'd3: tx_data_reg <= min_ctl;
				3'd4: tx_data_reg <= {20'b0, phase_ctl};
				default: tx_data_reg <= 32'b0;
			endcase
		end
	end
	
	assign tx_data = tx_data_reg;
endmodule