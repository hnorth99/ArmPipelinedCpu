`timescale 1ps/1ps
// This builds a unit of 64 32:1 muxs.
// The input data is received in a 32 count of 64 bit words. 
// The selected input word is specificed by the 5 bit sel input.
// 64 bit data is outputted onto out
module mux32_1_64x(i, sel, out);
	input logic [63:0] i [31:0];
	input logic [4:0] sel;
	output logic [63:0] out;
	
	// Transpose input data
	logic [31:0] transposed_bits [63:0];
	genvar j;
	genvar z;
	generate
		for (j = 0; j < 32; j++) begin : genj
			for (z = 0; z < 64; z++) begin : genz
				assign transposed_bits[z][j] = i[j][z];
			end
		end
	endgenerate
	
	// Create 64 muxs
	genvar m;
	generate
		for (m = 0; m < 64; m++) begin : genm
			mux32_1 mux32 (.i(transposed_bits[m]), .sel(sel), .out(out[m]));
		end
	endgenerate
endmodule

module mux32_1_64x_testbench();
	logic [63:0] i [31:0];
	logic [4:0] sel;
	logic [63:0] out;
	
	mux32_1_64x dut (.*);
	
	initial begin
	
		for(int j = 0; j < 32; j++) begin
			i[j] = 2045 * j;
		end
		#10;
		sel = 5'd2;			#100;
		sel = 5'd6;			#100;
		sel = 5'd9;			#100;
		sel = 5'd31;			#100;
		sel = 5'd0;			#100;
	end
endmodule
