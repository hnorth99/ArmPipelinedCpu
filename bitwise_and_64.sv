`timescale 1ps/1ps
// Builds a unit that will perform a bitwise and between 64 bit inputs a and b
// outputs onto 64 bit out
module bitwise_and_64(a, b, out);
	input logic [63:0] a, b;
	output logic [63:0] out;
	
	// Generate 64 different and gates
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit
			and #50 (out[i], a[i], b[i]);
		end
	endgenerate
endmodule

// Testbench for bitwise and
module bitwise_and_64_testbench();
	logic [63:0] a, b;
	logic [63:0] out;
	
	bitwise_and_64 dut (.*);
	
	initial begin
		a = 64'b0; b = 64'b0; #100; // zeros
		a = 64'b101011001101; b = 64'b10010101001110; #100; //76
		a = 64'd9223372036854775807; b = 64'd9223372036854775807; #100; //max
	end
endmodule