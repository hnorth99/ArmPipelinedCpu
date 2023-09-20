`timescale 1ps/1ps
// This builds a 3 to 8 decoder with an enable bit out of 2 2 to 4 edecoders. 
// The unit receives a 3 input code (binary number) that
// will determine which of 8 output lines receives the enable input bit
module edecoder3_8(i, e, o);
	input logic [2:0] i;
	input logic e;
	output logic [7:0] o;
	
	logic noti2;
	not #50 n (noti2, i[2]);
	
	logic [7:0] t;
	edecoder2_4 ed0 (.i1(i[1]), .i0(i[0]), .e(noti2), .o0(t[0]), 
						  .o1(t[1]), .o2(t[2]), .o3(t[3]));
	edecoder2_4 ed1 (.i1(i[1]), .i0(i[0]), .e(i[2]), .o0(t[4]), 
						  .o1(t[5]), .o2(t[6]), .o3(t[7]));

	genvar k;
	generate
		for (k = 0; k < 8; k++) begin : eachAND
			and aGate (o[k], e, t[k]);
		end
	endgenerate
endmodule

module edecoder3_8_testbench();
	logic [2:0] i;
	logic e;
	logic [7:0] o;
	
	edecoder3_8 dut (.*);
	
	integer k;
	initial begin
		for(k = 0; k < 16; k++) begin
			{i, e} = k; #100;
		end
	end
endmodule