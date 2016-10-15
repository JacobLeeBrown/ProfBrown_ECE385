module mux4_2t1 (
	input		[3:0] 	DinA,
	input		[3:0] 	DinB,
	input				 	sel,
	output	[3:0]		Dout
);
	
	always @ (DinA or DinB or sel)
	begin
		case (sel)
			1'b0 : Dout = DinA;
			default : Dout = DinB;
		endcase
	end

endmodule