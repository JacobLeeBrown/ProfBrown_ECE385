//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    10/1/16
// Design Name:    ECE 385 Lab 6 - Register Unit
// Module Name:    RegU
//
// Comments: Contains the register file and all MUX's that interact with it or
//		it interacts with.
//------------------------------------------------------------------------------
module RegU(input Clk, Reset_ah, LD_REG,
					input logic [15:0] Bus_Data, IR,
					input logic DRMUX, SR1MUX, SR2MUX, 
					output logic [15:0] SR1_out, SR2_MUX_out
);

// internal wires
logic [2:0] DR, SR1;
logic [15:0] sext_IR, SR2_out;

SEXT_5to16	Sexty_IR(.IN(IR[4:0]), .OUT(sext_IR));

mux3_2to1	DR_MUX(.Din_A(IR[11:9]), .Din_B(3'b111), .sel(DRMUX), .D_out(DR));

mux3_2to1	SR1_MUX(.Din_A(IR[11:9]), .Din_B(IR[8:6]), .sel(SR1MUX), .D_out(SR1));

reg_file	Meme_bank(.*, .SR2(IR[2:0]));

mux16_2to1	SR2_MUX(.Din_A(sext_IR), .Din_B(SR2_out), .sel(IR[5]), .D_out(SR2_MUX_out));

endmodule
