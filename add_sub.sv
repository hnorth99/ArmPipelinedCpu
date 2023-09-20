`timescale 1ps/1ps
// This module builds an add and subtracting unit out of a full adder
// Recieves one bit inputs a, b, and cIn to add or subtract (decided by sub
// input). Result is put onto s (sum) and cout (carryout) signals
module add_sub(a, b, cin, sub, s, cout);
	input logic a, b, cin, sub;
	output logic s, cout;
	
	// Invert b
	logic b_not, b_new;
	not #50 (b_not, b);
	
	mux2_1 m (.i0(b), .i1(b_not), .sel(sub), .out(b_new));
	full_adder f1 (.a(a), .b(b_new), .cin(cin), .s(s), .cout(cout));
endmodule


module add_sub_testbench();
	logic a, b, cin, sub;
	logic s, cout;
	
	add_sub dut (.*);
	
	integer i;
	initial begin
		for(i = 0; i < 16; i++) begin
			{a, b, cin, sub} = i; #1000;
		end
	end
endmodule
