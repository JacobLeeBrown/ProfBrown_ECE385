module opposite8 (
	input [7:0] In,
	output [7:0] Out
);
	wire c0;
	// 8 bit adder takes in one bit-wise NOT-ed 8-bit value and adds 1, returning the 2'Compliment negative
	adder8 A8_0 (.A (~In[7:0]), .B (8'b0), .c_in (1), .S (Out[7:0]), .c_out (c0));

endmodule