module full_adder
(
	input A, B, c_in,
	output S, c_out
);

	assign S = A^B^c_in;
	assign c_out = (A&B)|(B&c_in)|(A&c_in);

endmodule