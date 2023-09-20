`timescale 1ps/1ps
// Builds a 64 input nor gate
// Recieves 64 1 bit signals through input a and outputs a 1 bit signal to out
module nor_64(a, out);
	input logic [63:0] a;
	output logic out;
	
	logic [15:0] l1_wires;
	logic [3:0] l2_wires;
	logic l3_wire;
	
	// Generate 16 4 input or gates for 64 inputs
	genvar i;
	generate
		for (i = 0; i < 16; i++) begin : orl1
			or #50 (l1_wires[i], a[4*i + 3], a[4*i + 2], a[4*i + 1], a[4*i]);
		end
	endgenerate
	
	// Generates 4 4 input or gates for outputs of previous norgate level
	genvar j;
	generate
		for (j = 0; j < 4; j++) begin : orl2
			or #50 (l2_wires[j], l1_wires[4*j + 3], l1_wires[4*j + 2], l1_wires[4*j + 1], l1_wires[4*j]);
		end
	endgenerate
	
	// Or together previous level of or gate outputs
	or #50 (l3_wire, l2_wires[0], l2_wires[1], l2_wires[2], l2_wires[3]);
	// Not final signal
	not #50 (out, l3_wire);
endmodule

module nor_64_testbench();
	logic [63:0] a;
	logic out;
	
	nor_64 dut (.*);
	
	initial begin
		a = '0;					#10000;
		a = 64'b1010101010;	#10000;
		a = 64'b0000000001;	#10000;
		a = 64'b1111111111;	#10000;
		a = 64'b1010101010;	#10000;
	end
endmodule