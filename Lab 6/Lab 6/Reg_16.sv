//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    9/24/16
// Design Name:    ECE 385 Lab 6 - 16 Bit Parallel Load Register
// Module Name:    reg_16
//
// Comments: Either resets or loads in the given data into the register
//------------------------------------------------------------------------------	
module reg_16 (	input  logic 			Clk, Reset, Load,
				input  logic [15:0]		D_in,
				output logic [15:0]		D_out);

	always_ff @ (posedge Clk)
	begin
		if (Reset) //notice, this is a sychronous reset, which is recommended on the FPGA
			D_out <= 16'h0;
		else if (Load)
			D_out <= D_in;
	end

endmodule
