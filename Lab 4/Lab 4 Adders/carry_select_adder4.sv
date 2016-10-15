module carry_select_adder4
(
	input		logic[3:0]		A,
	input		logic[3:0]		B,
	input		logic				c_in,
	output	logic[3:0]		Sum,
	output	logic				CO
);

	wire c1, c2, o1;
	logic[3:0] Sum1, Sum2;
	
	adder4 FA4_0 (.A (A[3:0]), .B (B[3:0]), .c_in (0), .S (Sum1[3:0]), .c_out (c1));
	adder4 FA4_1 (.A (A[3:0]), .B (B[3:0]), .c_in (1), .S (Sum2[3:0]), .c_out (c2));
	mux4_2t1 mux1 (.DinA (Sum1[3:0]), .DinB (Sum2[3:0]), .sel (c_in), .Dout (Sum[3:0]));
	assign o1 = c2&c_in;
	assign CO = o1|c1;
	
endmodule