`timescale 1ps/1ps
// This module will build a unit that can perform both addition and subtraction
// on a 64 bit number by using 64 add_sub units.
// Adds a and b or subbtracts b from a depending on sub input. Outputs the sum
// overflow and carryout.
module adder64(a, b, s);
	input logic [63:0] a, b;
	output logic [63:0] s;
	
	logic [63:0] cout;
	// Use a full adder -- determine if sub is taking place to add in 1
	full_adder f0 (.a(a[0]), .b(b[0]), .cin(1'b0), 
					 .s(s[0]), .cout(cout[0]));
	
	// Generate the 64 add_sub units
	genvar i;
	generate
		for (i = 1; i < 64; i++) begin : eachBit
			// Use a full adder -- determine if sub is taking place to add in 1
			full_adder f0 (.a(a[i]), .b(b[i]), .cin(cout[i-1]), 
					 .s(s[i]), .cout(cout[i]));
		end
	endgenerate
endmodule 

// Testbench for the add_sub_64 unit
module adder64_testbench();
	logic [63:0] a, b;
	logic [63:0] s;
	
	adder64 dut (.*);
	
	initial begin
		a = 64'd52; b = 64'd26;			#10000;
		a = 64'd40; b = 64'd11;			#10000;
	end
endmodule
