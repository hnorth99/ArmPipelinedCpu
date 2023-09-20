`timescale 1ps/1ps
// This builds a D_FF with an enabler. A new bit will be loaded
// into the register (via din) only when the en bit is high. Bit stored
// in eDFF is outputed to dout
module eD_FF(clk, reset, en, din, dout);
	input logic clk, reset, en, din;
	output logic dout;
	
	logic f, d;
	
	mux2_1 m (.i0(f), .i1(din), .sel(en), .out(d));
	D_FF d_ff (.q(f), .d, .reset, .clk);
	
	assign dout = f;
endmodule 

module eD_FF_testbench();
	logic clk, reset, en, din;
	logic dout;
	
	eD_FF dut (.clk, .reset, .en, .din, .dout);
	
	// Simulated clock for the testing
	parameter clock_period = 1000;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	initial begin
		reset <= 0;	din <= 0;	en <= 0;		@(posedge clk);
		reset <= 1;									@(posedge clk);
		reset <= 0; 								@(posedge clk);
		
		din <= 0; 	en <= 0;			repeat(2)@(posedge clk); // output 0
		din <= 1; 	en <= 0;			repeat(2)@(posedge clk); // shouldnt change output (0)
		din <= 1; 	en <= 1;			repeat(2)@(posedge clk); // input a 1
		din <= 0; 	en <= 0;			repeat(2)@(posedge clk); // shouldnt change output (1)
		din <= 0; 	en <= 1;			repeat(2)@(posedge clk); // input a 0
		din <= 0;   en <= 0; 		repeat(2)@(posedge clk); // still 0....
		$stop;
	end
endmodule
