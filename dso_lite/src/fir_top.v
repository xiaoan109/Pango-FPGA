/***********************************************************
>> V201001 : Fs：29.7Mhz, fstop：1Mhz-6Mhz, order： 15
************************************************************/
`define SAFE_DESIGN

module fir_top (
  input         rstn,   //复位，低有效
  input         clk,    //工作频率，即采样频率
  input         en,     //输入数据有效信号
  input  [ 7:0] xin,    //输入混合频率的信号数据
  output        valid,  //输出数据有效信号
  output [19:0] yout    //输出数据，低频信号，即250KHz
);

  // parameter EDGE_THRESHOLD = 128;
  // // 定义窗口长度参数
  // parameter EDGE_WINDOW = 5;

  //data en delay 
  reg [3:0] en_r;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      en_r[3:0] <= 'b0;
    end else begin
      en_r[3:0] <= {en_r[2:0], en};
    end
  end

  //(1) 16 组移位寄存器
  reg [7:0] xin_reg[15:0];
  reg [3:0] i, j;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (i = 0; i < 15; i = i + 1) begin
        xin_reg[i] <= 12'b0;
      end
    end else if (en) begin
      xin_reg[0] <= xin;
      for (j = 0; j < 15; j = j + 1) begin
        xin_reg[j+1] <= xin_reg[j];  //周期性移位操作
      end
    end
  end

  //Only 8 multipliers needed because of the symmetry of FIR filter coefficient
  //(2) 系数对称，16个移位寄存器数据进行首位相加
  reg [8:0] add_reg[7:0];
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (i = 0; i < 8; i = i + 1) begin
        add_reg[i] <= 13'd0;
      end
    end else if (en_r[0]) begin
      for (i = 0; i < 8; i = i + 1) begin
        add_reg[i] <= xin_reg[i] + xin_reg[15-i];
      end
    end
  end

  //(3) 8个乘法器
  // 滤波器系数，已经过一定倍数的放大
  wire [7:0] coe[7:0];
  //   assign coe[0] = 12'd11;
  //   assign coe[1] = 12'd31;
  //   assign coe[2] = 12'd63;
  //   assign coe[3] = 12'd104;
  //   assign coe[4] = 12'd152;
  //   assign coe[5] = 12'd198;
  //   assign coe[6] = 12'd235;
  //   assign coe[7] = 12'd255;
  assign coe[0] = -8'd1;
  assign coe[1] = -8'd2;
  assign coe[2] = -8'd3;
  assign coe[3] = -8'd1;
  assign coe[4] = 8'd4;
  assign coe[5] = 8'd13;
  assign coe[6] = 8'd23;
  assign coe[7] = 8'd30;


`ifdef SAFE_DESIGN
  wire [16:0] mout       [7:0];
  //流水线式乘法器
  wire [ 7:0] valid_mult;
  genvar k;
  generate
    for (k = 0; k < 8; k = k + 1) begin
      mult_man #(9, 8) u_mult_paral (
        .clk     (clk),
        .rstn    (rstn),
        .data_rdy(en_r[1]),
        .mult1   (add_reg[k]),
        .mult2   (coe[k]),
        .res_rdy (valid_mult[k]),  //所有输出使能完全一致  
        .res     (mout[k])
      );
    end
  endgenerate
  wire valid_mult7 = valid_mult[7];

`else
  reg [16:0] mout[7:0];
  //如果对时序要求不高，可以直接用乘号
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      for (i = 0; i < 8; i = i + 1) begin
        mout[i] <= 25'b0;
      end
    end else if (en_r[1]) begin
      for (i = 0; i < 8; i = i + 1) begin
        mout[i] <= coe[i] * add_reg[i];
      end
    end
  end
  wire valid_mult7 = en_r[2];
`endif

  //(4) 积分累加，8组25bit数据 -> 1组 29bit 数据
  //数据有效延时
  reg [3:0] valid_mult_r;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      valid_mult_r[3:0] <= 'b0;
    end else begin
      valid_mult_r[3:0] <= {valid_mult_r[2:0], valid_mult7};
    end
  end

`ifdef SAFE_DESIGN
  //加法运算时，分多个周期进行流水，优化时序
  reg [18:0] sum1;
  reg [18:0] sum2;
  reg [19:0] yout_t;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      sum1   <= 19'd0;
      sum2   <= 19'd0;
      yout_t <= 19'd0;
    end else if (valid_mult7) begin
      sum1   <= mout[0] + mout[1] + mout[2] + mout[3];
      sum2   <= mout[4] + mout[5] + mout[6] + mout[7];
      yout_t <= sum1 + sum2;
    end
  end

`else
  //一步计算累加结果，但是实际中时序非常危险
  reg signed [18:0] sum;
  reg signed [19:0] yout_t;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      sum    <= 19'd0 ;
      yout_t <= 19'd0 ;
    end else if (valid_mult7) begin
      sum    <= mout[0] + mout[1] + mout[2] + mout[3] + mout[4] + mout[5] + mout[6] + mout[7];
      yout_t <= sum ;
    end
  end
`endif
  assign yout  = yout_t;
  assign valid = valid_mult_r[0];


  // hard to implement on board. Real DAC can not change from 255 to 0 (or vice versa) immediately...

  // // 定义一个边缘检测模块
  // reg [7:0] xin_prev  /* synthesis PAP_MARK_DEBUG="true" */;
  // wire edge_detected  /* synthesis PAP_MARK_DEBUG="true" */;
  // reg [EDGE_WINDOW-1:0] edge_window;  // 用于生成边沿窗口
  // wire [16:0] xin_div;

  // always @(posedge clk or negedge rstn) begin
  //   if (!rstn) begin
  //     xin_prev <= 8'b0;
  //   end else if (en) begin
  //     xin_prev <= xin;  // 保存上一个输入信号值
  //   end
  // end


  // // 边沿窗口生成：在检测到边沿后，维持窗口打开 EDGE_WINDOW 个周期
  // always @(posedge clk or negedge rstn) begin
  //   if (!rstn) begin
  //     edge_window <= 'b0;
  //   end else if (edge_detected) begin
  //     edge_window <= {EDGE_WINDOW{1'b1}};  // 打开窗口
  //   end else if (edge_window != 0) begin
  //     edge_window <= edge_window - 1'b1;  // 递减窗口计数
  //   end
  // end

  // // 检测输入信号的边缘
  // assign edge_detected = (en && (xin > xin_prev ? xin - xin_prev : xin_prev - xin) > EDGE_THRESHOLD);// EDGE_THRESHOLD 是自定义的跳变阈值

  // // 使用边沿窗口控制 MUX
  // assign yout = (edge_window >= 6 && edge_window <= 20) ? {xin_reg[14-(edge_window-6)]>>1, 12'b0} : yout_t;  // 边沿窗口期间输出原始输入

  // fxp_div #(
  //   .WIIA (9),  //sign bit=0
  //   .WIFA (8),
  //   .WIIB (9),  //sign bit=0
  //   .WIFB (8),
  //   .WOI  (9),  //sign bit=0
  //   .WOF  (8),
  //   .ROUND(1)
  // ) u_fxp_div (
  //   .dividend({1'b0, xin_reg[14-(edge_window-6)], 8'b0}),
  //   .divisor ({1'b0, 16'd484}),                            //1.8888..*256 = 484
  //   .out     (xin_div),
  //   .overflow()
  // );

endmodule
