`timescale 1ps/1ps
// This is a basic d flip flop unit 
module D_FF (q, d, reset, clk);  
	output reg q;   
	input d, reset, clk;   
	
	always_ff @(posedge clk)   
		if (reset)     
			q <= 0;  // On reset, set to 0   
		else     
			q <= d; // Otherwise out = d 
endmodule 

module D_FF_testbench();
	logic q;
	logic d, reset, clk;
	
	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	D_FF dut (.*);
	
	initial begin
		reset <= 0;	d <= 0;	@(posedge clk);
		reset <= 1;				@(posedge clk);
		reset <= 0; 			@(posedge clk);
		
		d <= 1;					@(posedge clk);
		d <= 1; 					@(posedge clk);
		d <= 0;					@(posedge clk);
		d <= 1;					@(posedge clk);
		d <= 1;					@(posedge clk);
		$stop;
	end
endmodule