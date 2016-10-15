module adder16 (
	input [15:0] A, B,
	input c_in,
	output [15:0] S,
	output c_out
);
	wire c0;

	adder8 A8_0 (.A (A[7:0]), .B (S[7:0]), .c_in (c_in), .S (S[7:0]), .c_out (c0));
	adder8 A8_1 (.A (A[15:8]), .B (S[15:8]), .c_in (c0), .S (S[15:8]), .c_out (c_out));

endmodule
