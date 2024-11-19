module icb_ddr (
	input  wire 					clk,
	input  wire 					rst_n,
	    //s5
    input  wire                 	s_icb_cmd_valid,
    output wire                		s_icb_cmd_ready,
    input  wire [31:0]          	s_icb_cmd_addr ,
    input  wire                 	s_icb_cmd_read ,
    input  wire [31:0]          	s_icb_cmd_wdata,
    input  wire [3:0]           	s_icb_cmd_wmask,
    output wire                		s_icb_rsp_valid,
    input  wire                 	s_icb_rsp_ready,
    output wire                		s_icb_rsp_err  ,
    output wire [31:0]         		s_icb_rsp_rdata,
	//axi bus   
    input  wire                     axi_clk        ,
    input  wire                     axi_rst_n      ,

	output wire [28-1:0]        	axi_awaddr     ,
	output wire                     axi_awuser_ap  ,
	output wire [3:0]               axi_awuser_id  ,
	output wire [3:0]               axi_awlen      ,
	input  wire                     axi_awready    ,
	output wire                     axi_awvalid    ,

	output wire [32*8-1:0]         	axi_wdata      ,
	output wire [32-1:0]           	axi_wstrb      ,
	input  wire                     axi_wready     ,
	input  wire [3:0]               axi_wusero_id  ,
	input  wire                     axi_wusero_last,

	output wire [28-1:0]        	axi_araddr     ,
	output wire                     axi_aruser_ap  ,
	output wire [3:0]               axi_aruser_id  ,
	output wire [3:0]               axi_arlen      ,
	input  wire                     axi_arready    ,
	output wire                     axi_arvalid    ,

	input  wire[8*32-1:0]        	axi_rdata      ,
	input  wire[3:0]                axi_rid        ,
	input  wire                     axi_rlast      ,
	input  wire                     axi_rvalid     
);


reg icb_rsp_valid;
reg [31:0] icb_rsp_rdata;

wire icb_cmd = s_icb_cmd_valid&s_icb_cmd_ready;
wire icb_read = icb_cmd&s_icb_cmd_read;
wire icb_write = icb_cmd&(~s_icb_cmd_read);
wire [7:2] icb_addr = s_icb_cmd_addr[7:2];
wire [31:0] icb_wdata = s_icb_cmd_wdata;

reg [28-1:0] waddr,raddr;
reg [255:0] wdata,rdata;
reg [1:0] ctrl,state;


localparam ADDR_CTRL    = 6'd0;
localparam ADDR_STATE   = 6'd1;
localparam ADDR_WDATA0  = 6'd2;
localparam ADDR_WDATA1  = 6'd3;
localparam ADDR_WDATA2  = 6'd4;
localparam ADDR_WDATA3  = 6'd5;
localparam ADDR_WDATA4  = 6'd6;
localparam ADDR_WDATA5  = 6'd7;
localparam ADDR_WDATA6  = 6'd8;
localparam ADDR_WDATA7  = 6'd9;
localparam ADDR_WADDR   = 6'd10;
localparam ADDR_RDATA0  = 6'd11;
localparam ADDR_RDATA1  = 6'd12;
localparam ADDR_RDATA2  = 6'd13;
localparam ADDR_RDATA3  = 6'd14;
localparam ADDR_RDATA4  = 6'd15;
localparam ADDR_RDATA5  = 6'd16;
localparam ADDR_RDATA6  = 6'd17;
localparam ADDR_RDATA7  = 6'd18;
localparam ADDR_RADDR   = 6'd19;
// localparam    = 6'd20;
// localparam    = 6'd21;
reg rdone;
reg wdone;

reg wdone_r,wdone_rr,wdone_rrr;
reg rdone_r,rdone_rr,rdone_rrr;
always @(posedge clk) begin
    rdone_r   <= rdone;
    rdone_rr  <= rdone_r;
    rdone_rrr <= rdone_rr;

    wdone_r   <= wdone;
    wdone_rr  <= wdone_r;
    wdone_rrr <= wdone_rr;
end

