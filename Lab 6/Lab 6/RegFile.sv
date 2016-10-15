//8x16 General Purpose Register (RegFile)
module reg_file(input Clk, Reset_ah, LD_REG,
					input logic [15:0] Bus_Data, 
					input logic [2:0] DR, SR1, SR2, 
					output logic [15:0] SR1_out, SR2_out
);

// All 8 registers, can just be logic since we dont need to shift
logic [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

// whenever the clock updates or the non-bus data inputs change
always_ff @ (Clk or DR or SR1 or SR2)
begin 
	if(LD_REG)	// loading from the data bus
		case(DR)
			3'b000: R0 <= Bus_Data;
			3'b001: R1 <= Bus_Data;
			3'b010: R2 <= Bus_Data;
			3'b011: R3 <= Bus_Data;
			3'b100: R4 <= Bus_Data;
			3'b101: R5 <= Bus_Data;
			3'b110: R6 <= Bus_Data;
			3'b111: R7 <= Bus_Data;
			default: ;
		endcase
		
	case(SR1)	// outputting to SR1
		3'b000: SR1_out <= R0;
		3'b001: SR1_out <= R1;
		3'b010: SR1_out <= R2;
		3'b011: SR1_out <= R3;
		3'b100: SR1_out <= R4;
		3'b101: SR1_out <= R5;
		3'b110: SR1_out <= R6;
		3'b111: SR1_out <= R7;
		default: ;
	endcase
	
	case(SR2)	// outputting to SR2
		3'b000: SR2_out <= R0;
		3'b001: SR2_out <= R1;
		3'b010: SR2_out <= R2;
		3'b011: SR2_out <= R3;
		3'b100: SR2_out <= R4;
		3'b101: SR2_out <= R5;
		3'b110: SR2_out <= R6;
		3'b111: SR2_out <= R7;
		default: ;
	endcase
	
end
endmodule	
