`timescale 1ns/1ns
`include "defines.v"
module tb_soc(); 

`define CorePath inst_sparrow_soc.inst_core


//测试DUT信号
logic clk;//时钟信号
logic randem;//产生异步信号
logic rst_n;//复位
logic core_ex_trap_valid, core_ex_trap_ready;//外部中断线
logic JTAG_TCK,JTAG_TMS,JTAG_TDI,JTAG_TDO;//jtag
wire sd_clk,sd_cmd,sd_dat;//sd卡
wire [2:0]sd_dat123;//sd卡上拉线
wire [`FPIOA_PORT_NUM-1:0]fpioa;

//仿真显示信号
logic [63:0] sim_cycle_cnt = '0;//仿真周期计数器
localparam sim_printf_line_length = 64;//显示printf的最大单行字符数
int sim_printf_p = sim_printf_line_length;//仿真csr printf的显示终端指针
logic [7:0] sim_printf_ascii = '0;//仿真csr printf的字符
logic [sim_printf_line_length*8-1:0] sim_printf_line = '0;//仿真csr printf的显示终端，和处理器运行状态同步

//assign fpioa[3:2] = 0;

assign fpioa[1]=randem;

wire uart0_tx=fpioa[0];//fpioa[1]

//测试信号
assign fpioa[7] = 1'b1;

integer r;//计数工具人
//寄存器监测
wire [31:0] x3  = `CorePath.inst_regs.regs[3];
`ifndef RV32E_BASE_ISA
wire [31:0] x26 = `CorePath.inst_regs.regs[26];
wire [31:0] x27 = `CorePath.inst_regs.regs[27];
`endif
wire mends = `CorePath.inst_csr.mends;//仿真结束标志

// 读入程序
initial begin
    for(r=0; r<`IRamSize; r=r+1) begin//先填充0
        `CorePath.inst_iram.inst_appram.BRAM[r] = 32'h0;
    end
    $readmemh ("inst.txt", `CorePath.inst_iram.inst_appram.BRAM);//把程序(inst.txt)写进去
/*
    `CorePath.inst_iram.inst_appram.BRAM[0] = 32'h000027b7;
    `CorePath.inst_iram.inst_appram.BRAM[1] = 32'h00078067;//无启动文件，跳转至0x2000
    $readmemh ("btrm.txt", `CorePath.inst_iram.inst_appram.BRAM,0,(8192/4)-1);
    $readmemh ("inst.txt", `CorePath.inst_iram.inst_appram.BRAM,(8192/4));
*/

end

// 生成clk
initial begin
    clk = '0;
    forever #(5) clk = ~clk;
end

// 生成异步信号
initial begin
    randem = '0;
    forever #(61) randem = ~randem;
end

//仿真周期计数
always @(posedge clk) 
    sim_cycle_cnt <= sim_cycle_cnt+1;



//启动仿真流程
initial begin
    sysrst();//复位系统
    #10;
`ifdef ISA_TEST  //通过宏定义，控制是否是指令集测试程序
    wait(x26 == 32'b1);   // x26 == 1，结束仿真
    @(posedge clk);//等3个周期
    @(posedge clk);
    @(posedge clk);
    if (x27 == 32'b1) begin
    $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
    $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
    $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
    $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
    $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
    $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end else begin
    $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("fail testnum = %2d", x3);
    for (r = 1; r < 32; r = r + 1)
        $display("x%2d = 0x%x", r, `CorePath.inst_regs.regs[r]);
    end
    $stop;//结束
`else //不测ISA，做其他事
    ex_trap();//测试外部中断
`endif
end

initial begin//超时强制结束
`ifndef MODELSIM
    #600000;//iverilog
`else 
    #3000000;//modeslsim速度快，长一个数量级
`endif
`ifdef ISA_TEST
    $display("*Sim tool:ISA_TEST Timeout, Err");//ISA测试超时
    $display("*Sim tool:Sim cycle = %d", sim_cycle_cnt);
`else 
    $display("*Sim tool:Normal Sim Timeout");//普通仿真超时
    $display("*Sim tool:Sim cycle = %d", sim_cycle_cnt);
`endif
    $stop;
end

initial begin
    #30;
    wait(mends === 1'b1)//软件控制仿真结束
    $display("*Sim tool:CSR MENDS END, stop sim");
    $display("*Sim tool:Sim cycle = %d", sim_cycle_cnt);
    #10;
    $stop;
end

task sysrst;//复位任务
    core_ex_trap_valid=0;//关闭外部中断线
    JTAG_TCK=0;//JTAG不工作
    JTAG_TMS=0;
    JTAG_TDI=0;
    rst_n <= '0;//复位
    #20
    rst_n <= '1;
    #10;

endtask : sysrst

task ex_trap;//外部中断
    #15000;
    core_ex_trap_valid=1;//使能外部中断线
    #30;
    wait(core_ex_trap_ready);//等待响应
    core_ex_trap_valid=0;//取消信号
endtask : ex_trap


genvar i;//计数工具人
generate
    for ( i=0; i<`FPIOA_PORT_NUM ; i++) begin//fpioa信号弱下拉，防止出现不定态
        assign (weak1,weak0) fpioa[i] = 1'b0;
    end
endgenerate

//显示printf单行内容，遇到转义符n r则刷新
always @(posedge clk) begin
    if(`CorePath.inst_csr.printf_valid) begin
        sim_printf_ascii = `CorePath.inst_csr.idex_csr_wdata_i[7:0];//读取printf的内容
        if(sim_printf_ascii==8'h0A || sim_printf_ascii==8'h0D) begin
            sim_printf_p = sim_printf_line_length;
            sim_printf_line = '0;
        end
        else begin
            for (int printf_bitp = 0; printf_bitp < 8; printf_bitp=printf_bitp+1) begin
                sim_printf_line[(sim_printf_p-1)*8+printf_bitp] = sim_printf_ascii[printf_bitp];
            end
            sim_printf_p = sim_printf_p-1;
        end
    end 
end

initial begin
    wait(rst_n===1'b1);
    if(`CorePath.inst_iram.inst_appram.BRAM[0]==32'h0) begin//如果inst.txt读入失败，停止仿真
        $display("*Sim tool:Inst load error");
        #10;
        $stop;
    end
end
sparrow_soc inst_sparrow_soc (
    .clk               (clk), 
    .hard_rst_n        (rst_n), 
    .core_active       (),
`ifdef JTAG_DBG_MODULE
    .JTAG_TCK          (JTAG_TCK),
    .JTAG_TMS          (JTAG_TMS),
    .JTAG_TDI          (JTAG_TDI),
    .JTAG_TDO          (JTAG_TDO),
`endif
    .sd_clk            (sd_clk),
    .sd_cmd            (sd_cmd),
    .sd_dat            ({sd_dat123,sd_dat}),
    .fpioa             (fpioa)//处理器IO接口
);

`ifndef ISA_TEST
sd_fake inst_sd_fake
(
    .rstn_async       (rst_n),
    .sdclk            (sd_clk),
    .sdcmd            (sd_cmd),
    .sddat            ({sd_dat123, sd_dat}),
    .show_status_bits (),
    .show_sdcmd_en    (),
    .show_sdcmd_cmd   (),
    .show_sdcmd_arg   ()
);
`endif

//输出波形
initial begin
    $dumpfile("tb.vcd");  //生成lxt的文件名称
    $dumpvars(0,tb_soc);   //tb中实例化的仿真目标实例名称   
end


endmodule