//This file can be used instead of the Multiplier.sv and Lab_5_Multiplier_TopLevel.sv 
// files. Don't use either of those two files if replacing with this one (new toplevel)

module NewMultiplierTopLevel(input  logic  Clk,  // Internal
                                Reset,   		// Push button 0
                                ClearA_LoadB,   // Push button 1
                                Run,	  		// Push button 2
					input  logic [7:0]  S,        // Input data from switches
					output logic  	X,		         // Sign-extend bit
										M,					// DEBUG
					output logic [7:0]   Aval,    // DEBUG
												Bval,    // DEBUG
               output logic [6:0]   AhexL,	// Output values for hex displays
												AhexU,
												BhexL,
												BhexU);

    //Local Variables
	logic A_Out, B_Out;                         //1-bit output from each register shift
	logic [7:0] A, B, S_2comp, adder_In;        //8-bit parallel out from both registers, and 
	                                            //  2's compliment of switch input
	logic [8:0] Sum;                            //9-bit output from adder9 module
	
	// Control variables
	logic   Shift_En_local,                     //Shift-enable bit (on both registers)
	        Add,                                //1-bit add signal
	        Subtr,                              //1-bit subtract signal
			  LoadA_,									  //Local var for LoadA signal out of control logic
			  S_SH;									  
	
	always @(Add)
	begin
		if(Add)                                  //Either add
			adder_In = S_SH;
		else                                     //Or subtract
			adder_In = S_2comp;
	end
	
	// Invert the "active-low" switches
	logic Reset_SH, ClearA_LoadB_SH, Run_SH;       //_h for "high"
//	always_comb
//	begin
//		Reset_h = ~Reset;
//		ClearA_LoadB_h= ~ClearA_LoadB;
//		Run_h = ~Run;
//	end


    //Instantiate modules
	adder9 Adder9(.*,
						.A(A),                          //Register A input
						.S(adder_In),                   //8-bit input from switches
						.Out(Sum[7:0]),                 //8-bit output from adder
						.X(Sum[8]));                    //1-bit sign-extend from adder
						
	opposite8 twoscompliment(.In(S_SH),            //8-bit In from switches
	                         .Out(S_2comp));       //8-bit Out (2's Compliment)
						
	control	Control_unit(.*,
						.Reset(Reset_SH),               //Reset in = inverted Reset button
						.ClearA_LoadB(ClearA_LoadB_SH), //ClearA_LoadB = inverted ClearA_LoadB 
						                                //  button
						.Run(Run_SH),                   //Run in = inverted Run button
						.M_in (B_Out),                  //Connect register B's shift-out bit to 
						                                //  M_in on control unit
						.Shift_En(Shift_En_local),      //Shift-enable (output) loads into local
						                                //  var
						.ClA_LdB,                       //ClA_LdB (output)
						.LoadA(LoadA_),                 //LoadA (output)
						.Add(Add),                      //Add signal (output) loads into local var
						.Subtr(Subtr));                 //Subtr signal (output) loads into local
						                                //  var
						
	reg_8		Reg_A(.*,
						.Reset(ClA_LdB || Reset_SH),    //ClA_LdB or Reset button will determine when to clear regA
						                                 //  , or Reset_h button will also clear it
						.Shift_In(X),                   //Sign-extend bit from adder9
						.Load(LoadA_),            		  //Load signal comes from Control_unit out
						.D(Sum[7:0]),                   //Data-in comes from 8-but Sum of adder9
						.Shift_En(Shift_En_local),
						.Shift_Out(A_Out),              //A_Out is also the shift-in for regB
						.Data_Out(A));                  //Parallel data out
					
	reg_8		Reg_B(.*,
						.Reset(Reset_SH),               //Reset register when reset is pressed
						.Shift_In(A_Out),               //A_Out shifts into regB
						.Load(ClA_LdB),                 //Load signal comes from ClA_LdB output 
						                                //  logic of "Control_unit"
						.D(S),                       //Data-in from switches
						.Shift_En(Shift_En_local),
						.Shift_Out(B_Out),              //B_Out is assigned to M later
						.Data_Out(B));	
						
	
	HexDriver HexAL (
						.In0(A[3:0]),
                  .Out0(AhexL));
	HexDriver HexAU (
                  .In0(A[7:4]),
                  .Out0(AhexU));
	HexDriver HexBL (
                  .In0(B[3:0]),
                  .Out0(BhexL));
	HexDriver HexBU (
                  .In0(B[7:4]),
                  .Out0(BhexU));
                  
                  
    //Assignments (simple combinational logic)
	assign Aval = A;                            //8-bit output logic = contents of regA
	assign Bval = B;                            //8-bit output logic = contents of regB
	assign M = B_Out;                           //1-bit output logic M = shift-out bit of regB
							
	sync button_sync[2:0] (Clk, {~Reset, ~ClearA_LoadB, ~Run}, {Reset_SH, ClearA_LoadB_SH, Run_SH});
	sync S_sync[7:0] (Clk, S, S_SH);
	
endmodule
