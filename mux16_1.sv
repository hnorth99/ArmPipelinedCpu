`timescale 1ps/1ps
// This builds a 16 to 1 mux out of 5 4 to 1 muxs.
// Receives 16 input lines that are toggled onto the output
// line by the 4 bit sel input.
module mux16_1(i, sel0, sel1, sel2, sel3, out);
					
	input logic [15:0] i;
	input logic sel0, sel1, sel2, sel3;
	output logic out;
	
	logic v0, v1, v2, v3;
	
	mux4_1 m0 (.i00(i[0]), .i01(i[1]), .i10(i[2]), .i11(i[3]), .sel1(sel1), .sel0(sel0), 
			     .out(v0));
	mux4_1 m1 (.i00(i[4]), .i01(i[5]), .i10(i[6]), .i11(i[7]), .sel1(sel1), .sel0(sel0), 
			     .out(v1));
	mux4_1 m2 (.i00(i[8]), .i01(i[9]), .i10(i[10]), .i11(i[11]), .sel1(sel1), .sel0(sel0),
			     .out(v2));
	mux4_1 m3 (.i00(i[12]), .i01(i[13]), .i10(i[14]), .i11(i[15]), .sel1(sel1), .sel0(sel0), 
			     .out(v3));
	mux4_1 m4 (.i00(v0), .i01(v1), .i10(v2), .i11(v3), .sel1(sel3), .sel0(sel2), 
			     .out(out));
endmodule

module mux16_1_testbench();
	logic [15:0] i;
   logic sel0, sel1, sel2, sel3;
	logic out;
 
	mux16_1 dut (.*);
	
	initial begin
		// Set all to zero
		{i, sel0, sel1, sel2, sel3} = 0; 		#100;
	
		// Mux 1 tests
		// Test 0th entry in mux 1 -> OVERALL ENTRY 0
		{sel3, sel2, sel1, sel0} = 0;
		i[0] = 1; 											#100;
		i[0] = 0; 											#100;
		// Test 2nd entry in mux 1 -> OVERALL ENTRY 2
		{sel3, sel2, sel1, sel0} = 2;
		i[2] = 1; 											#100;
		i[2] = 0; 											#100;
		// End Mux 1 tests
		
		// Mux 2 tests
		// Test 1st entry in mux 2 -> OVERALL ENTRY 5
		{sel3, sel2, sel1, sel0} = 5;
		i[5] = 1; 											#100;
		i[5] = 0;											#100;
		// Test 3rd entry in mux 2 -> OVERALL ENTRY 7
		{sel3, sel2, sel1, sel0} = 7;
		i[7] = 1; 											#100;
		i[7] = 0; 											#100;
		// End Mux 2 tests
		
		// Mux 3 tests
		// Test 0th entry in mux 3 -> OVERALL ENTRY 8
		{sel3, sel2, sel1, sel0} = 8;
		i[8] = 1; 											#100;
		i[8] = 0; 											#100;
		// Test 2nd entry in mux 3 -> OVERALL ENTRY 10
		{sel3, sel2, sel1, sel0} = 10;
		i[10] = 1; 										#100;
		i[10] = 0;											#100;
		// End Mux 3 tests
		
		// Mux 4 tests
		// Test 1st entry in mux 4 -> OVERALL ENTRY 13
		{sel3, sel2, sel1, sel0} = 13;
		i[13] = 1; 										#100;
		i[13] = 0; 										#100;
		// Test 4th entry in mux 4 -> OVERALL ENTRY 15
		{sel0, sel1, sel2, sel3} = 15;
		i[15] = 1; 										#100;
		i[15] = 0;											#100;
		// End Mux 4 tests
	end
endmodule