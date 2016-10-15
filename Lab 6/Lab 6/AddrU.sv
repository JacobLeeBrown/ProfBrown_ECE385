//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    10/1/16
// Design Name:    ECE 385 Lab 6 - Address Unit
// Module Name:    AddrU
//
// Comments: Handles data for modifying the PC or loading a modified address
//		onto the data bus.
//------------------------------------------------------------------------------
module AddrU(	input logic [15:0] IR, SR1_out, PC_out,
					input logic ADDR1MUX,
					input logic [1:0] ADDR2MUX,
					output logic [15:0] Addr_out
);

// internal logic
logic [15:0] ADDR1MUX_out, ADDR2MUX_out;
logic [15:0] sext_IR10to0, sext_IR8to0, sext_IR5to0;

SEXT_11to16	Sexty_IR0(.IN(IR[10:0]), .OUT(sext_IR10to0));
SEXT_9to16	Sexty_IR1(.IN(IR[8:0]), .OUT(sext_IR8to0));
SEXT_6to16	Sexty_IR2(.IN(IR[5:0]), .OUT(sext_IR5to0));

mux16_2to1	ADDR1_MUX(
				.Din_A(PC_out),
				.Din_B(SR1_out),
				.sel(ADDR1MUX),
				.D_out(ADDR1MUX_out)
);

mux16_4to1	ADDR2_MUX(
				.Din_A(sext_IR10to0),
				.Din_B(sext_IR8to0),
				.Din_C(sext_IR5to0),
				.Din_D(16'b0),
				.sel(ADDR2MUX),
				.D_out(ADDR2MUX_out)
);

assign Addr_out = ADDR1MUX_out + ADDR2MUX_out;

endmodule
