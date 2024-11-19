module fft_adc_top (
  input wire sys_clk,   //ad_clk
  input wire sys_rst_n,

  input wire [7:0] ad_data,
  input wire       deci_valid,
  input wire       fft_en  /* synthesis PAP_MARK_DEBUG="true" */,

  input wire rd_clk,
  input wire [9:0] rd_addr  /* synthesis PAP_MARK_DEBUG="true" */,
  output wire [11:0] ram_rd_data  /* synthesis PAP_MARK_DEBUG="true" */
);


  localparam CLKDIV = ("FALSE" == "TRUE") ? 3 : 1;

  localparam FFT_ARCH = ("Pipeline" == "Radix-2 Burst") ? 1 : 0;

  localparam  LOG2_FFT_LEN      = ("1024" == "8"    ) ? 3  :
                              ("1024" == "16"   ) ? 4  :
                              ("1024" == "32"   ) ? 5  :
                              ("1024" == "64"   ) ? 6  :
                              ("1024" == "128"  ) ? 7  :
                              ("1024" == "256"  ) ? 8  :
                              ("1024" == "512"  ) ? 9  :
                              ("1024" == "1024" ) ? 10 :
                              ("1024" == "2048" ) ? 11 :
                              ("1024" == "4096" ) ? 12 :
                              ("1024" == "8192" ) ? 13 :
                              ("1024" == "16384") ? 14 :
                              ("1024" == "32768") ? 15 :
                                                  16 ;

  function integer clog2;
    input integer n;
    begin
      n = n - 1;
      for (clog2 = 0; n > 0; clog2 = clog2 + 1) n = n >> 1;
    end
  endfunction

  localparam MAX_TIME_OF_FFT = (FFT_ARCH == 1) ? (LOG2_FFT_LEN + clog2(
    LOG2_FFT_LEN
  ) + 1) : (LOG2_FFT_LEN + 2);


  localparam OUTPUT_ORDER = ("Natural Order" == "Natural Order") ? 1 : 0;

  localparam SCALE_MODE = ("Unscaled" == "Block Floating Point") ? 1 : 0;
  localparam INPUT_WIDTH = 16;


  localparam DATAIN_BYTE_NUM = ((INPUT_WIDTH % 8) == 0) ? INPUT_WIDTH / 8 : INPUT_WIDTH / 8 + 1;
  localparam DATAIN_WIDTH = DATAIN_BYTE_NUM * 8;
  localparam UNSCALED_WIDTH = INPUT_WIDTH + LOG2_FFT_LEN + 1;
  localparam OUTPUT_WIDTH = SCALE_MODE ? INPUT_WIDTH : UNSCALED_WIDTH;
  localparam DATAOUT_BYTE_NUM = ((OUTPUT_WIDTH % 8) == 0) ? OUTPUT_WIDTH / 8 : OUTPUT_WIDTH / 8 + 1;
  localparam DATAOUT_WIDTH = DATAOUT_BYTE_NUM * 8;
  localparam  USER_BYTE_NUM     = ((LOG2_FFT_LEN%8)==0) ? LOG2_FFT_LEN/8 + 1: LOG2_FFT_LEN/8 + 2; // blk_exp and index
  localparam USER_WIDTH = USER_BYTE_NUM * 8;

  localparam FIFO_RST_CNT_MAX = 10;  //TODO: fifo rst cnt

  localparam ADC_DATA_WIDTH = 8;


  wire                       aclken;
  reg                        xn_axi4s_data_tvalid;
  wire [ DATAIN_WIDTH*2-1:0] xn_axi4s_data_tdata;
  reg                        xn_axi4s_data_tlast;
  wire                       xn_axi4s_data_tready;
  reg                        xn_axi4s_cfg_tvalid;
  wire                       xn_axi4s_cfg_tdata;
  wire                       xk_axi4s_data_tvalid;
  wire [DATAOUT_WIDTH*2-1:0] xk_axi4s_data_tdata;
  wire                       xk_axi4s_data_tlast;
  wire [     USER_WIDTH-1:0] xk_axi4s_data_tuser;
  wire [                2:0] alm;
  wire                       stat;

  wire                       srstn;

  reg  [                2:0] start_test_dly;
  wire                       start_test_pulse;
  reg                        fft_run;
  wire                       fft_stop;
  reg                        fft_mode;
  reg  [   LOG2_FFT_LEN-1:0] data_cnt = {LOG2_FFT_LEN{1'b0}};  // supports no reset
  reg  [    INPUT_WIDTH-1:0] data_re = {{(INPUT_WIDTH - 1) {1'b0}}, 1'b1};  // supports no reset
  reg  [    INPUT_WIDTH-1:0] data_im = {{(INPUT_WIDTH - 1) {1'b1}}, 1'b0};  // supports no reset
  wire                       wr_en;
  wire [                7:0] wr_data;
  wire                       wr_full;
  wire                       almost_full;
  wire                       rd_en;
  wire                       rd_empty;
  wire                       almost_empty;
  wire [                7:0] rd_data;
  reg  [                3:0] rst_cnt;  //TODO: fifo rst cnt

  wire [  DATAOUT_WIDTH-1:0] out_re;
  wire [  DATAOUT_WIDTH-1:0] out_im;
  reg  [  DATAOUT_WIDTH-1:0] ori_re;
  reg  [  DATAOUT_WIDTH-1:0] ori_im;
  reg  [DATAOUT_WIDTH*2-1:0] sum_data;

  wire [  DATAOUT_WIDTH-1:0] sqrt_data;

  reg  [DATAOUT_WIDTH+3-1:0] data_valid_dly;  // 1 + 1+ 32 + 1

  wire                       fft_data_valid;

  reg  [                9:0] wr_addr;
  wire [               11:0] ram_wr_data;

  assign aclken = 1'b1;

  ipsxe_fft_sync_arstn u_sync_arstn (
    .i_clk          (sys_clk),
    .i_arstn_presync(sys_rst_n),
    .o_arstn_synced (srstn)
  );

  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) start_test_dly <= 3'b111;
    else if (aclken) start_test_dly <= {start_test_dly[1:0], fft_en && wr_full};
  end

  assign start_test_pulse = start_test_dly[1] && ~start_test_dly[2];

  assign data_gen_en = xn_axi4s_data_tvalid && xn_axi4s_data_tready;
  assign fft_stop = !(fft_en && wr_full) && data_gen_en && xn_axi4s_data_tlast;

  // ----------------------------------------------------------------------------
  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) fft_run <= 1'b0;
    else if (aclken) begin
      if (start_test_pulse) fft_run <= 1'b1;
      else if (fft_stop) fft_run <= 1'b0;
    end
  end

  // configs fft
  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) fft_mode <= 1'b1;
    else if (aclken) begin
      if (start_test_pulse) fft_mode <= 1'b1;
    end
  end

  assign xn_axi4s_cfg_tdata = fft_mode;

  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) xn_axi4s_cfg_tvalid <= 1'b0;
    else if (aclken) begin
      if (xn_axi4s_cfg_tvalid) xn_axi4s_cfg_tvalid <= 1'b0;
      else if (start_test_pulse) xn_axi4s_cfg_tvalid <= 1'b1;
      else xn_axi4s_cfg_tvalid <= 1'b0;
    end
  end


  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) data_cnt <= {LOG2_FFT_LEN{1'b0}};
    else if (aclken) begin
      if (start_test_pulse) data_cnt <= {LOG2_FFT_LEN{1'b0}};
      else if (data_gen_en) begin
        data_cnt <= data_cnt + 1'b1;
      end
    end
  end


  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) xn_axi4s_data_tvalid <= 1'b0;
    else if (aclken) begin
      if (start_test_pulse) xn_axi4s_data_tvalid <= 1'b0;
      else if (xn_axi4s_data_tready && fft_run && !fft_stop)  // wait ending of first configuration
        xn_axi4s_data_tvalid <= 1'b1;
      else if (xn_axi4s_data_tready && xn_axi4s_data_tlast) xn_axi4s_data_tvalid <= 1'b0;
    end
  end


  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) xn_axi4s_data_tlast <= 1'b0;
    else if (aclken) begin
      if (data_gen_en) begin
        if (data_cnt == {{(LOG2_FFT_LEN - 1) {1'b1}}, 1'b0}) xn_axi4s_data_tlast <= 1'b1;
        else xn_axi4s_data_tlast <= 1'b0;
      end
    end
  end

  fifo1024x8 u_fifo1024x8 (
    .clk         (sys_clk),      // input
    .rst         (!srstn),       // input
    .wr_en       (wr_en),        // input
    .wr_data     (wr_data),      // input [7:0]
    .wr_full     (wr_full),      // output
    .almost_full (almost_full),  // output
    .rd_en       (rd_en),        // input
    .rd_data     (rd_data),      // output [7:0]
    .rd_empty    (rd_empty),     // output
    .almost_empty(almost_empty)  // output
  );

  assign wr_en   = deci_valid && !wr_full;
  assign wr_data = ad_data;
  assign rd_en   = fft_run && !fft_stop && !rd_empty;


  //   always @(posedge sys_clk or negedge srstn) begin
  //     if (!srstn) begin
  //       data_re <= {{(INPUT_WIDTH - 1) {1'b0}}, 1'b1};
  //       data_im <= {{(INPUT_WIDTH - 1) {1'b1}}, 1'b0};
  //     end else if (aclken) begin
  //       if (data_gen_en) begin
  //         if (xn_axi4s_data_tlast) begin
  //           data_re <= {{(INPUT_WIDTH - 1) {1'b0}}, 1'b1};
  //           data_im <= {{(INPUT_WIDTH - 1) {1'b1}}, 1'b0};
  //         end else begin
  //           data_re <= {data_re[INPUT_WIDTH-2:0], (data_re[INPUT_WIDTH-1] ^ data_re[0])};
  //           data_im <= {data_im[INPUT_WIDTH-2:0], (data_im[INPUT_WIDTH-1] ^ data_im[0])};
  //         end
  //       end
  //     end
  //   end

  always @(*) begin
    data_re = {8'b0, rd_data};
    data_im = 16'b0;
  end

  generate
    if (DATAIN_WIDTH == INPUT_WIDTH) begin : no_bit_ext
      assign xn_axi4s_data_tdata[DATAIN_WIDTH-1:0] = data_re;
      assign xn_axi4s_data_tdata[DATAIN_WIDTH*2-1:DATAIN_WIDTH] = data_im;
    end else begin : en_bit_ext
      assign xn_axi4s_data_tdata[DATAIN_WIDTH-1:0] = {
        {(DATAIN_WIDTH - INPUT_WIDTH) {data_re[INPUT_WIDTH-1]}}, data_re
      };
      assign xn_axi4s_data_tdata[DATAIN_WIDTH*2-1:DATAIN_WIDTH] = {
        {(DATAIN_WIDTH - INPUT_WIDTH) {data_im[INPUT_WIDTH-1]}}, data_im
      };
    end
  endgenerate



  ipsxb_fft_demo_pp_1024 u_fft_wrapper (
    .i_aclk(sys_clk),

    .i_axi4s_data_tvalid(xn_axi4s_data_tvalid),
    .i_axi4s_data_tdata (xn_axi4s_data_tdata),
    .i_axi4s_data_tlast (xn_axi4s_data_tlast),
    .o_axi4s_data_tready(xn_axi4s_data_tready),
    .i_axi4s_cfg_tvalid (xn_axi4s_cfg_tvalid),
    .i_axi4s_cfg_tdata  (xn_axi4s_cfg_tdata),
    .o_axi4s_data_tvalid(xk_axi4s_data_tvalid),
    .o_axi4s_data_tdata (xk_axi4s_data_tdata),
    .o_axi4s_data_tlast (xk_axi4s_data_tlast),
    .o_axi4s_data_tuser (xk_axi4s_data_tuser),
    .o_alm              (alm),
    .o_stat             (stat)
  );


  assign out_re = xk_axi4s_data_tdata[DATAOUT_WIDTH-1:0];
  assign out_im = xk_axi4s_data_tdata[DATAOUT_WIDTH*2-1:DATAOUT_WIDTH];

  always @(posedge sys_clk) begin
    if (aclken) begin
      if (xk_axi4s_data_tvalid) begin
        if (out_re[DATAOUT_WIDTH-1] == 1'b0) begin
          ori_re <= out_re;
        end else begin
          ori_re <= ~out_re + 1'b1;
        end
        if (out_im[DATAOUT_WIDTH-1] == 1'b0) begin
          ori_im <= out_im;
        end else begin
          ori_im <= ~out_im + 1'b1;
        end
      end
      sum_data <= ori_re * ori_re + ori_im * ori_im;
    end
  end


  isqrt_dbd #(
    .DATA_WIDTH(DATAOUT_WIDTH * 2)
  ) u_isqrt (
    .clk(sys_clk),
    .data(sum_data),
    .q(sqrt_data)
  );

  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) data_valid_dly <= {(DATAOUT_WIDTH + 3) {1'b0}};
    else if (aclken) data_valid_dly <= {data_valid_dly[DATAOUT_WIDTH+3-2:0], xk_axi4s_data_tvalid};
  end


  assign fft_data_valid = data_valid_dly[DATAOUT_WIDTH+3-1];


  always @(posedge sys_clk or negedge srstn) begin
    if (!srstn) begin
      wr_addr <= 10'b0;
    end else if (fft_data_valid) begin
      wr_addr <= wr_addr + 1'b1;
    end
  end

  assign ram_wr_data = sqrt_data[(ADC_DATA_WIDTH+LOG2_FFT_LEN-1)-:12];

  ram1024x12 u_ram1024x12 (
    .wr_data(ram_wr_data),     // input [11:0]
    .wr_addr(wr_addr),         // input [9:0]
    .wr_en  (fft_data_valid),  // input
    .wr_clk (sys_clk),         // input
    .wr_rst (!srstn),          // input
    .rd_addr(rd_addr),         // input [9:0]
    .rd_data(ram_rd_data),     // output [11:0]
    .rd_clk (rd_clk),          // input
    .rd_rst (!srstn)           // input
  );

endmodule
