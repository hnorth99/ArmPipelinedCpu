`timescale 1ps/1ps
// This builds a 32 bit 4 to 1 mux using 2 32 bit 2 to 1 muxs.
// Receives 4 32 bit input lines that are toggled onto the 32 bit output
// line by the 2 bit sel input.
module mux4_1_32x(i00, i01, i10, i11, sel0, sel1, out);
	input logic [31:0] i00, i01, i10, i11;
	input logic sel0, sel1;
	output logic [31:0] out;
	
	logic [31:0] v0, v1;
	
	mux2_1_32x m0 (.i0(i00), .i1(i01), .sel(sel0), .out(v0));
	mux2_1_32x m1 (.i0(i10), .i1(i11), .sel(sel0), .out(v1));
	mux2_1_32x m (.i0(v0), .i1(v1), .sel(sel1), .out(out));
endmodule

module mux4_1_32xtestbench();
	logic [31:0] i00, i01, i10, i11;
	logic sel0, sel1;
	logic [31:0] out;

	mux4_1_32x dut (.i00, .i01, .i10, .i11, .sel0, .sel1, .out);
	
	integer i;
	initial begin
		for(i = 0; i < 32; i++) begin
			{sel1, sel0, i00, i01, i10, i11} = i; #100;
		end
	end
endmodule