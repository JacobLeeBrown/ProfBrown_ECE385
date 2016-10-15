//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Code - Program Counter Unit
// Module Name:    PCU
//
// Comments:
//------------------------------------------------------------------------------	
module PCU (
	input						Clk,
	input						Reset_ah,
	input						LD_PC,		// load control bit for PC register
	input				[1:0]	PCMUX,		// select bits for PC_MUX
	input				[15:0]Addr_out,	// 2nd option for PC_MUX
	output	wire	[15:0]PC_out,
   inout		wire	[15:0]Bus_Data			// 1st option for PC_MUX
);

logic	[15:0]	PC_in;

mux16_3to1	PC_MUX(	.Din_A(Bus_Data), 
					.Din_B(Added_ADDR),
					.Din_C(PC_out + 1'b1),	// incremented PC
					.sel(PCMUX), 
					.D_out(PC_in));
	
reg_16		PC_Reg( .Clk, 
					.Reset(Reset_ah),
					.Load(LD_PC), 
					.D_in(PC_in), 
					.D_out(PC_out));

endmodule
