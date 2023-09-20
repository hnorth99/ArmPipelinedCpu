`timescale 1ps/1ps

// Unit that will handle the intructions within the processor. Decide how to increment 
// the program counter and properly release the next instruction.
module instruction_handler(clk, reset, imm26, imm19, uncondBr, brTaken, instr);
	input logic clk, reset;
	input logic [25:0] imm26;
	input logic [18:0] imm19;
	input logic uncondBr, brTaken;
	output logic [31:0] instr;
	
	// Out put current pc
	logic [63:0] pc_next, pc_curr;
	D_FF_64 d (.q(pc_curr), .d(pc_next), .reset, .clk); 
	
	// Sign extend imm addresses to 32 bit
	logic [63:0] ext_imm26, ext_imm19;
	sign_extender #(38) s1 (.in(imm26), .out(ext_imm26));
	sign_extender #(45) s2 (.in(imm19), .out(ext_imm19));
	
	// Mux for selecting imm branch address
	logic [63:0] imm;
	mux2_1_64x immMux (.i0(ext_imm19), .i1(ext_imm26), .sel(uncondBr), .out(imm));
	
	// Left shift 2
	logic [63:0] shift_imm;
	shift_left_2 s (.in(imm), .out(shift_imm));
	
	// Add pc value to imm value
	logic dummy_o, dummy_c;
	logic [63:0] pc_curr_minus_4;
	add_sub_64 minus4 (.a(pc_curr), .b(3'd4), .sub(1), .s(pc_curr_minus_4), 
							 .overflow(dummy_o), .carryout(dummy_c));
	
	logic [63:0] branch_addr;
	adder64 branchAdder (.a(pc_curr_minus_4), .b(shift_imm), .s(branch_addr));
	
	// Add 4 to the current pc value
	logic [63:0] addr_int, addr;
	adder64 add64 (.a(pc_curr), .b(64'd4), .s(addr_int));
	
	//D_FF_64 br (.clk, .reset, .d(branch_addr_int), .q(branch_addr));
	//D_FF_64 no_br (.clk, .reset, .d(addr_int), .q(addr));

	// Select if we want to take the normal +4 instruction or the branch
	mux2_1_64x pcMux (.i0(addr_int), .i1(branch_addr), .sel(brTaken), .out(pc_next));
	// Send output back into d_ff for next clock cycle
	
	instructmem imem (.address(pc_curr), .instruction(instr), .clk);
	
endmodule

module instruction_handler_testbench();
	logic clk, reset;
	logic [25:0] imm26;
	logic [18:0] imm19;
	logic uncondBr, brTaken;
	logic [31:0] instr;
	
	// Simulated clock for the testing
	parameter clock_period = 100000;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	instruction_handler dut (.*);
	
	initial begin
		imm26 <= '0; imm19 <= '0; uncondBr <= 0; brTaken <= 0;
		reset <= 0;													@(posedge clk);
		reset <= 1;																@(posedge clk);
		reset <= 0; 															@(posedge clk);
		
																		repeat(5)@(posedge clk);
		
		/*brTaken <= 1; uncondBr <= 1; imm26 <= 26'd42; imm19 <= 19'd11;
																					@(posedge clk);
						  uncondBr <= 0;										@(posedge clk);
		brTaken <= 0;												repeat(5)@(posedge clk);*/
		$stop;
	end
	
endmodule 