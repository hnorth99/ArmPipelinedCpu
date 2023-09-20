// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:
// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alu(A, B, cntrl, result, negative, zero, overflow, carryout);
	input logic [63:0] A, B;
	input logic [2:0]  cntrl;
	output logic [63:0] result;
	output logic negative, zero, overflow, carryout;
	
	logic cout, oflow;
	// Result drivers
	logic [63:0] add_sub_wire, and_wire, or_wire, xor_wire;
	add_sub_64 as (.a(A), .b(B), .sub(cntrl[0]), .s(add_sub_wire), 
				      .overflow(oflow), .carryout(cout));
	bitwise_and_64 ba (.a(A), .b(B), .out(and_wire));
	bitwise_or_64 bo (.a(A), .b(B), .out(or_wire));
	bitwise_xor_64 bx (.a(A), .b(B), .out(xor_wire));
	
	// Determine result
	logic [63:0] result_wire;
	logic [63:0] result_driver [7:0];
	assign result_driver[0] = B;
	assign result_driver[1] = '0;
	assign result_driver[2] = add_sub_wire;
	assign result_driver[3] = add_sub_wire;
	assign result_driver[4] = and_wire;
	assign result_driver[5] = or_wire;
	assign result_driver[6] = xor_wire;
	assign result_driver[7] = '0;
	mux8_1_64x m8_1_64 (.i(result_driver), .sel(cntrl), .out(result_wire));
	assign result = result_wire;
	
	logic add_sub_sel;
	logic cntrl2_not;
	not #50 (cntrl2_not, cntrl[2]);
	and #50 (add_sub_sel, cntrl2_not, cntrl[1]);
	
	// Determine carryout flag
	mux2_1 m (.i0(1'b0), .i1(cout), .sel(add_sub_sel), .out(carryout));
	
	// Determine overflow flag
	mux2_1 m2 (.i0(1'b0), .i1(oflow), .sel(add_sub_sel), .out(overflow));
	
	// Determine negative flag
	assign negative = result_wire[63];
	
	// Determine zero flag
	nor_64 nor64 (.a(result_wire), .out(zero));

endmodule

module alu_testbench();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carryout ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carryout);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carryout == 0 && overflow == 0 && negative == 0 && zero == 0);
		A = '1; B = 64'd1;
		#(delay);
		assert(result == 64'd0 && carryout == 1 && overflow == 0 && negative == 0 && zero == 1);
		A = '1; B = '1;
		#(delay);
		assert(result == -64'd2 && carryout == 1 && overflow == 0 && negative == 1 && zero == 0);
		A = '0; B = '0;
		#(delay);
		assert(result == 64'd0 && carryout == 0 && overflow == 0 && negative == 0 && zero == 1);
		
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000000 && carryout == 1 && overflow == 0 && negative == 0 && zero == 1);
		A = '1; B = 64'd1;
		#(delay);
		assert(result == -64'd2 && carryout == 1 && overflow == 0 && negative == 1 && zero == 0);
		A = '1; B = '1;
		#(delay);
		assert(result == 64'd0 && carryout == 1 && overflow == 0 && negative == 0 && zero == 1);
		A = -64'd9223372036854775808; B = 1'd1;
		#(delay);
		assert(result == 64'd9223372036854775807 && carryout == 1 && overflow == 1 && negative == 0 && zero == 0);
		
		$display("%t testing and", $time);
		cntrl = ALU_AND;
		A = '0; B = '1;
		#(delay);
		assert(result == 64'h0000000000000000 && carryout == 0 && overflow == 0 && negative == 0 && zero == 1);
		A = 64'hF000A00000000000; B = 64'hF0000000CF000000;
		#(delay);
		assert(result == 64'hF000000000000000 && carryout == 0 && overflow == 0 && negative == 1 && zero == 0);
		A = '1; B = '1;
		#(delay);
		assert(result == '1 && carryout == 0 && overflow == 0 && negative == 1 && zero == 0);
		A = '0; B = '0;
		#(delay);
		assert(result == 64'h0000000000000000 && carryout == 0 && overflow == 0 && negative == 0 && zero == 1);
		
		$display("%t testing or", $time);
		cntrl = ALU_OR;
		A = '0; B = '1;
		#(delay);
		assert(result == '1 && carryout == 0 && overflow == 0 && negative == 1 && zero == 0);
		A = 64'hF000A00000000000; B = 64'hF0000000CF000000;
		#(delay);
		assert(result == 64'hF000A000CF000000 && carryout == 0 && overflow == 0 && negative == 1 && zero == 0);
		A = '1; B = '1;
		#(delay);
		assert(result == '1 && carryout == 0 && overflow == 0 && negative == 1 && zero == 0);
		A = '0; B = '0;
		#(delay);
		assert(result == 64'h0000000000000000 && carryout == 0 && overflow == 0 && negative == 0 && zero == 1);
		
		$display("%t testing xor", $time);
		cntrl = ALU_XOR;
		A = '0; B = '1;
		#(delay);
		assert(result == '1 && carryout == 0 && overflow == 0 && negative == 1 && zero == 0);
		A = 64'hF000A00000000000; B = 64'hF0000000CF000000;
		#(delay);
		assert(result == 64'h0000A000CF000000 && carryout == 0 && overflow == 0 && negative == 0 && zero == 0);
		A = '1; B = '1;
		#(delay);
		assert(result == '0 && carryout == 0 && overflow == 0 && negative == 0 && zero == 1);
		A = '0; B = '0;
		#(delay);
		assert(result == 64'h0000000000000000 && carryout == 0 && overflow == 0 && negative == 0 && zero == 1);
	end
endmodule
