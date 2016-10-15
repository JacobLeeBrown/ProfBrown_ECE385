module carry_lookahead_adder4
(
	input		logic[3:0]     A,
	input		logic[3:0]     B,
	input		logic				c_in,
	output	logic[3:0]     Sum,
	output	logic          CO
);
		
	logic[3:0]	G, P;
	wire c1, c2, c3;

	cl_fAdder CLA00 (.x (A[0]), .y (B[0]), .z (c_in), .s (Sum[0]), .g (G[0]), .p (P[0]));
	assign c1 = G[0]|(P[0]&c_in);
	cl_fAdder CLA01 (.x (A[1]), .y (B[1]), .z (c1), .s (Sum[1]), .g (G[1]), .p (P[1]));
	assign c2 = G[1]|(P[1]&c1);
	cl_fAdder CLA02 (.x (A[2]), .y (B[2]), .z (c2), .s (Sum[2]), .g (G[2]), .p (P[2]));
	assign c3 = G[2]|(P[2]&c2);
	cl_fAdder CLA03 (.x (A[3]), .y (B[3]), .z (c3), .s (Sum[3]), .g (G[3]), .p (P[3]));
	assign CO = G[3]|(P[3]&c3);
     
endmodule