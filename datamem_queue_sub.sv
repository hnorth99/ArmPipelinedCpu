`timescale 1ps/1ps
// This unit builds a singular dff for control logic in the regfileread pipeline stage.
// Recieves a clock and reset as well as all the required control logic from the decoder.
// Outputs values onto control logic name with O added to end
module datamem_queue_sub(clk, reset, ReadMem, RegWData, MemWr, FwdMem, ReadMemO, RegWDataO, MemWrO, FwdMemO);
	input logic clk, reset;
	input logic ReadMem, MemWr, FwdMem;
	input logic [1:0] RegWData;
	output logic ReadMemO, MemWrO, FwdMemO;
	output logic [1:0] RegWDataO;
	
	D_FF dffrd (.clk, .reset, .d(ReadMem), .q(ReadMemO));
	D_FF dffwr (.clk, .reset, .d(MemWr), .q(MemWrO));
	D_FF dffFwdMem (.clk, .reset, .d(FwdMem), .q(FwdMemO));
	
	genvar i;
	generate
		for (i = 0; i < 2; i++) begin : eachBit
			D_FF rwd (.clk, .reset, .d(RegWData[i]), .q(RegWDataO[i]));
		end
	endgenerate
	
endmodule

// Testbench to confirm unit is working correctly
module datamem_queue_sub_testbench();
	logic clk, reset;
	logic ReadMem, MemWr;
	logic ReadMemO, MemWrO;
	logic FwdMem, FwdMemO;
	logic [1:0] RegWData, RegWDataO;
	
	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	datamem_queue_sub dut (.*);
	
	initial begin
		reset <= 1'd0;	ReadMem <= 1'b0; RegWData <= 2'd0; MemWr <= 1'b0;							@(posedge clk);
		reset <= 1;																									@(posedge clk);
		reset <= 0; 																								@(posedge clk);
		
		ReadMem <= 1'b0; RegWData <= 2'd0; MemWr <= 1'b1;												@(posedge clk);
		ReadMem <= 1'b1; RegWData <= 2'd2; MemWr <= 1'b0;												@(posedge clk);							
		ReadMem <= 1'b1; RegWData <= 2'd2; MemWr <= 1'b1;												@(posedge clk);
		ReadMem <= 1'b0; RegWData <= 2'd2; MemWr <= 1'b0;												@(posedge clk);
		$stop;
	end
endmodule