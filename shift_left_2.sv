// Module that will shift in two zeros and then shift everything else to the left
// Top two bits shifted out. 
module shift_left_2 (in, out);
	input logic [63:0] in;
	output logic [63:0] out;
	
	assign out[0] = 0;
	assign out[1] = 0;
	
	genvar i;
	generate
		for (i = 2; i < 64; i++) begin : b
			assign out[i] = in[i - 2];
		end
	endgenerate
endmodule

module shift_left_2_testbench ();
	logic [63:0] in;
	logic [63:0] out;
	
	shift_left_2 dut (.*);
	
	initial begin
		in = 63'd4; #1000;
		in = '1; #1000;
	end
endmodule