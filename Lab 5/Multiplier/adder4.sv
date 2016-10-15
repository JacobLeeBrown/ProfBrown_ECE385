module adder4 (
	input [3:0] A, B,
	input c_in,
	output [3:0] S,
	output c_out
);
	wire c0, c1, c2;
	
	full_adder FA0 (.A (A[0]), .B (B[0]), .c_in (c_in), .S (S[0]), .c_out (c0));
	full_adder FA1 (.A (A[1]), .B (B[1]), .c_in (c0), .S (S[1]), .c_out(c1));
	full_adder FA2 (.A (A[2]), .B (B[2]), .c_in (c1), .S (S[2]), .c_out(c2));
	full_adder FA3 (.A (A[3]), .B (B[3]), .c_in (c2), .S (S[3]), .c_out(c_out));

endmodule
