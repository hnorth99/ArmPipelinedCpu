`timescale 1ps/1ps
// This builds a 4 to 1 mux using 2 2 to 1 muxs.
// Receives 4 input lines that are toggled onto the output
// line by the 2 bit sel input.
module mux4_1(i00, i01, i10, i11, sel0, sel1, out);

	input logic i00, i01, i10, i11, sel0, sel1;
	output logic out;
	
	logic v0, v1;
	
	mux2_1 m0 (.i0(i00), .i1(i01), .sel(sel0), .out(v0));
	mux2_1 m1 (.i0(i10), .i1(i11), .sel(sel0), .out(v1));
	mux2_1 m (.i0(v0), .i1(v1), .sel(sel1), .out(out));
endmodule

module mux4_1_testbench();
	logic i00, i01, i10, i11, sel0, sel1;
	logic out;

	mux4_1 dut (.i00, .i01, .i10, .i11, .sel0, .sel1, .out);
	
	integer i;
	initial begin
		for(i = 0; i < 64; i++) begin
			{sel1, sel0, i00, i01, i10, i11} = i; #100;
		end
	end
endmodule