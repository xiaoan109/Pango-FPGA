`define TRIGGER
module ad9280_sample (
  input         ad_clk,
  input         rst_n,
  input  [ 7:0] ad_data,
  input         deci_valid  /* synthesis PAP_MARK_DEBUG="true" */,
  input         wave_run  /* synthesis PAP_MARK_DEBUG="true" */,
  input  [ 7:0] trig_level,
  input         trig_edge,
  output        ad_buf_wr  /* synthesis PAP_MARK_DEBUG="true" */,
  output [11:0] ad_buf_addr,
  output [ 7:0] ad_buf_data
);

  //`define TRIGGER

  localparam S_IDLE = 0;
  localparam S_SAMPLE = 1;
  localparam S_WAIT = 2;

  reg buf_wr;
  reg [7:0] ad_data_d0;
  reg [10:0] sample_cnt  /* synthesis PAP_MARK_DEBUG="true" */;
  reg [31:0] wait_cnt;
  reg [2:0] state  /* synthesis PAP_MARK_DEBUG="true" */;

  wire trig_pulse;
  assign ad_buf_addr = sample_cnt;
  assign ad_buf_data = ad_data;

  assign trig_pulse = trig_edge ? (ad_data_d0 < trig_level && ad_data >= trig_level) : (ad_data_d0 > trig_level && ad_data <= trig_level) ;

  always @(posedge ad_clk or negedge rst_n) begin
    if (rst_n == 1'b0) ad_data_d0 <= 8'd0;
    else ad_data_d0 <= ad_data;
  end
  always @(posedge ad_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
      state <= S_IDLE;
      wait_cnt <= 32'd0;
      sample_cnt <= 11'd0;
      buf_wr <= 1'b0;
    end else
      case (state)
        S_IDLE: begin
          state <= S_SAMPLE;
        end
        S_SAMPLE: begin
          if (sample_cnt == 11'd1023 && wave_run) begin
            sample_cnt <= 11'd0;
            buf_wr <= 1'b0;
            state <= S_WAIT;
          end else if (deci_valid) begin
            sample_cnt <= sample_cnt + 11'd1;
            buf_wr <= 1'b1;
          end
        end
        S_WAIT: begin
`ifdef TRIGGER
          if (deci_valid && trig_pulse) state <= S_SAMPLE;
`else
          if (wait_cnt == 32'd33_670_033) begin
            state <= S_SAMPLE;
            wait_cnt <= 32'd0;
          end else begin
            wait_cnt <= wait_cnt + 32'd1;
          end
`endif
        end
        default: state <= S_IDLE;
      endcase
  end

  assign ad_buf_wr = buf_wr && wave_run;

endmodule
