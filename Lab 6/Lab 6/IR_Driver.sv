module IR_Driver(	input 	[15:0]	IR,
						output 	[3:0]		HEX0, HEX1, HEX2, HEX3);
						
assign HEX0 = IR[3:0];
assign HEX1 = IR[7:4];
assign HEX2 = IR[11:8];
assign HEX3 = IR[15:12];

endmodule
