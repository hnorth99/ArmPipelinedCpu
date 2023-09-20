`timescale 1ps/1ps
// This builds a 2 to 1 mux.
// Receives two input lines that are toggled onto the output
// line by the sel input.
module mux2_1(i0, i1, sel, out);
	input logic i0, i1, sel;
	output logic out;

	logic tL, tR, selNot;
	not #50 n (selNot, sel);
	and #50 andL (tL, i1, sel);
	and #50 andR (tR, i0, selNot);
	or #50 orF (out, tL, tR);
endmodule

module mux2_1_testbench();
	logic i0, i1, sel;
	logic out;
	
	mux2_1 dut (.out, .i0, .i1, .sel);
	
	initial begin
		sel = 0; i0 = 0; i1 = 0; #100;
		sel = 0; i0 = 0; i1 = 1; #100;
		sel = 0; i0 = 1; i1 = 0; #100;
		sel = 0; i0 = 1; i1 = 1; #100;
		sel = 1; i0 = 0; i1 = 0; #100;
		sel = 1; i0 = 0; i1 = 1; #100;
		sel = 1; i0 = 1; i1 = 0; #100;
		sel = 1; i0 = 1; i1 = 1; #100;
	end
endmodule