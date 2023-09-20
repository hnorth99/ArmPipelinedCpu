`timescale 1ps/1ps
// This builds a 32 bit 4 to 1 mux using 2 32 bit 2 to 1 muxs.
// Receives 4 32 bit input lines that are toggled onto the 32 bit output
// line by the 2 bit sel input.
module mux4_1_64x(i00, i01, i10, i11, sel0, sel1, out);
	input logic [63:0] i00, i01, i10, i11;
	input logic sel0, sel1;
	output logic [63:0] out;
	
	logic [63:0] v0, v1;
	
	mux2_1_64x m0 (.i0(i00), .i1(i01), .sel(sel0), .out(v0));
	mux2_1_64x m1 (.i0(i10), .i1(i11), .sel(sel0), .out(v1));
	mux2_1_64x m (.i0(v0), .i1(v1), .sel(sel1), .out(out));
endmodule

module mux4_1_64x_testbench();
	logic [63:0] i00, i01, i10, i11;
	logic sel0, sel1;
	logic [63:0] out;

	mux4_1_64x dut (.i00, .i01, .i10, .i11, .sel0, .sel1, .out);
	
	integer i;
	initial begin
		{sel1, sel0, i00, i01, i10, i11} = '0; #1000;
		i00 <= 64'd100; 								#1000;
		sel1 <= 1; sel0 <= 1; i11 <= 64'd55;	#1000;
							#1000;
	end
endmodule