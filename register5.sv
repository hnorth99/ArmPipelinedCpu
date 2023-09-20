`timescale 1ps/1ps
// This unit builds a 5 bit register out of 5 individual eD_FFs.
// Recieves a clock and reset to coordinate operation within unit.
// Additionally takes a 5 bit input (din) that will be loaded into 
// the register when the en bit is high. Output of register is projected
// onto dout.
module register5 (clk, reset, din, en, dout);
	input logic clk, reset, en;
	input logic [4:0] din;
	output logic [4:0] dout;
	
	genvar i;
	generate
		for (i = 0; i < 5; i++) begin : eachBit
			eD_FF d (.clk, .reset, .en, .din(din[i]), .dout(dout[i]));
		end
	endgenerate

endmodule

module register5_testbench();
	logic clk, reset, en;
	logic [4:0] din;
	logic [4:0] dout;
	
	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	register5 dut (.*);
	
	initial begin
		reset <= 0;	din <= 4'd0;	en <= 1;		@(posedge clk);
		reset <= 1;										@(posedge clk);
		reset <= 0; 									@(posedge clk);
		
		din <= 5'd0; 	     en <= 1;			repeat(2)@(posedge clk); // output 0
		din <= 5'd31; 	     en <= 1;			repeat(2)@(posedge clk); // output 31
		din <= 5'd27; 	     en <= 1;			repeat(2)@(posedge clk); // output 27
		$stop;
	end 
endmodule