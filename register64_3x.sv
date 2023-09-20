`timescale 1ns/10ps
// This unit builds 3, 64 bit registers.
// Recieves a clock and reset to coordinate operation within unit.
// Takes 3 64 bit input (a, b, c) that will be loaded into 
// the register. Output of register is projected
// onto outA, outB, and outC.
module register64_3x(clk, reset, a, b, c, outA, outB, outC);
	input logic clk, reset;
	input logic [63:0] a, b, c;
	output logic [63:0] outA, outB, outC;
	
	register64 aReg (.clk, .reset, .din(a), .en(1'b1), .dout(outA));
	register64 bReg (.clk, .reset, .din(b), .en(1'b1), .dout(outB));
	register64 cReg (.clk, .reset, .din(c), .en(1'b1), .dout(outC));
endmodule 

// Module to confirm that register64_3x is working
module register64_3x_testbench();
	logic clk, reset;
	logic [63:0] a, b, c;
	logic [63:0] outA, outB, outC;

	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	register64_3x dut (.*);
	
	initial begin
		reset <= 0;	a <= 64'd0; b <= 64'd0; c <= 64'd0;			@(posedge clk);
		reset <= 1;															@(posedge clk);
		reset <= 0; 														@(posedge clk);
		
		a <= 64'd5;															@(posedge clk);
		a <= 64'd6; b <= 64'd10; 										@(posedge clk);
		a <= 64'd7; b <= 64'd11; c <= 64'd15;						@(posedge clk);
		a <= 64'd0; b <= 64'd0; c <= 64'd0;							@(posedge clk);
		$stop;
	end
endmodule