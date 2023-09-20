`timescale 1ps/1ps
// This builds a 32 to 1 mux out of 2 16 to 1 muxs and 1 2 to 1 mux.
// Receives 32 input lines that are toggled onto the output
// line by the 5 bit sel input.
module mux32_1(i, sel, out);

	input logic [31:0] i;
	input logic [4:0] sel;
	output logic out;
	
	logic v0, v1;
	
	mux16_1 m0 (.i(i[15:0]), .sel0(sel[0]), .sel1(sel[1]), .sel2(sel[2]), 
					.sel3(sel[3]), .out(v0));
	mux16_1 m1 (.i(i[31:16]), .sel0(sel[0]), .sel1(sel[1]), .sel2(sel[2]), 
					.sel3(sel[3]), .out(v1));
	mux2_1 m2  (.i0(v0), .i1(v1), .sel(sel[4]), .out(out));
	
endmodule

module mux32_1_testbench();
	logic [31:0] i;
	logic [4:0] sel;
	logic out;
 
	mux32_1 dut (.*);
	
	initial begin
		// Zero everything
		{i, sel} = 0;				#100;
		
		// Test first mux
		// Test 0th entry in mux 1 -> OVERALL ENTRY 0
		sel = 5'b00000;
		i[0] = 1; 											#100;
		i[0] = 0; 											#100;
		// Test 6th entry in mux 1 -> OVERALL ENTRY 6
		sel = 5'b00110;
		i[6] = 1; 											#100;
		i[6] = 0; 											#100;
		// Test 14th entry in mux 1 -> OVERALL ENTRY 14
		sel = 5'b01110;
		i[14] = 1; 											#100;
		i[14] = 0; 											#100;
		// End Mux 1 tests
		
		// Test second mux
		// Test 4th entry in mux 2 -> OVERALL ENTRY 20
		sel = 5'b10100;
		i[20] = 1; 											#100;
		i[20] = 0; 											#100;
		// Test 12th entry in mux 2 -> OVERALL ENTRY 28
		sel = 5'b11100;
		i[28] = 1; 											#100;
		i[28] = 0; 											#100;
		// Test 15th entry in mux 2 -> OVERALL ENTRY 31
		sel = 5'b11111;
		i[31] = 1; 											#100;
		i[31] = 0; 
		// End Mux 2 test
	end
endmodule