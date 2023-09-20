`timescale 1ps/1ps
// This builds a 8 to 1 mux out of 2 4 to 1 muxs and 1 2 to 1 mux.
// Receives 8 input lines that are toggled onto the output
// line by the 3 bit sel input.
module mux8_1(i, sel, out);
	input logic [7:0] i;
	input logic [2:0] sel;
	output logic out;
	
	logic v0, v1;
	
	mux4_1 m0 (.i00(i[0]), .i01(i[1]), .i10(i[2]), .i11(i[3]), .sel0(sel[0]), .sel1(sel[1]), .out(v0));
	mux4_1 m1 (.i00(i[4]), .i01(i[5]), .i10(i[6]), .i11(i[7]), .sel0(sel[0]), .sel1(sel[1]), .out(v1));
	mux2_1 m2 (.i0(v0), .i1(v1), .sel(sel[2]), .out(out));
endmodule

// Testbench for mux8_1
module mux8_1_testbench();
	logic [7:0] i;
	logic [2:0] sel;
	logic out;
	
	mux8_1 dut (.*);
	
	initial begin;
		// Set all to zero
		{i, sel[2], sel[1], sel[0]} = 0; 		#1000;
	
		// Test 0th entry in mux 1 -> OVERALL ENTRY 0
		sel = 0;
		i[0] = 1; 											#1000;
		i[0] = 0; 											#1000;
		// Test 3rd entry in mux 1 -> OVERALL ENTRY 3
		sel = 3;
		i[3] = 1; 											#1000;
		i[3] = 0; 											#1000;
		// End Mux 1 tests
		
		// Test 1st entry in mux 2 -> OVERALL ENTRY 5
		sel = 5;
		i[5] = 1; 											#1000;
		i[5] = 0; 											#1000;
		// Test 2nd entry in mux 2 -> OVERALL ENTRY 6
		sel = 6;
		i[6] = 1; 											#1000;
		i[6] = 0; 											#1000;
		// End Mux 1 tests
	end
	
endmodule