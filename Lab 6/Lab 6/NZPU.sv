//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Jacob Brown
//
// Create Date:    10/2/16
// Design Name:    ECE 385 Lab 6 - NZP Unit
// Module Name:    NZPU
//
// Comments: Handles calculating and storing NZP and Ben
//------------------------------------------------------------------------------
module NZPU(input Clk, Reset_ah, LD_CC, LD_BEN,
					input logic [15:0] Bus_Data,
					input logic [2:0] NZP,
					output logic BEN
);

logic n, z, p;

always_ff @ (posedge Clk or posedge Reset_ah)
begin	
	if (Reset_ah) 
		begin
			n <= 0;
			z <= 0;
			p <= 0;
		end
	else if (LD_CC)	
		begin
			if(Bus_Data == 16'b0) 
				begin
					n <= 0;
					z <= 1;
					p <= 0;
				end 
			else if (Bus_Data[15] == 1) 
				begin
					n <= 1;
					z <= 0;
					p <= 0;
				end 
			else if (Bus_Data[15] == 0)
				begin
					n <= 0;
					z <= 0;
					p <= 1;
				end
		end
end	

always_comb
begin
	if (((NZP & {n, z, p}) != 3'b0) && LD_BEN)
		BEN <= 1;
	else
		BEN <= 0;
end

endmodule
