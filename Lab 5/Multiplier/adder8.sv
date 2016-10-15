module adder8 (
	input [7:0] A, B,
	input c_in,
	output [7:0] S,
	output c_out
);
	wire c0;

	adder4 A4_0 (.A (A[3:0]), .B (S[3:0]), .c_in (c_in), .S (S[3:0]), .c_out (c0));
	adder4 A4_1 (.A (A[7:4]), .B (S[7:4]), .c_in (c0), .S (S[7:4]), .c_out (c_out));

endmodule
