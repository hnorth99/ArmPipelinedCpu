`timescale 1ps/1ps
// This unit builds a regfilewrite_queue out of 4 regfilewrite_queue_sub.
// Recieves a clock and reset to coordinate operation within unit.
// Additionally takes a 1 bit input (RegWrt), 2 bit input (RegWData), and 5 bit input (Rd)
// that will be loaded into the register.
// Output of the register is projected onto RegWrtO, RegWDataO, and RdO.
// Takes 4 clock cycles.
module regfilewrite_queue (clk, reset, RegWrt, Rd, RegWrtO, RdO);
	input logic clk, reset, RegWrt;
	input logic [4:0] Rd;
	output logic RegWrtO;
	output logic [4:0] RdO;
	
	logic RW1, RW2;
	logic [4:0] Rd1, Rd2;
	
	regfilewrite_queue_sub r1 (.clk, .reset, .RegWrt, .Rd, .RegWrtO(RW1), .RdO(Rd1));
	regfilewrite_queue_sub r2 (.clk, .reset, .RegWrt(RW1), .Rd(Rd1), .RegWrtO(RW2), .RdO(Rd2));
	regfilewrite_queue_sub r4 (.clk, .reset, .RegWrt(RW2), .Rd(Rd2), .RegWrtO, .RdO);

endmodule

module regfilewrite_queue_testbench();
	logic clk, reset, RegWrt;
	logic [4:0] Rd;
	logic RegWrtO;
	logic [4:0] RdO;

	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	regfilewrite_queue dut (.*);
	
	initial begin
		reset <= 0; RegWrt <= 1'd0; Rd <= 5'd0;		@(posedge clk);
		reset <= 1; 																	@(posedge clk);
		reset <= 0; 																	@(posedge clk);
		RegWrt <= 1'd1; Rd <= 5'd0;			repeat(6)@(posedge clk); // RegWrtO gets a 1
		RegWrt <= 1'd1; Rd <= 5'd0;			repeat(6)@(posedge clk); // RegWDataO gets a 3
		RegWrt <= 1'd1; Rd <= 5'd12;			repeat(6)@(posedge clk); // RdO gets a 12
		
		$stop;
	end 
endmodule