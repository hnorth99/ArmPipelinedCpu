`timescale 1ps/1ps
// Builds a unit that will perform a bitwise or between 64 bit inputs a and b
// outputs onto 64 bit out
module bitwise_or_64(a, b, out);
	input logic [63:0] a, b;
	output logic [63:0] out;
	
	// generate 64 or gates
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit
			or #50 (out[i], a[i], b[i]);
		end
	endgenerate
endmodule

// Testbench for bitwise or
module bitwise_or_64_testbench();
	logic [63:0] a, b;
	logic [63:0] out;
	
	bitwise_or_64 dut (.*);
	
	initial begin
		a = 64'b0; b = 64'b0; #100; // zeros
		a = 64'b00000101; b = 64'b0000001001; #100; //13
		a = 64'd9223372036854775807; b = 64'd9223372036854775807; #100; //max
	end
endmodule