`timescale 1ps/1ps

// This module will handle the flag registers by storing input signals
// into registers when enable signal is high
module flag_handler(clk, reset, en, zero_in, oflow_in, neg_in, cout_in,
						  zero, overflow, negative, carry_out);
	input logic clk, reset, en;
	input logic zero_in, oflow_in, neg_in, cout_in;
	output logic zero, overflow, negative, carry_out;
	
	// Intermediate wires
	logic z_mout, z_min, o_mout, o_min, n_mout, n_min, c_mout, c_min;
	
	// Muxs to determine what to feed into the Dffs
	mux2_1 zm (.i0(z_min), .i1(zero_in), .sel(en), .out(z_mout));
	mux2_1 om (.i0(o_min), .i1(oflow_in), .sel(en), .out(o_mout));
	mux2_1 nm (.i0(n_min), .i1(neg_in), .sel(en), .out(n_mout));
	mux2_1 cm (.i0(c_min), .i1(cout_in), .sel(en), .out(c_mout));
	
	D_FF zDff (.clk, .reset, .d(z_mout), .q(z_min));
	D_FF oDff (.clk, .reset, .d(o_mout), .q(o_min));
	D_FF nDff (.clk, .reset, .d(n_mout), .q(n_min));
	D_FF cDff (.clk, .reset, .d(c_mout), .q(c_min));
	
	// Assign outputs
	assign zero 		= z_mout;
	assign overflow 	= o_mout;
	assign negative 	= n_mout;
	assign carry_out	= c_mout;
endmodule

module flag_handler_testbench();
	logic clk, reset, en;
	logic zero_in, oflow_in, neg_in, cout_in;
	logic zero, overflow, negative, carry_out;
	
	// Simulated clock for the testing
	parameter clock_period = 1000;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	flag_handler dut (.*);
	
	initial begin
		reset <= 0; neg_in <= 0; oflow_in <= 0; 
		cout_in <= 0; zero_in <= 0; en <=0;				@(posedge clk);
		reset <= 1;												@(posedge clk);
		reset <= 0; 											@(posedge clk);
		
		zero_in <= 1;  en <= 0; 				repeat(5)@(posedge clk);
							en <= 1;								@(posedge clk);
		neg_in <= 1; oflow_in <= 1; 
		cout_in <= 1; zero_in <= 1; en <=0; repeat(1)@(posedge clk);
		zero_in <= 0;								repeat(2)@(posedge clk);
		en <= 1; 									repeat(2)@(posedge clk);
		$stop;
	end
endmodule