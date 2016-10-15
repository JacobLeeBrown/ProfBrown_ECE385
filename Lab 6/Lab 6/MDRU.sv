//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Code - Memory Data Register Unit
// Module Name:    MDRU
//
// Comments:
//------------------------------------------------------------------------------	
module MDRU (
	input							Clk,
	input							Reset_ah,
	input							LD_MDR,			// load control bit for PC register
	input							MIO_EN,			// select bit for MDR_MUX
	input				[15:0]	D_CPU_out,		// 2nd option for MDR_MUX
	output	wire	[15:0]	MDR_out,
   inout  	wire	[15:0]	Bus_Data			// 1st option for MDR_MUX
);

logic	[15:0]	MDR_in;

mux16_2to1	MDR_MUX(.Din_A(Bus_Data), 
					.Din_B(D_CPU_out),
					.sel(MIO_EN),
					.D_out(MDR_in));
					
reg_16		MDR_Reg(.Clk, 
					.Reset(Reset_ah), 
					.Load(LD_MDR), 
					.D_in(MDR_in),  
					.D_out(MDR_out));

endmodule
