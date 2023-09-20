`timescale 1ps/1ps
// This unit builds a 64 bit register out of 64 individual eD_FFs.
// Recieves a clock and reset to coordinate operation within unit.
// Additionally takes a 64 bit input (din) that will be loaded into 
// the register when the en bit is high. Output of register is projected
// onto dout.
module register64 (clk, reset, din, en, dout);
	input logic clk, reset, en;
	input logic [63:0] din;
	output logic [63:0] dout;
	
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit
			eD_FF d (.clk, .reset, .en, .din(din[i]), .dout(dout[i]));
		end
	endgenerate

endmodule

module register64_testbench();
	logic clk, reset, en;
	logic [63:0] din;
	logic [63:0] dout;
	
	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	register64 dut (.*);
	
	initial begin
		reset <= 0;	din <= 64'd0;	en <= 0;		@(posedge clk);
		reset <= 1;										@(posedge clk);
		reset <= 0; 									@(posedge clk);
		
		din <= 64'd0; 	        en <= 0;			repeat(2)@(posedge clk); // output 0
		din <= 64'd33; 	     en <= 0;			repeat(2)@(posedge clk); // shouldnt change output (0)
		din <= 64'd27; 	     en <= 1;			repeat(2)@(posedge clk); // input a 27
		din <= 64'd2147483647; en <= 0;			repeat(2)@(posedge clk); // shouldnt change output (27)
		din <= 64'd2147483647; en <= 1;			repeat(2)@(posedge clk); // input largest 32 bit number
		din <= 64'd0;			  en <= 0;			repeat(2)@(posedge clk); // should change output
		din <= 64'd0;			  en <= 1;			repeat(2)@(posedge clk); // load a zero
		din <= 64'd30;			  en <= 0;			repeat(2)@(posedge clk); // confirm still a zero
		$stop;
	end 
endmodule