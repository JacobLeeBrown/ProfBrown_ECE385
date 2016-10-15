//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    9/24/16
// Design Name:    ECE 385 Lab 6 - 3 Bit 2:1 MUX
// Module Name:    mux3_2to1
//
// Comments:
//------------------------------------------------------------------------------
module mux3_2to1 (
	input	[2:0]	Din_A,
	input	[2:0]	Din_B,
    input	[1:0]	sel,
    output  logic [2:0]	D_out
);

// always block occurs when triggered by one of the inputs
always @ (Din_A or Din_B  or sel)
	begin
		case (sel)
			1'b0 :		D_out = Din_A;	// if sel is 0
			default :	D_out = Din_B;	// if sel is 1 (not 0)
		endcase
	end

endmodule
