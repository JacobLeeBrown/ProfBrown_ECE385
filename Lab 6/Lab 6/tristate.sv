//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Given Code - Tristate buffer for SRAM
// Module Name:    tristate
//
// Comments:
//------------------------------------------------------------------------------

module tristate #(N = 16) (
	input wire Clk, OE,
	input [N-1:0] In,
	output logic [N-1:0] Out,
	inout wire [N-1:0] Data_Mem
);

logic [N-1:0] a, b;

assign Data_Mem = (OE ? a : {N{1'bZ}});
assign Out = b;

always_ff @(posedge Clk)
begin
	b <= Data_Mem;
	a <= In;
end

endmodule
