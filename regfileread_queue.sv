`timescale 1ns/10ps
// This unit builds the queue for control logic in the regfileread pipeline stage.
// Recieves a clock and reset as well as all the required control logic from the decoder.
// Outputs values onto control logic name with O added to end
module regfileread_queue(clk, reset, Swap, RdToRdA, RdToRdB, 
								 Imm12ALU, ImmALUA, ImmALUA, Imm12, Imm9,
								 FwdT1, FwdT2, FwdT3, FwdT4, BrTaken,
								 SwapO, RdToRdAO, RdToRdBO, 
								 Imm12ALUO, ImmALUAO, Imm12O, Imm9O,
								 FwdT1O, FwdT2O, FwdT3O, FwdT4O, BrTakenO);
	input logic clk, reset, Swap, RdToRdA, RdToRdB, Imm12ALU, ImmALUA, FwdT1, FwdT2, 
					FwdT3, FwdT4, BrTaken;
	input logic [11:0] Imm12;
	input logic [8:0] Imm9;
	
	output logic SwapO, RdToRdAO, RdToRdBO, Imm12ALUO, ImmALUAO, FwdT1O, FwdT2O, FwdT3O, FwdT4O, BrTakenO;
	output logic [11:0] Imm12O;
	output logic [8:0] Imm9O;
	
	// 1 bit dffs
	D_FF dffSwap (.clk, .reset, .d(Swap), .q(SwapO));
	D_FF dffRdToRdA (.clk, .reset, .d(RdToRdA), .q(RdToRdAO));
	D_FF dffRdToRdB (.clk, .reset, .d(RdToRdB), .q(RdToRdBO));
	D_FF dffImm12ALU (.clk, .reset, .d(Imm12ALU), .q(Imm12ALUO));
	D_FF dffImmALUA (.clk, .reset, .d(ImmALUA), .q(ImmALUAO));
	D_FF dffFwdT1 (.clk, .reset, .d(FwdT1), .q(FwdT1O));
	D_FF dffFwdT2 (.clk, .reset, .d(FwdT2), .q(FwdT2O));
	D_FF dffFwdT3 (.clk, .reset, .d(FwdT3), .q(FwdT3O));
	D_FF dffFwdT4 (.clk, .reset, .d(FwdT4), .q(FwdT4O));
	D_FF dffBrTaken (.clk, .reset, .d(BrTaken), .q(BrTakenO));
	
	// 9 bit dff
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit1
			D_FF d9 (.q(Imm9O[i]), .d(Imm9[i]), .reset, .clk);
		end
	endgenerate
	
	// 12 bit dff
	generate
		for (i = 0; i < 64; i++) begin : eachBit2
			D_FF d12 (.q(Imm12O[i]), .d(Imm12[i]), .reset, .clk);
		end
	endgenerate
	
endmodule

// Testbench to confirm unit is working correctly
module regfileread_queue_testbench();

	logic clk, reset, Swap, RdToRdA, RdToRdB, ShiftDir, 
					ShiftToALUB, Imm12ALU, ImmALUA,
					FwdT1, FwdT2, FwdT3, FwdT4, BrTaken;
	logic [5:0] Shamt;
	logic [11:0] Imm12;
	logic [8:0] Imm9;
	
	logic SwapO, RdToRdAO, RdToRdBO, ShiftDirO,
					ShiftToALUBO, Imm12ALUO, ImmALUAO,
					FwdT1O, FwdT2O, FwdT3O, FwdT4O, BrTakenO;
	logic [5:0] ShamtO;
	logic [11:0] Imm12O;
	logic [8:0] Imm9O;

	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	regfileread_queue dut (.*);
	
	initial begin
		reset <= 1'd0;	Swap <= 1'd0; RdToRdA <= 1'd0; RdToRdB <= 1'd0; 
		Imm12ALU <= 1'd0; ImmALUA <= 1'd0;								
		Imm9 <= 9'd0; Imm12 <= 12'd0;																			@(posedge clk);
		reset <= 1;																									@(posedge clk);
		reset <= 0; 																								@(posedge clk);
		
		Swap <= 1'd1; RdToRdA <= 1'd0; RdToRdB <= 1'd1; 
		Imm12ALU <= 1'd0; ImmALUA <= 1'd1;								
		Imm9 <= 9'd15; Imm12 <= 12'd20;																		@(posedge clk);
		
		Swap <= 1'd0; RdToRdA <= 1'd1; RdToRdB <= 1'd0; 
		Imm12ALU <= 1'd1; ImmALUA <= 1'd0;							
		Imm9 <= 9'd20; Imm12 <= 12'd25;																		@(posedge clk);
		
		Swap <= 1'd1; RdToRdA <= 1'd0; RdToRdB <= 1'd1; 
		Imm12ALU <= 1'd0; ImmALUA <= 1'd1;								
		Imm9 <= 9'd25; Imm12 <= 12'd30;																		@(posedge clk);
		
		$stop;
	end
endmodule
