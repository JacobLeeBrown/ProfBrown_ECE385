//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    9/24/16
// Design Name:    ECE 385 Lab 6 - 16 Bit 3:1 MUX
// Module Name:    mux16_3to1
//
// Comments:
//------------------------------------------------------------------------------
module mux16_3to1 (
	input	[15:0]	Din_A,
	input	[15:0]	Din_B,
	input	[15:0]	Din_C,
    input	[1:0]	sel,
    output  logic [15:0]	D_out
);

// always block occurs when triggered by one of the inputs
always @ (Din_A or Din_B or Din_C or sel)
	begin
		case (sel)
			2'b00 :		D_out = Din_A;	// if sel is 0
			2'b01 :		D_out = Din_B;	// if sel is 1
			default : 	D_out = Din_C;	// if sel is 2 (not 0 or 1)
		endcase
	end

endmodule
