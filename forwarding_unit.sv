module forwarding_unit(rd, rm, rn, rd_alu, rd_mem,
							  FwdALU, FwdMem, FwdT1, FwdT2, FwdT3, FwdT4,
							  fa, fb, da, db);
	input logic [4:0] rd, rm, rn, rd_alu, rd_mem;
	input logic FwdALU, FwdMem, FwdT1, FwdT2, FwdT3, FwdT4;
	output logic [1:0] fa, fb, da, db;
	
	always_comb begin
		fa = 2'b00; fb = 2'b00; da = 2'b00; db = 0;
		if (FwdMem && (rd_mem != 5'b11111)) begin
			if (FwdT1) begin
				if (rm == rd_mem) begin
					fa = 2'b01;
				end
				if (rn == rd_mem) begin
					fb = 2'b01;
				end
			end
			if (FwdT2) begin
				if (rn == rd_mem) begin
					fb = 2'b01; // from da
				end
			end
			if (FwdT3) begin
				if (rd == rd_mem) begin
					da = 2'b01; // from fb
				end
			end
			if (FwdT4) begin
				if (rd == rd_mem) begin
					fb = 2'b01; // from db
				end
			end
		end
		
		if(FwdALU && (rd_alu != 5'b11111)) begin
			if (FwdT1) begin
				if (rm == rd_alu) begin
					fa = 2'b10;
				end
				if (rn == rd_alu) begin
					fb = 2'b10;
				end
			end
			if (FwdT2) begin
				if (rn == rd_alu) begin
					fb = 2'b10; // from da
				end
			end
			if (FwdT3) begin
				if (rd == rd_alu) begin
					da = 2'b10; // from fb
				end
			end
			if (FwdT4) begin
				if (rd == rd_alu) begin
					fb = 2'b10; // from db
				end
			end
		end		
	end
	
endmodule
