`timescale 1ps/1ps
// This builds a unit of 5 2:1 muxs.
// The input data is received in a 2 count of 5 bit words. 
// The selected input word is specificed by the 1 bit sel input.
// 5 bit data is outputted onto out
module mux2_1_5x(i0, i1, sel, out);
	input logic [4:0] i0, i1;
	input logic sel;
	output logic [4:0] out;
	
	// Create 5 muxs
	genvar m;
	generate
		for (m = 0; m < 5; m++) begin : genm
			mux2_1 mux2 (.i0(i0[m]), .i1(i1[m]), .sel(sel), .out(out[m]));
		end
	endgenerate
endmodule

module mux2_1_5x_testbench();
	logic [4:0] i0, i1;
	logic sel;
	logic [4:0] out;
	
	mux2_1_5x dut (.*);
	
	initial begin
		sel = 0; i0 = 5'd6; i1 = 5'd10; #1000;
		sel = 1; i0 = 5'd6; i1 = 5'd10; #1000;

	end
endmodule
