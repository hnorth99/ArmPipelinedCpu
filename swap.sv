// Module that will swap two 5 bit inputs when the swap signal is high
module swap (i0, i1, swap, out0, out1);
	input logic [4:0] i0, i1;
	input logic swap;
	output logic [4:0] out0, out1;
	
	mux2_1_5x m1 (.i0, .i1, .sel(swap), .out(out0));
	mux2_1_5x m2 (.i0(i1), .i1(i0), .sel(swap), .out(out1));
	
endmodule	