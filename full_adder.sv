`timescale 1ps/1ps
// This unit builds a full adder.
// Recieves one bit inputs for a, b, cin and then outputs the signals
// representing the sum of three inputs onto s (sum) and cout (carry out)
module full_adder(a, b, cin, s, cout);
	input logic a, b, cin;
	output logic s, cout;
	
	// s logic
	xor #50 (s, a, b, cin);
	
	// cout logic
	logic wtop, wmid, wbot;
	and #50 andTop (wtop, a, b);
	and #50 andMid (wmid, a, cin);
	and #50 andBot (wbot, b, cin);
	or #50 andFinal (cout, wtop, wmid, wbot);
	
endmodule

// Testbench for the full_adder unit
module full_adder_testbench();
	logic a, b, cin;
	logic s, cout;
	
	full_adder dut (.*);
	
	integer i;
	initial begin
		for(i = 0; i < 8; i++) begin
			{a, b, cin} = i; #1000;
		end
	end
endmodule