module wave_display (
  input hdmi_pclk,  //hdmi驱动时钟
  input rst_n,      //复位信号

  input [11:0] pixel_xpos,  //像素点横坐标
  input [11:0] pixel_ypos,  //像素点纵坐标

  input [23:0] ui_pixel_data,  //UI像素数据   

  input      [ 7:0] wave_data,      //波形(AD数据)
  output     [11:0] wave_addr,      //显示点数
  input             outrange,
  output            wave_data_req,  //请求波形（AD）数据
  output            wr_over,        //绘制波形完成
  output reg [23:0] pixel_data,     //hdmi像素点数据

  input [9:0] v_shift,   //波形竖直偏移量，bit[9]=0/1:上移/下移 
  input [4:0] v_scale,   //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
  input [7:0] trig_line  //触发电平
);

  //parameter define  

  parameter WAVE_X_START = 12'd50;
  parameter WAVE_X_END = 12'd950;
  parameter WAVE_Y_START = 12'd50;
  parameter WAVE_Y_END = 12'd650;

  localparam WHITE = 24'hFFFFFF;  //RGB888 白色
  localparam BLUE = 24'h0000FF;  //RGB888 蓝色

  //reg define
  reg  [15:0] pre_length;
  reg         outrange_reg;
  reg  [15:0] shift_length;
  reg  [ 9:0] v_shift_t;
  reg  [ 4:0] v_scale_t;
  reg  [11:0] scale_length;
  reg  [ 7:0] trig_line_t;

  //wire define
  wire [15:0] draw_length;

  //*****************************************************
  //**                    main code
  //*****************************************************

  //请求像素数据信号
  assign wave_data_req = ((pixel_xpos >= WAVE_X_START - 12'b1 - 12'b1) && (pixel_xpos < WAVE_X_END - 12'b1 -12'b1)  
                        && (pixel_ypos >= WAVE_Y_START - 12'b1) && (pixel_ypos < WAVE_Y_END)) 
                      ? 1'b1 : 1'b0;

  //根据显示的X坐标计算数据在RAM中的地址
  assign wave_addr = wave_data_req ? (pixel_xpos - (WAVE_X_START - 12'b1 - 12'b1)) : 12'd0;

  //标志一帧波形绘制完毕
  assign wr_over = (pixel_xpos == WAVE_X_END - 12'b1) && (pixel_ypos == WAVE_Y_END);

  //寄存输入的参数
  always @(posedge hdmi_pclk or negedge rst_n) begin
    if (!rst_n) begin
      v_shift_t   <= 10'b0;
      v_scale_t   <= 5'b0;
      trig_line_t <= 8'b0;
    end else begin
      v_shift_t   <= v_shift;
      v_scale_t   <= v_scale;
      trig_line_t <= trig_line;
    end
  end

  //竖直方向上的缩放
  always @(*) begin
    if (v_scale_t[4]) begin  //放大
      scale_length = wave_data * v_scale_t[3:0] - ((12'd128 * v_scale_t[3:0]) - 12'd128);
    end else begin  //缩小
      scale_length = (wave_data >> v_scale_t[3:1]) + (12'd128 - (12'd128 >> v_scale_t[3:1]));
    end
  end

  //对波形进行竖直方向的移动
  always @(*) begin
    if (v_shift_t[9]) begin  //下移
      if (scale_length >= 12'd2048) begin
        shift_length = v_shift_t[8:0] + 16'd20 - (~{4'hf, scale_length} + 16'b1);
      end else begin
        shift_length = scale_length + v_shift_t[8:0] + 16'd20;
      end
    end else begin  //上移
      if (scale_length >= 12'd2048) begin
        shift_length = 16'd0;
      end else if (scale_length + 16'd20 <= v_shift_t[8:0]) begin
        shift_length = 16'd0;
      end else begin
        shift_length = scale_length + 16'd20 - v_shift_t[8:0];
      end
    end
  end

  //处理负数长度
  assign draw_length = shift_length[15] ? 16'd0 : shift_length;

  //寄存前一个像素点的纵坐标，用于各点之间的连线
  always @(posedge hdmi_pclk or negedge rst_n) begin
    if (!rst_n) begin
      pre_length <= 16'd0;
    end else if((pixel_xpos >= WAVE_X_START - 12'b1) && (pixel_xpos < WAVE_X_END - 12'b1) 
    && (pixel_ypos >= WAVE_Y_START - 12'b1) && (pixel_ypos < WAVE_Y_END)) begin
      pre_length <= draw_length;
    end
  end

  //寄存outrange,用于水平方向移动时处理左右边界
  always @(posedge hdmi_pclk or negedge rst_n) begin
    if (!rst_n) begin
      outrange_reg <= 1'b0;
    end else begin
      outrange_reg <= outrange;
    end
  end

  //根据读出的AD值，在屏幕上绘点
  always @(*) begin
    if (outrange_reg || outrange) begin  //超出波形显示范围
      pixel_data = ui_pixel_data;  //显示UI波形
    end else if((pixel_xpos > WAVE_X_START -12'b1) && (pixel_xpos < WAVE_X_END - 12'b1) &&   //坐标点在波形显示范围内 
      (pixel_ypos >= WAVE_Y_START - 12'b1) && (pixel_ypos < WAVE_Y_END)) begin
      if(((pixel_ypos >= pre_length) && (pixel_ypos <= draw_length))
                   ||((pixel_ypos <= pre_length)&&(pixel_ypos >= draw_length))) begin
        pixel_data = WHITE;  //显示波形
      end else if (pixel_ypos == trig_line_t) begin  //显示触发线
        pixel_data = BLUE;
      end else begin
        pixel_data = ui_pixel_data;
      end
    end else begin
      pixel_data = ui_pixel_data;
    end
  end

endmodule
