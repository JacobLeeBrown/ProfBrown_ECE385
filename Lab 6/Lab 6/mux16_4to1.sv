//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    9/24/16
// Design Name:    ECE 385 Lab 6 - 16 Bit 4:1 MUX
// Module Name:    mux16_4to1
//
// Comments:
//------------------------------------------------------------------------------
module mux16_4to1 (
	input	[15:0]	Din_A,
	input	[15:0]	Din_B,
	input	[15:0]	Din_C,
	input	[15:0]	Din_D,
    input	[1:0]	sel,
    output  logic [15:0]	D_out
);

// always block occurs when triggered by one of the inputs
always @ (Din_A or Din_B or Din_C or Din_D or sel)
	begin
		case (sel)
			2'b00 :		D_out = Din_A;	// if sel is 0
			2'b01 :		D_out = Din_B;	// if sel is 1
			2'b10 :		D_out = Din_C;	// if sel is 2
			default : 	D_out = Din_D;	// if sel is 3 (not 0, 1, or 2)
		endcase
	end

endmodule