wire rdone_p = (!rdone_rrr) & rdone_rr;
wire wdone_p = (!wdone_rrr) & wdone_rr;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        waddr <= 'b0;
        raddr <= 'b0;
    end else begin
        if(rdone_p) state[0] <= 1'b1;
        if(wdone_p) state[1] <= 1'b1;
        if(icb_write) begin
            case(icb_addr)
                ADDR_CTRL:      ctrl <= icb_wdata;
                ADDR_STATE:     state <= icb_wdata;
                ADDR_WDATA0:    wdata[0*32+31:0*32] <= icb_wdata;
                ADDR_WDATA1:    wdata[1*32+31:1*32] <= icb_wdata;
                ADDR_WDATA2:    wdata[2*32+31:2*32] <= icb_wdata;
                ADDR_WDATA3:    wdata[3*32+31:3*32] <= icb_wdata;
                ADDR_WDATA4:    wdata[4*32+31:4*32] <= icb_wdata;
                ADDR_WDATA5:    wdata[5*32+31:5*32] <= icb_wdata;
                ADDR_WDATA6:    wdata[6*32+31:6*32] <= icb_wdata;
                ADDR_WDATA7:    wdata[7*32+31:7*32] <= icb_wdata;
                ADDR_WADDR:     waddr <= icb_wdata;
                // ADDR_RDATA0:    rdata[0*32+31:0*32] <= icb_wdata;
                // ADDR_RDATA1:    rdata[1*32+31:1*32] <= icb_wdata;
                // ADDR_RDATA2:    rdata[2*32+31:2*32] <= icb_wdata;
                // ADDR_RDATA3:    rdata[3*32+31:3*32] <= icb_wdata;
                // ADDR_RDATA4:    rdata[4*32+31:4*32] <= icb_wdata;
                // ADDR_RDATA5:    rdata[5*32+31:5*32] <= icb_wdata;
                // ADDR_RDATA6:    rdata[6*32+31:6*32] <= icb_wdata;
                // ADDR_RDATA7:    rdata[7*32+31:7*32] <= icb_wdata;
                ADDR_RADDR:     raddr <= icb_wdata;
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        icb_rsp_valid <= 'b0;
    end else begin
        if(s_icb_rsp_valid&s_icb_rsp_ready) icb_rsp_valid <= 'b0;
        if(icb_read) begin
            icb_rsp_valid <= 'b1;
            case(icb_addr)

                ADDR_CTRL:      icb_rsp_rdata <= ctrl;
                ADDR_STATE:     icb_rsp_rdata <= state;
                ADDR_WDATA0:    icb_rsp_rdata <= wdata[0*32+31:0*32] ;
                ADDR_WDATA1:    icb_rsp_rdata <= wdata[1*32+31:1*32] ;
                ADDR_WDATA2:    icb_rsp_rdata <= wdata[2*32+31:2*32] ;
                ADDR_WDATA3:    icb_rsp_rdata <= wdata[3*32+31:3*32] ;
                ADDR_WDATA4:    icb_rsp_rdata <= wdata[4*32+31:4*32] ;
                ADDR_WDATA5:    icb_rsp_rdata <= wdata[5*32+31:5*32] ;
                ADDR_WDATA6:    icb_rsp_rdata <= wdata[6*32+31:6*32] ;
                ADDR_WDATA7:    icb_rsp_rdata <= wdata[7*32+31:7*32] ;
                ADDR_WADDR:     icb_rsp_rdata <= waddr;

                ADDR_RDATA0:    icb_rsp_rdata <= rdata[0*32+31:0*32] ;
                ADDR_RDATA1:    icb_rsp_rdata <= rdata[1*32+31:1*32] ;
                ADDR_RDATA2:    icb_rsp_rdata <= rdata[2*32+31:2*32] ;
                ADDR_RDATA3:    icb_rsp_rdata <= rdata[3*32+31:3*32] ;
                ADDR_RDATA4:    icb_rsp_rdata <= rdata[4*32+31:4*32] ;
                ADDR_RDATA5:    icb_rsp_rdata <= rdata[5*32+31:5*32] ;
                ADDR_RDATA6:    icb_rsp_rdata <= rdata[6*32+31:6*32] ;
                ADDR_RDATA7:    icb_rsp_rdata <= rdata[7*32+31:7*32] ;
                ADDR_RADDR:     icb_rsp_rdata <= raddr;
            endcase
        end
    end
end
assign s_icb_cmd_ready = 1'b1;
assign s_icb_rsp_valid = icb_rsp_valid;
assign s_icb_rsp_err = 1'b0;
assign s_icb_rsp_rdata = icb_rsp_rdata;

reg [1:0] ctrl_r,ctrl_rr,ctrl_rrr;

wire ctrl_read = (!ctrl_rrr[0]) & ctrl_rr[0];
wire ctrl_write = (!ctrl_rrr[1]) & ctrl_rr[1];
always @(posedge axi_clk) begin
    ctrl_r <= ctrl;
    ctrl_rr <= ctrl_r;
    ctrl_rrr <= ctrl_rr;
end


reg awvalid,arvalid;

assign axi_awaddr     = waddr;
assign axi_awuser_ap  = 'b1;
assign axi_awuser_id  = 'b0;
assign axi_awlen      = 'b0;
assign axi_awvalid    = awvalid;
assign axi_wdata      = wdata;
assign axi_wstrb      = ~32'b0;
assign axi_araddr     = raddr;
assign axi_aruser_ap  = 'b1;
assign axi_aruser_id  = 'b0;
assign axi_arlen      = 'b0;
assign axi_arvalid    = arvalid;
wire   axi_wvalid     = 'b1;
wire   axi_rready     = 'b1;


always @(posedge axi_clk or negedge axi_rst_n) begin
    if(!axi_rst_n) rdata <= 256'b0;
    else if(axi_rready&axi_rvalid) rdata <= axi_rdata;

    if(!axi_rst_n) begin
        awvalid <= 1'b0;
        arvalid <= 1'b0;
        rdone <= 1'b0;
    end else begin
        if(axi_arvalid&axi_arready) arvalid <= 1'b0;
        if(ctrl_read) begin
            arvalid <= 1'b1;
            rdone <= 1'b0;
            rdata <= 256'b0;
        end 
        if(axi_rvalid) rdone <= 1'b1;

        if(axi_awvalid&axi_awready) awvalid <= 1'b0;
        if(ctrl_write) begin 
            awvalid <= 1'b1;
            wdone <= 1'b0;
        end

        if(axi_wusero_last) begin
            wdone <= 1'b1;
        end

    end
end 



endmodule