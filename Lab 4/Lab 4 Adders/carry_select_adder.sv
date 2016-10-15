module carry_select_adder
(
	input		logic[15:0]		A,
	input		logic[15:0]		B,
	output	logic[15:0]		Sum,
	output	logic				CO
);

	wire c1, c2, c3;

	adder4 FA4 (.A (A[3:0]), .B (B[3:0]), .c_in (0), .S (Sum[3:0]), .c_out (c1));
	carry_select_adder4 CSA_0 (.A (A[7:4]), .B (B[7:4]), .c_in (c1), .Sum (Sum[7:4]), .CO (c2));
	carry_select_adder4 CSA_1 (.A (A[11:8]), .B (B[11:8]), .c_in (c2), .Sum (Sum[11:8]), .CO (c3));
	carry_select_adder4 CSA_2 (.A (A[15:12]), .B (B[15:12]), .c_in (c3), .Sum (Sum[15:12]), .CO (CO));
	
endmodule
