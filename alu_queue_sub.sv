`timescale 1ps/1ps
// This unit builds a register out of 4 individual D_FFs.
// Recieves a clock and reset to coordinate operation within unit.
// Additionally takes a 3 bit input (ALUCntrl) and 1 bit input (FlagE) 
// that will be loaded into the register.
// Output of the register is projected onto ALUCntrlO and FlagEO.
module alu_queue_sub (clk, reset, ALUCntrl, FlagE, FwdALU, ShiftDir, ShiftToALUB, Shamt, 
							 ALUCntrlO, FlagEO, FwdALUO, ShiftDirO, ShiftToALUBO, ShamtO);
	input logic clk, reset, FlagE, FwdALU;
	input logic ShiftDir, ShiftToALUB;
	input logic [5:0] Shamt;
	input logic [2:0] ALUCntrl;
	output logic [2:0] ALUCntrlO;
	output logic ShiftDirO, ShiftToALUBO;
	output logic [5:0] ShamtO;
	output logic FlagEO, FwdALUO;
	
	genvar i;
	generate
		for (i = 0; i < 3; i++) begin : eachBit
			D_FF alu (.clk, .reset, .d(ALUCntrl[i]), .q(ALUCntrlO[i]));
		end
	endgenerate
	
	// 6 bit dff
	genvar j;
	generate
		for (j = 0; j < 64; j++) begin : eachBit0
			D_FF ds (.q(ShamtO[j]), .d(Shamt[j]), .reset, .clk);
		end
	endgenerate
	
	D_FF flag (.clk, .reset, .d(FlagE), .q(FlagEO));
	D_FF FwdALUDFF (.clk, .reset, .d(FwdALU), .q(FwdALUO));
	D_FF dffShiftDir (.clk, .reset, .d(ShiftDir), .q(ShiftDirO));
	D_FF dffShiftToALUB (.clk, .reset, .d(ShiftToALUB), .q(ShiftToALUBO));
endmodule

module alu_queue_sub_testbench();
	logic clk, reset, FlagE, FlagEO, FwdALU, FwdALUO;
	logic [2:0] ALUCntrl, ALUCntrlO;
	logic ShiftDir, ShiftToALUB, ShiftDirO, ShiftToALUBO;
	logic [5:0] Shamt, ShamtO;

	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	alu_queue_sub dut (.*);
	
	initial begin
		reset <= 0; ALUCntrl <= 3'd0; FlagE <= 1'd0;		@(posedge clk);
		reset <= 1; 												@(posedge clk);
		reset <= 0; 												@(posedge clk);
		ALUCntrl <= 3'd3; FlagE <= 1'd0;		repeat(2)@(posedge clk);
		ALUCntrl <= 3'd5; FlagE <= 1'd1;		repeat(2)@(posedge clk);
		
		$stop;
	end 
endmodule