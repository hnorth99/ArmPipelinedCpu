`timescale 1ps/1ps
// This unit builds a 32 bit dff out of 32 individual D_FFs.
// Recieves a clock and reset to coordinate operation within unit.
// Additionally takes a 32 bit input (d) that will be loaded into 
// the q.
module D_FF_64 (clk, reset, d, q);
	input logic clk, reset;
	input logic [63:0] d;
	output logic [63:0] q;
	
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit
			D_FF d (.q(q[i]), .d(d[i]), .reset, .clk);
		end
	endgenerate

endmodule

module D_FF_64_testbench();
	logic clk, reset;
	logic [63:0] d;
	logic [63:0] q;
	
	// Simulated clock for the testing
	parameter clock_period = 1000;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	D_FF_64 dut (.*);
	
	initial begin
		reset <= 0;	d <= 63'd0;						@(posedge clk);
		reset <= 1;										@(posedge clk);
		reset <= 0; 									@(posedge clk);
		
		d <= 63'd0; 	   				repeat(2)@(posedge clk); 
		d <= 63'd27; 	     			   repeat(2)@(posedge clk); 
		d <= 63'd2147; 					repeat(2)@(posedge clk); 
		d <= 63'd30;						repeat(2)@(posedge clk); 
		$stop;
	end 
endmodule