// Single cycle processor used to run the arm instructions
// provided in canvas.
`timescale 1ps/1ps
module processor(clk, reset);
	input logic clk, reset;
	
	logic LT, ALU_Zero, UncondBr, BrTaken, ImmALUA, RegWrite;
	logic RdToRdB, Imm12ALU, ShiftToALUB, ShiftDir;
	logic ReadMem, MemWr, RdToRdA, FlagE, swap,
			FwdALU, FwdMem, FwdT1, FwdT2, FwdT3, FwdT4;
	logic [02:0] ALUCntrl;
	logic [01:0] RegWData;
	logic [04:0] rd, rm, rn;
	logic [05:0] shamt;
	logic [31:0] instruction;
	logic [25:0] imm26;
	logic [18:0] imm19;
	logic [11:0] imm12;
	logic [08:0] imm9;
	logic [63:0] B;
	
	/************************* IF Stage ******************************************************/		
	instruction_handler ih (.clk, .reset, .imm26, .imm19, .uncondBr(UncondBr), .brTaken(BrTaken), .instr(instruction));
	/************************* IF STAGE END **************************************************/	
	
	/*************************CONTROL LOGIC QUEUES ******************************************************/		
	
	// Control Logic Queue for ALU Pipeline Stage
	logic ShiftDirO, ShiftToALUBO;
	logic [5:0] ShamtO;
	logic [2:0] ALUCntrlO;
	logic FlagEO, FwdALUO;
	alu_queue aq (.clk, .reset, .ALUCntrl, .FlagE, .FwdALU, .ShiftDir, .ShiftToALUB, .Shamt(shamt),
					  .ALUCntrlO, .FlagEO, .FwdALUO, .ShiftDirO, .ShiftToALUBO, .ShamtO);
	
	// Control Logic Queue for DataMem Pipeline Stage
	logic ReadMemO, MemWrO, FwdMemO;
	logic [1:0] RegWDataO;
	datamem_queue dmq (.clk, .reset, .ReadMem, .RegWData, .MemWr, .FwdMem, .ReadMemO, .RegWDataO, .MemWrO, .FwdMemO);
	
	// Control Logic Queue for RegFileWrite Stage
	logic RegWrtO;
	logic [4:0] RdO;
	regfilewrite_queue rfwq (.clk, .reset, .RegWrt(RegWrite), .Rd(rd), .RegWrtO, .RdO);
	/************************* END CONTROL LOGIC QUEUES ***************************************************/
	
	/************************* PIPELINE: REG/DECODE STAGES *********************************************************/
	logic [31:0] instruction_out;
	genvar i;
	generate
		for (i = 0; i < 32; i++) begin : eachBit2
			D_FF d (.q(instruction_out[i]), .d(instruction[i]), .reset, .clk);
		end
	endgenerate
	
	instruction_decoder id (.clk, .instruction(instruction_out), .LT, .ALU_Zero(B),
									.UncondBr, .BrTaken, .ImmALUA, .RegWrite, 
									.RdToRdB, .Imm12ALU, .RegWData, .ShiftToALUB, .ShiftDir,
									.ReadMem, .MemWr, .RdToRdA, .ALUCntrl, .FlagE,
									.FwdALU, .FwdMem, .FwdT1, .FwdT2, .FwdT3, .FwdT4,
									.rd, .rm, .rn, .imm26, .imm19, .imm12, .imm9,
									.shamt, .swap);
											 
	// Register for regfilewrite stage
	logic [63:0] write_data, write_data_reg, emptyB, emptyC;
	logic [63:0] alu_out;
	register64_3x rfwritegate (.clk, .reset, .a(write_data), .b('0), .c('0),
										.outA(write_data_reg), .outB(emptyB), 
										.outC(emptyC));
	
	logic [4:0] rm_post, rn_post;
	swap sw (.i0(rm), .i1(rn), .swap, .out0(rm_post), .out1(rn_post));
									
	logic [04:0] rda, rdb;
	logic inverted_clk;
	logic [63:0] mul_out, wdata, dA, dB;
	not #50 inv (inverted_clk, clk);	
	mux2_1_5x rdtora_mux (.i0(rm_post), .i1(rd), .sel(RdToRdA), .out(rda));
	mux2_1_5x rdtorb_mux (.i0(rn_post), .i1(rd), .sel(RdToRdB), .out(rdb));
	regfile	r (.clk(inverted_clk), .WriteRegister(RdO), .RegWrite(RegWrtO), .WriteData(write_data_reg), 
				   .ReadRegister1(rda), .ReadRegister2(rdb), .ReadData1(dA), .ReadData2(dB));
					
	logic [63:0] zeimm12, seimm9, imm, ALUA;				
	zero_extender #(52) imm12_ze (.in(imm12), .out(zeimm12));
	sign_extender #(55) imm9_se (.in(imm9), .out(seimm9));
	mux2_1_64x imm12alu_mux (.i0(seimm9), .i1(zeimm12), .sel(Imm12ALU), .out(imm));
	mux2_1_64x immalu_mux (.i0(dA), .i1(imm), .sel(ImmALUA), .out(ALUA));					  
	
	logic [1:0] dataA, fa, fb;
	logic [63:0] dA_post, dB_post, A;
	mux4_1_64x da_fwd (.i00(dA), .i01(write_data), .i10(alu_out), .i11('0),
							 .sel0(dataA[0]), .sel1(dataA[1]), .out(dA_post)); //dA_post passed forward 
	//mux4_1_64x db_fwd (.i00(dB), .i01(write_data), .i10(alu_out), .i11('0), 
	//						 .sel0(dataB[0]), .sel1(dataB[1]), .out(dB_post)); //dB_post passed forward 
	mux4_1_64x fa_fwd (.i00(ALUA), .i01(write_data), .i10(alu_out), .i11('0),
							 .sel0(fa[0]), .sel1(fa[1]), .out(A)); 				//A passed forward 
	mux4_1_64x fb_fwd (.i00(dB), .i01(write_data), .i10(alu_out), .i11('0), 
							 .sel0(fb[0]), .sel1(fb[1]), .out(B)); 				//B passed forward 
	
	logic [63:0] mult_dummy;
	mult m (.A(dA_post), .B(B), .doSigned(1'b1), .mult_low(mul_out), .mult_high(mult_dummy)); //mul_out passed forward
	/************************* PIPELINE: REGFILE STAGES END **************************************************/

	/************************* PIPELINE: ALU STAGE  *********************************************************/
	// Register for ALU/EXEC stage
	logic [63:0] da_alu;
	D_FF_64 daalu (.clk, .reset, .d(dA_post), .q(da_alu));									//da_alu passed forward
	logic [63:0] a_alu, b_alu, mulout_alu;
	logic [4:0] rd_alu;																			
	register5 rd_alugate(.clk, .reset, .din(rd), .en(1), .dout(rd_alu));			//rd_alu passed forward
	register64_3x alugate (.clk, .reset, .a(A), .b(B), .c(mul_out),
										.outA(a_alu), .outB(b_alu), .outC(mulout_alu)); //mulout_alu passed forward
	
	logic [63:0] shiftres, ALUB;
	shifter s (.value(b_alu), .direction(ShiftDirO), .distance(ShamtO), .result(shiftres));
	mux2_1_64x shifttoalub_mux (.i0(b_alu), .i1(shiftres), .sel(ShiftToALUBO), .out(ALUB));
	
	logic ALU_Neg, ALU_Oflow, ALU_Cout;
	alu al_unit (.A(a_alu), .B(ALUB), .cntrl(ALUCntrlO), .result(alu_out), .negative(ALU_Neg), .zero(ALU_Zero), 
					 .overflow(ALU_Oflow), .carryout(ALU_Cout)); 						//alu_out passed forward
	
	logic zflag, oflag, nflag, cflag;
	flag_handler fh (.clk, .reset, .en(FlagEO), .zero_in(ALU_Zero), .oflow_in(ALU_Oflow), .neg_in(ALU_Neg), 
							.cout_in(ALU_Cout), .zero(zflag), .overflow(oflag), .negative(nflag), .carry_out(cflag));
	xor #50 lt (LT, oflag, nflag);
	/************************* PIPELINE: ALU STAGE END  ******************************************************/
	
	/************************* PIPELINE: DATAMEM STAGE  ******************************************************/
	// Register for ALU/EXEC stage
	logic [63:0] da_datamem, aluout_datamem, mulout_datamem, mem_out;
	logic [4:0] rd_mem;
	register5 rd_datamem(.clk, .reset, .din(rd_alu), .en(1), .dout(rd_mem));			//rd_mem passed forward
	register64_3x datamemgate (.clk, .reset, .a(alu_out), .b(mulout_alu), .c(da_alu),
										.outA(aluout_datamem), .outB(mulout_datamem), .outC(da_datamem));
	
	datamem mem (.address(aluout_datamem), .write_enable(MemWrO), .read_enable(ReadMemO), .write_data(da_datamem), 
				    .clk, .xfer_size(4'b1000), .read_data(mem_out));								
					 
	mux4_1_64x wdata_mux (.i00(aluout_datamem), .i01(mem_out), .i10(mulout_datamem), 
								 .i11('0), .sel0(RegWDataO[0]), .sel1(RegWDataO[1]), .out(write_data));
																														// 
	/************************* PIPELINE: DATAMEM STAGE END  ******************************************************/
	
	/************************* Forwarding  ***********************************************************************/
	forwarding_unit f (.rd, .rm(rm_post), .rn(rn_post), .rd_alu, .rd_mem,
							 .FwdALU(FwdALUO), .FwdMem(FwdMemO), .FwdT1, .FwdT2, .FwdT3, .FwdT4,
							 .fa, .fb, .da(dataA), .db(dataB));
	/************************* Forwarding END  *******************************************************************/
	
endmodule

module processor_testbench();
	logic clk, reset;
	
	// Simulated clock for the testing
	parameter clock_period = 50000;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	processor dut (.*);
	
	initial begin
		reset <= 1; 				  	  @(posedge clk);
		reset <= 0;			repeat(800)@(posedge clk);
		$stop;
	end
endmodule