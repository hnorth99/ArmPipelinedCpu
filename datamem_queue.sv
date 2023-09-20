`timescale 1ps/1ps
// This unit builds the queue for control logic in the datamem pipeline stage.
// Recieves a clock and reset as well as all the required control logic from the decoder.
// Outputs values onto control logic name with O added to end
module datamem_queue(clk, reset, ReadMem, RegWData, MemWr, FwdMem, ReadMemO, RegWDataO, MemWrO, FwdMemO);
	input logic clk, reset;
	input logic ReadMem, MemWr, FwdMem;
	input logic [1:0] RegWData;
	output logic ReadMemO, MemWrO, FwdMemO;
	output logic [1:0] RegWDataO;
	
	logic r1, w1, fm1;
	logic [1:0] rwd1;
	datamem_queue_sub rm1 (.clk, .reset, .ReadMem, .RegWData, .MemWr, .FwdMem,
								  .ReadMemO(r1), .RegWDataO(rwd1), .MemWrO(w1), .FwdMemO(fm1));
	datamem_queue_sub rm2 (.clk, .reset, .ReadMem(r1), .RegWData(rwd1), .MemWr(w1), .FwdMem(fm1),
								  .ReadMemO, .RegWDataO, .MemWrO, .FwdMemO);
endmodule

// Testbench to confirm unit is working correctly
module datamem_queue_testbench();
	logic clk, reset;
	logic ReadMem, MemWr, FwdMem;
	logic ReadMemO, MemWrO, FwdMemO;
	logic [1:0] RegWData, RegWDataO;
	
	// Simulated clock for the testing
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period / 2) clk <= ~clk;
	end
	
	datamem_queue dut (.*);
	
	initial begin
		reset <= 1'd0;	ReadMem <= 1'b0; RegWData <= 2'd0; MemWr <= 1'b0;							@(posedge clk);
		reset <= 1;																									@(posedge clk);
		reset <= 0; 																								@(posedge clk);
		
		ReadMem <= 1'b0; RegWData <= 2'd0; MemWr <= 1'b1;												@(posedge clk);
		ReadMem <= 1'b1; RegWData <= 2'd2; MemWr <= 1'b0;												@(posedge clk);							
		ReadMem <= 1'b1; RegWData <= 2'd2; MemWr <= 1'b1;												@(posedge clk);
		ReadMem <= 1'b0; RegWData <= 2'd2; MemWr <= 1'b0;												@(posedge clk);
		ReadMem <= 1'b0; RegWData <= 2'd0; MemWr <= 1'b0;									repeat(4)@(posedge clk);
		$stop;
	end
endmodule