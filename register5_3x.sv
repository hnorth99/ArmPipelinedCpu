`timescale 1ps/1ps
// This unit builds 3 5bit registers.
// Recieves a clock and reset to coordinate operation within unit.
// Additionally takes a 3 5 bit inputs (din1, din2, din3) that will be loaded into 
// the registers. Output of the registers is projected onto dout1, dout2, and dout3.
module register5_3x (clk, reset, din1, din2, din3, dout1, dout2, dout3);
	input logic clk, reset;
	input logic [4:0] din1, din2, din3;
	output logic [4:0] dout1, dout2, dout3;
	
	register5 r1 (.clk, .reset, .din(din1), .en(1'b1), .dout(dout1));
	register5 r2 (.clk, .reset, .din(din2), .en(1'b1), .dout(dout2));
	register5 r3 (.clk, .reset, .din(din3), .en(1'b1), .dout(dout3));

endmodule

module register5_3x_testbench();
	logic clk, reset, en;
	logic [4:0] din1, din2, din3;
	logic [4:0] dout1, dout2, dout3;
	
	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	register5_3x dut (.*);
	
	initial begin
		reset <= 0;	din1 <= 4'd0;	din2<= 4'd0; din3 <= 4'd0; en <= 1;			@(posedge clk);
		reset <= 1;																				@(posedge clk);
		reset <= 0; 																			@(posedge clk);
		
		din1 <= 5'd5; 	     en <= 1;											repeat(2)@(posedge clk); // output 0
		din2 <= 5'd31; 	  en <= 1;											repeat(2)@(posedge clk); // output 31
		din3 <= 5'd27; 	  en <= 1;											repeat(2)@(posedge clk); // output 27
		$stop;
	end 
endmodule