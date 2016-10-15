module cl_fAdder
(
	input x, y, z,
	output s, g, p
);

	assign s = x^y^z;
	assign g = (x&y);
	assign p = (x^y);

endmodule