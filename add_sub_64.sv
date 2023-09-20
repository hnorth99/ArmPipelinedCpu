`timescale 1ps/1ps
// This module will build a unit that can perform both addition and subtraction
// on a 64 bit number by using 64 add_sub units.
// Adds a and b or subbtracts b from a depending on sub input. Outputs the sum
// overflow and carryout.
module add_sub_64(a, b, sub, s, overflow, carryout);
	input logic [63:0] a, b;
	input logic sub;
	output logic [63:0] s;
	output logic overflow, carryout;
	
	logic [63:0] cout;
	// Use a full adder -- determine if sub is taking place to add in 1
	add_sub as0 (.a(a[0]), .b(b[0]), .cin(sub), .sub(sub), 
					 .s(s[0]), .cout(cout[0]));
	
	// Generate the 64 add_sub units
	genvar i;
	generate
		for (i = 1; i < 64; i++) begin : eachBit
			add_sub as(.a(a[i]), .b(b[i]), .cin(cout[i - 1]), .sub(sub), 
						  .s(s[i]), .cout(cout[i]));
		end
	endgenerate
	
	xor #50 (overflow, cout[62], cout[63]);
	assign carryout = cout[63];

endmodule 

// Testbench for the add_sub_64 unit
module add_sub_64_testbench();
	logic [63:0] a, b;
	logic sub;
	logic [63:0] s;
	logic overflow, carryout;
	
	add_sub_64 dut (.*);
	
	integer i;
	initial begin
		// No overflow
		a = 64'd52; b = 64'd26; sub = 0;				#10000;
		a = 64'd52; b = 64'd26; sub = 1;				#10000;
		a = 64'd99; b = -64'd44; sub = 0;			#10000;
		a = 64'd99; b = -64'd44; sub = 1;			#10000;
		a = 64'd9223372036854775807;	b = 64'd1; sub = 0; #10000;
		a = 64'd9223372036854775807;	b = 64'd111; sub = 0; #10000;
		// Check zero
		a = 64'd9223372036854775807;	b = 64'd9223372036854775807; 
		sub = 1;	  #10000;
		a = 64'd1; b = '1; sub = 0;        #10000;
	end
endmodule
