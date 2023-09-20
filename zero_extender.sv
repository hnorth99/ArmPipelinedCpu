// Module to extend an input with EXTENSION parameter to reach a 32 bit output
// filled with zeros at front
module zero_extender #(
	parameter EXTENSION=6) 
	(in, out);
	input logic [63 - EXTENSION:0] in;
	output logic [63:0] out;
	
	genvar i;
	generate
		for (i = 0; i < 64 - EXTENSION; i++) begin : eachBit0
			assign out[i] = in[i];
		end
	endgenerate
	
	genvar j;
	generate
		for (j = 64 - EXTENSION; j < 64; j++) begin : eachBit1
			assign out[j] = 1'b0;
		end
	endgenerate
endmodule

module zero_extender_testbench();
	logic [18:0] in;
	logic [63:0] out;
	
	zero_extender #(45) dut (.*);
	
	initial begin
		in = 19'd3;	#1000;
		in = -19'd5;#1000;
	end
endmodule