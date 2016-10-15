module ripple_adder
(
	input		logic[15:0]     A,
	input		logic[15:0]     B,
	output	logic[15:0]     Sum,
	output	logic           CO
);

	wire c1, c2, c3;
	
	adder4 FA4_0 (.A (A[3:0]), .B (B[3:0]), .c_in (32'b0), .S (Sum[3:0]), .c_out (c1));
	adder4 FA4_1 (.A (A[7:4]), .B (B[7:4]), .c_in (c1), .S (Sum[7:4]), .c_out (c2));
	adder4 FA4_2 (.A (A[11:8]), .B (B[11:8]), .c_in (c2), .S (Sum[11:8]), .c_out (c3));
	adder4 FA4_3 (.A (A[15:12]), .B (B[15:12]), .c_in (c3), .S (Sum[15:12]), .c_out (CO));
     
endmodule
