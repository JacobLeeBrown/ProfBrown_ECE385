module adder9 ( //Specialized adder for implementation in lab 5
	input [7:0] A, S,
	output [7:0] Out,
	output X
);
	wire c0, c1;

	adder8 A8_0 (.A(A[7:0]), .B (S[7:0]), .c_in (0), .S (Out[7:0]), .c_out (c0));
	full_adder FA (.A (A[7]), .B (S[7]), .c_in (c0), .S (X), .c_out (c1));

endmodule
