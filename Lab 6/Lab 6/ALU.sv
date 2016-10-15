//ALU
module ALU(input logic [1:0] ALUK,
			  input logic [15:0] A, B,
			  output logic [15:0] ALU_out
); 	 

//MUX functionality
always_comb
begin
	unique case(ALUK)
		2'b00: //ADD two 16-bit numbers, output 16-bit output and carry-out bit.
				ALU_out = (A + B);
		2'b01: //AND
				ALU_out = (A & B);
		2'b10: //NOT A
				ALU_out = (~A);
		default: //PASS A
				ALU_out = (A);
	endcase
end

endmodule
