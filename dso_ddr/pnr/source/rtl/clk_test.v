//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           clk_test
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        clk_test
//
//----------------------------------------------------------------------------------------
//****************************************************************************************///

module clk_test(
     input        clk_in     ,                 // 输入时钟
     input        rst_n      ,                 // 复位信号

     output  reg  clk_out                      // 输出时钟
);
//paramater define
parameter       DIV_N = 26'd100;
//reg define
reg [25:0] cnt;                                 // 时钟分频计数

//*****************************************************
//**                    main code
//*****************************************************

//时钟分频，生成500KHz的测试时钟
always @(posedge clk_in or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        cnt     <= 0;
        clk_out <= 0;
    end
    else begin
        if(cnt == DIV_N/2 - 1'b1) begin
            cnt     <= 26'd0;
            clk_out <= ~clk_out;
        end
        else
            cnt <= cnt + 1'b1;
    end
end

endmodule