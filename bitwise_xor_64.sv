`timescale 1ps/1ps
// Builds a unit that will perform a bitwise xor between 64 bit inputs a and b
// outputs onto 64 bit out
module bitwise_xor_64(a, b, out);
	input logic [63:0] a, b;
	output logic [63:0] out;
	
	// Generate 64 xor gates
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit
			xor #50 (out[i], a[i], b[i]);
		end
	endgenerate
endmodule

// Testbench for bitwise xor
module bitwise_xor_64_testbench();
	logic [63:0] a, b;
	logic [63:0] out;
	
	bitwise_xor_64 dut (.*);
	
	initial begin
		a = 64'b0; b = 64'b0; #100; // 0
		a = 64'b00000101; b = 64'b0000001001; #100; //1100 (12)
		a = 64'd9223372036854775807; b = 64'd9223372036854775807; #100; //0
	end
endmodule