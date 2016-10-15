//Status Register_3 (nzp)
module reg_3 (	input		logic 			Clk, Reset, LD_CC,
					input		logic [15:0]	D,
					input		logic [2:0]		NZP,
					output	logic 			n, z, p, BEN);

    always_ff @ (posedge Clk)
    begin
		if (Reset) //notice, this is a sychronous reset, which is recommended on the FPGA
			begin
				n = 1'b0;
				z = 1'b0;
				p = 1'b0;
			end
		else if (LD_CC) //synchronous load
			begin
				if(D[15:0] == 16'b0)
					begin
						n = 1'b0;
						z = 1'b1;
						p = 1'b0;
					end
				else if(D[15] == 1'b1)
					begin
						n = 1'b1;
						z = 1'b0;
						p = 1'b0;
					end
				else if(D[15] == 1'b0)
					begin
						n = 1'b0;
						z = 1'b0;
						p = 1'b1;
					end
			end
		else				//Cycle same data if LD_CC and Reset are both low
			n <= n;
			z <= z;
			p <= p;
   end
	
	always_comb
	begin
		if ((NZP & {n, z, p}) != 0)
			BEN <= 1;
		else
			BEN <= 0;
	end

endmodule
