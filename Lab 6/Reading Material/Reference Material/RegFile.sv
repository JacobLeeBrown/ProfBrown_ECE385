//8x16 General Purpose Register (RegFile)
module RegFile (input  logic Clk, Reset, A_In, B_In,  C_In, D_In, E_In, F_In, G_In, H_In, 
									        Ld_A, Ld_B, Ld_C, Ld_D, Ld_E, Ld_F, Ld_G, Ld_H,
                                   Shift_En,
                      input  logic [15:0]  Data_In, 
                      output logic A_out, B_out, C_out, D_out, E_out, F_out, G_out, H_out,
                      output logic [15:0]  A,
                      output logic [15:0]  B,
							 output logic [15:0]  C,
							 output logic [15:0]  D,
							 output logic [15:0]  E,
							 output logic [15:0]  F,
							 output logic [15:0]  G,
							 output logic [15:0]  H);

    reg_16  reg_A (.*, .Shift_In(A_In), .D_in(Data_In), .Load(Ld_A),	//Inputs
	                .Shift_Out(A_out), .D_out(A));	
    reg_16  reg_B (.*, .Shift_In(B_In), .D_in(Data_In), .Load(Ld_B), //Outputs
	                .Shift_Out(B_out), .D_out(B));	
	 reg_16  reg_C (.*, .Shift_In(C_In), .D_in(Data_In), .Load(Ld_C),
	                .Shift_Out(C_out), .D_out(B));	
	 reg_16  reg_D (.*, .Shift_In(D_In), .D_in(Data_In), .Load(Ld_D),
	                .Shift_Out(D_out), .D_out(B));	
	 reg_16  reg_E (.*, .Shift_In(E_In), .D_in(Data_In), .Load(Ld_E),
	                .Shift_Out(E_out), .D_out(B));	
	 reg_16  reg_F (.*, .Shift_In(F_In), .D_in(Data_In), .Load(Ld_F),
	                .Shift_Out(F_out), .D_out(B));	
	 reg_16  reg_G (.*, .Shift_In(G_In), .D_in(Data_In), .Load(Ld_G),
	                .Shift_Out(G_out), .D_out(B));	
	 reg_16  reg_H (.*, .Shift_In(H_In), .D_in(Data_In), .Load(Ld_H),
	                .Shift_Out(H_out), .D_out(B));	

endmodule
