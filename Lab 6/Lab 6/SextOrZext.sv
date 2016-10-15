module SEXT_5to16 (input [4:0] IN, output logic [15:0] OUT);
	
	always_comb
	begin
		if(IN[4] == 0)
			OUT <= (16'b0000000000000000 + IN);
		else
			OUT <= (16'b1111111111100000 + IN);
	end
endmodule

module SEXT_11to16 (input [10:0] IN, output logic [15:0] OUT);
	
	always_comb
	begin
		if(IN[10] == 0)
			OUT <= (16'b0000000000000000 + IN);
		else
			OUT <= (16'b1111100000000000 + IN);
	end
endmodule

module SEXT_9to16 (input [8:0] IN, output logic [15:0] OUT);
	
	always_comb
	begin
		if(IN[8] == 0)
			OUT <= (16'b0000000000000000 + IN);
		else
			OUT <= (16'b1111111000000000 + IN);
	end
endmodule


module SEXT_6to16 (input [5:0] IN, output logic [15:0] OUT);
	
	always_comb
	begin
		if(IN[5] == 0)
			OUT <= (16'b0000000000000000 + IN);
		else
			OUT <= (16'b1111111111000000 + IN);
	end
endmodule

module ZEXT_8to16 (input [7:0] IN, output logic [15:0] OUT);
	
	always_comb
	begin
		OUT <= (16'b0000000000000000 + IN);
	end
endmodule