`timescale 1ps/1ps
// This builds our regfile unit out of a 5to32 decoder, 32 64 bit registers,
// and two different sets of 64 32 to 1 muxs.
// Module receives a clk to coordinate timing. 
// WriteRegister (5 bits) input is used to select with register will recieve 
// WriteData (64 bits) when RegWrite bit is high.
// 64 bit data is read out onto ReadData1 and ReadData2 that corresponds to the 
// register selected by the 5 bit ReadRegister1 and ReadRegister2 inputs.
module regfile(clk, WriteRegister, RegWrite, WriteData, ReadRegister1, ReadRegister2, ReadData1, ReadData2);

	input logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0]	WriteData;
	input	logic 			RegWrite, clk;
	output logic [63:0]	ReadData1, ReadData2;
	
	// Intermediate logic holders
	logic [31:0] o; // This is used to mark the register that is being written to
	logic [63:0] dout [31:0]; // This is the data being sent from registers
	
	edecoder5_32 dec(.i(WriteRegister), .e(RegWrite), .o(o));
	register64_32x r64_32(.clk(clk), .reset(1'b0), .din(WriteData), .en(o), .dout(dout));
	mux32_1_64x m32_1x64_1(.i(dout), .sel(ReadRegister1), .out(ReadData1));
	mux32_1_64x m32_1x64_2(.i(dout), .sel(ReadRegister2), .out(ReadData2));
endmodule

module regfile_testbench(); 		
	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$stop;
	end
endmodule
