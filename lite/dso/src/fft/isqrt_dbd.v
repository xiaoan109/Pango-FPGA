// Digit-by-digit method
`define M(W, I) ({{(W-1){1'b0}}, 1'b1}<<(W - 2*(I + 1)))

module isqrt_dbd #(parameter DATA_WIDTH = 32) (clk, data, q);
	localparam WIDTH = (DATA_WIDTH & 1) ? DATA_WIDTH + 1 : DATA_WIDTH;

	input clk;
	input [DATA_WIDTH-1:0] data;
	output [WIDTH/2-1:0] q;

	reg [WIDTH-1:0] data_reg;
	reg  [WIDTH-1:0]x [WIDTH/2 - 1:0];
	reg  [WIDTH-1:0]y [WIDTH/2 - 1:0];
	reg  [WIDTH-1:0]b [WIDTH/2 - 1:0];

	
	always @(posedge clk)
		data_reg <= data;
	
	always @(posedge clk) begin
		if (data_reg >= `M(WIDTH, 0))
			begin
				x[0] <= data_reg - `M(WIDTH, 0);
				y[0] <= `M(WIDTH, 0);
			end
		else
			begin
				x[0] <= data_reg;
				y[0] <= 'b0;
			end
	end
	
	genvar i;
	generate for (i = 1; i < WIDTH/2; i=i+1)
		begin :gen
			always @(*)
				b[i-1] = y[i-1] | `M(WIDTH, i);
		
			always @(posedge clk)
				if (x[i-1] >= b[i-1])
					begin
						x[i] <= x[i-1] - b[i-1];
						y[i] <= (y[i-1] >> 1'b1) | `M(WIDTH, i);
					end
				else
					begin
						x[i] <= x[i-1];
						y[i] <= y[i-1] >> 1'b1;
					end
		end
	endgenerate
	
	assign q = y[WIDTH/2 - 1][WIDTH/2 - 1:0];
	
endmodule
