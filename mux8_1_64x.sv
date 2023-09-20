`timescale 1ps/1ps
// Create an 8 to 1 mux that operates on 64 bit inputs by using 64 8 to 1 muxs
// Recieves 8 64 bit signals in input i and toggles which 64 bit signal is sent to
// out through the 3 bit sel input
module mux8_1_64x(i, sel, out);
	input logic [63:0] i [7:0];
	input logic [2:0] sel;
	output logic [63:0] out;
	
	// Transpose input data
	logic [7:0] transposed_bits [63:0];
	genvar j;
	genvar z;
	generate
		for (j = 0; j < 8; j++) begin : genj
			for (z = 0; z < 64; z++) begin : genz
				assign transposed_bits[z][j] = i[j][z];
			end
		end
	endgenerate
	
	// Create 64 muxs
	genvar m;
	generate
		for (m = 0; m < 64; m++) begin : genm
			mux8_1 mux8 (.i(transposed_bits[m]), .sel(sel), .out(out[m]));
		end
	endgenerate
endmodule

module mux8_1_64x_testbench();
	logic [63:0] i [7:0];
	logic [2:0] sel;
	logic [63:0] out;
	
	mux8_1_64x dut (.*);
	
	initial begin
		for(int j = 0; j < 8; j++) begin
			i[j] = 2045 * j;
		end
		#10000;
		for(int j = 0; j < 8; j++) begin
			sel = j; #10000;
		end
	end
endmodule