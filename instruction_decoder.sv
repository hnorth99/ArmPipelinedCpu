// Module will decode an instruction to set the proper control logic and 
// the read in values to the processor.
module instruction_decoder(clk, instruction, LT, ALU_Zero,
									UncondBr, BrTaken, ImmALUA, RegWrite, 
									RdToRdB, Imm12ALU, RegWData, ShiftToALUB, ShiftDir,
									ReadMem, MemWr, RdToRdA, ALUCntrl, FlagE,
									FwdALU, FwdMem, FwdT1, FwdT2, FwdT3, FwdT4,
									rd, rm, rn, imm26, imm19, imm12, imm9,
									shamt, swap);
									
	input logic [31:0] instruction;
	input logic LT, clk;
	input logic [63:0] ALU_Zero;
	output logic 		 UncondBr, BrTaken, ImmALUA, RegWrite, RdToRdB, Imm12ALU, 
							 ShiftToALUB, ShiftDir, ReadMem, MemWr, RdToRdA, FlagE, swap,
							 FwdALU, FwdMem, FwdT1, FwdT2, FwdT3, FwdT4;
	output logic [1:0] RegWData;
	output logic [2:0] ALUCntrl;
	output logic [4:0] rd, rm, rn;
	output logic [25:0] imm26;
	output logic [18:0] imm19;
	output logic [11:0] imm12;
	output logic [8:0]  imm9;
	output logic [5:0]  shamt;
	
	logic [23:0] control_code;
		
	logic zero;
	nor_64 nor64 (.a(ALU_Zero), .out(zero));
	
	enum {ADDI, ADDS, B, BLT, CBZ, LDUR, LSL, LSR, MUL, STUR, SUBS} operation;
	always_comb begin
		//I type:
		// ADDI : 0x244 = 10 0100 0100
		// [31:22] = OPCODE
		// [21:10] = imm12
		// [09:05] = rn
		// [04:00] = rd
		case (instruction[31:22])
			10'b1001000100: begin 
									operation = ADDI;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = instruction[21:10];
									imm9      = 9'bX;
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = 5'bX;
									shamt		 = 6'bX;
								 end
		endcase
		
		//D type:
		//	STUR : 0x7C0
		// LDUR : 0x7C2
		// [31:21] = OPCODE
		// [20:12] = imm9
		// [11:10] = 00
		// [09:05] = rn
		// [04:00] = rd
		case (instruction[31:21])
			11'b11111000000: begin 
									operation = STUR;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = instruction[20:12];
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = 5'bX;
									shamt		 = 6'bX;
								 end
			11'b11111000010: begin 
									operation = LDUR;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = instruction[20:12];
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = 5'bX;
									shamt		 = 6'bX;
								 end
		endcase
		
		//B type: 
		// B : 0x05
		// [31:26] = OPCODE
		// [25:00] = imm26
		case (instruction[31:26])
			6'b000101: begin 
									operation = B;
									imm26 	 = instruction[25:00];
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = 5'bX;
									rd 		 = 5'bX;
									rm			 = 5'bX;
									shamt		 = 6'bX;
						  end
		endcase
		
		//CB type:
		// B.LT : 0x54
		// CBZ : 0xB4
		// [31:24] = OPCODE
		// [23:05] = imm19
		// [04:00] = rd
		case (instruction[31:24])
			8'b01010100: begin 
									operation = BLT;
									imm26 	 = 26'bX;
									imm19     = instruction[23:05];
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = 5'bX;
									rd 		 = instruction[04:00];
									rm			 = 5'bX;
									shamt		 = 6'bX;
						  end
			8'b10110100: begin 
									operation = CBZ;
									imm26 	 = 26'bX;
									imm19     = instruction[23:05];
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = 5'bX;
									rd 		 = instruction[04:00];
									rm			 = 5'bX;
									shamt		 = 6'bX;
						  end
		endcase
		
		//R type:
		// ADDS : 0x558
		// SUBS : 0x758
		// LSL : 0x69B
		// LSR : 0x69A
		// MUL : 0x4D8
		// [31:21] = OPCODE
		// [20:16] = rm
		// [15:10] = shamt
		// [09:05] = rn
		// [04:00] = rd
		case (instruction[31:21])
			11'b10101011000: begin 
									operation = ADDS;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = instruction[20:16];
									shamt		 = instruction[15:10];
								 end
			11'b11101011000: begin 
									operation = SUBS;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = instruction[20:16];
									shamt		 = instruction[15:10];
								 end
			11'b11010011011: begin 
									operation = LSL;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = instruction[20:16];
									shamt		 = instruction[15:10];
								 end
			11'b11010011010: begin 
									operation = LSR;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = instruction[20:16];
									shamt		 = instruction[15:10];
								 end
			11'b10011011000: begin 
									operation = MUL;
									imm26 	 = 26'bX;
									imm19     = 19'bX;
									imm12 	 = 12'bX;
									imm9      = 9'bX;
									rn 		 = instruction[09:05];
									rd 		 = instruction[04:00];
									rm			 = instruction[20:16];
									shamt		 = 5'b11111;
								 end
		endcase
	end
	
	always_comb begin
		case (operation)
			ADDI: control_code = 24'b000111X01101000XX0X01000;
			ADDS: control_code = 24'b000111X0010X000XX0001010;
			B: 	control_code = 24'bXXXX0011X0XXXXXXX0XXXX00;
			BLT: 	begin
						if(LT) begin 
							control_code = 24'bXXXX0001X0XXXXXXX0XXXX00;
						end
						else begin
							control_code = 24'bXXXX0000X0XXXXXXX0XXXX00;
						end
					end
			CBZ: 	begin
						if(zero) begin 
							control_code = 24'b10000001X01XXX0XX0X00000;
						end
						else begin
							control_code = 24'b10000000X01XXX0XX0X00000;
						end
					end
			LDUR: control_code = 24'b001010X01100010X10X01000;
			LSL:	control_code = 24'b000111X0X10X0010X0X00000;
			LSR:	control_code = 24'b000111X0X10X0011X0X00000;
			MUL:	control_code = 24'b000111X0X10X10XXX00XXX00;
			STUR:	control_code = 24'b011000X01000XX0XX1101000;
			SUBS:	control_code = 24'b000111X0010X000XX0001111;
		endcase
	end
	
	assign FwdT4 			= control_code[23];
	assign FwdT3 			= control_code[22];
	assign FwdT2 			= control_code[21];
	assign FwdT1 			= control_code[20];
	assign FwdMem 			= control_code[19];
	assign FwdALU  		= control_code[18];
	assign UncondBr 		= control_code[17];
	assign BrTaken  		= control_code[16];
	assign ImmALUA	 		= control_code[15];
	assign RegWrite 		= control_code[14];
	assign RdToRdB  		= control_code[13];
	assign Imm12ALU 		= control_code[12];
	assign RegWData 		= control_code[11:10];
	assign ShiftToALUB 	= control_code[09];
	assign ShiftDir		= control_code[08];	
	assign ReadMem			= control_code[07];
	assign MemWr			= control_code[06];
	assign RdToRdA			= control_code[05];
	assign ALUCntrl		= control_code[04:02];
	assign FlagE			= control_code[01];
	assign swap				= control_code[00];
	
endmodule