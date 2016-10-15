//Datapath
module datapath(
	input					GatePC,
	input					GateMDR,
	input					GateALU,
	input					GateMARMUX,
	input		[15:0]	PC,
	input		[15:0]	MDR,
	input		[15:0]	ALU,
	input		[15:0]	MARMUX,
	output	[15:0]	D_out
);

// always block occurs when triggered by one of the inputs
always @ (PC or MDR or ALU or MARMUX or GatePC or GateMDR or GateALU or GateMARMUX)
	begin
		if(GatePC)
			D_out = PC;
		else if(GateMDR)
			D_out = MDR;
		else if(GateALU)
			D_out = ALU;
		else
			D_out = MARMUX;
	end

endmodule
