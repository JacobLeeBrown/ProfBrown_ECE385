//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//------------------------------------------------------------------------------
//Instruction Sequencer Decoder Unit (state controller)
module ISDU (input		 Clk, 
								 Reset,
								 Run,
								 Continue,
								 ContinueIR,
									
				input [3:0]  Opcode,
				input        IR_5,
				input 		 BEN,
				  
				output logic LD_MAR,
								 LD_MDR,
								 LD_IR,
								 LD_BEN,
								 LD_CC,
								 LD_REG,
								 LD_PC,
									
				output logic GatePC,
								 GateMDR,
								 GateALU,
								 GateMARMUX,
									
				output logic [1:0] PCMUX,
				output logic 		 DRMUX,
										 SR1MUX,
										 SR2MUX,
										 ADDR1MUX,
				output logic [1:0] ADDR2MUX,
				output logic 		 MARMUX,
				  
				output logic [1:0] ALUK,
				
				output logic Mem_CE,
								 Mem_UB,
								 Mem_LB,
								 Mem_OE,
								 Mem_WE
				);

	 //****************************23/32 States****************************
    enum logic [4:0] {Halted,  S_18, S_33_1, S_33_2, S_35, S_32, S_01,	//
								S_BR,															//
								S_JSR, S_JSR_2,											//
								S_AND,														//
								S_LDR, S_LDR_2, S_LDR_3, S_LDR_4,  					//
								S_STR, S_STR_2, S_STR_3, S_STR_4,					//
								S_NOT,														//
								S_JMP,														//
								PauseIR1, PauseIR2}   State, Next_state;   		//
	//*********************************************************************
	    
    always_ff @ (posedge Clk or posedge Reset )
    begin : Assign_Next_State
        if (Reset) 
            State <= Halted;
        else 
            State <= Next_state;
    end
   
	always_comb
    begin 
	    Next_state  = State;
	 
        unique case (State)
            Halted : 
	             if (Run) 
						  Next_state <= S_18;					  
            S_18 : 
                Next_state <= S_33_1;
            S_33_1 : 
                Next_state <= S_33_2;
            S_33_2 : 
                Next_state <= S_35;
            S_35 : 
                Next_state <= PauseIR1;
            PauseIR1 : 
                if (~ContinueIR) 
                    Next_state <= PauseIR1;
                else 
                    Next_state <= PauseIR2;
            PauseIR2 : 
                if (ContinueIR) 
                    Next_state <= PauseIR2;
                else 
                    Next_state <= S_18;
						  
            //***************9/16 OPCODES***************
				S_32 : 												//
					case (Opcode)									//
						4'b0000 : 									// BR   (op 0)
							if (BEN) Next_state <= S_BR;		//
							else Next_state <= S_18;			//
						4'b0001 : 									// ADD and ADDi (depends later on IR_5)
							Next_state <= S_01;  	 			// 
						4'b0100 : 							   	// JSR  (op 4)
							Next_state <= S_JSR;					//
						4'b0101 : 									// AND and ANDi (depends later on IR_5)
							Next_state <= S_AND;					//
					   4'b0110 : 									// LDR  (op 6)
							Next_state <= S_LDR;					//
						4'b0111 : 									// STR  (op 7)
							Next_state <= S_STR;					//
						4'b1001 :									// NOT  (op 9)
							Next_state <= S_NOT;					//
						4'b1100 : 									// JMP  (op 12)
							Next_state <= S_JMP;					//
						4'b1101 : 									// PAUSE (op 13)
							Next_state <= PauseIR1;				//
																		//
						default : 									//
							Next_state <= S_18;					//
				   endcase											//
				//******************************************
				
				S_01 : Next_state <= S_18;
				
				S_BR : Next_state <= S_18;
				
				S_JSR : Next_state <= S_JSR_2;
				S_JSR_2 : Next_state <= S_18;
				
				S_AND : Next_state <= S_18;
				
				S_LDR : Next_state <= S_LDR_2;
				S_LDR_2 : Next_state <= S_LDR_3;
				S_LDR_3 : Next_state <= S_LDR_4;
				S_LDR_4 : Next_state <= S_18;
				
				S_STR : Next_state <= S_STR_2;
				S_STR_2 : Next_state <= S_STR_3;
				S_STR_3 : Next_state <= S_STR_4;
				S_STR_4 : Next_state <= S_18;
				
				S_NOT : Next_state <= S_18; 
				
				S_JMP : Next_state <= S_18;
						
			default : ;

	     endcase
    end
   
    always_comb
    begin 
        //default controls signal values; within a process, these can be
        //overridden further down (in the case statement, in this case)
	    LD_MAR = 1'b0;
	    LD_MDR = 1'b0;
	    LD_IR = 1'b0;
	    LD_BEN = 1'b0;
	    LD_CC = 1'b0;
	    LD_REG = 1'b0;
	    LD_PC = 1'b0;
		 
	    GatePC = 1'b0;
	    GateMDR = 1'b0;
	    GateALU = 1'b0;
	    GateMARMUX = 1'b0;
		 
		 ALUK = 2'b00;
		 
	    PCMUX = 2'b00;
	    DRMUX = 1'b0;
	    SR1MUX = 1'b0;
	    SR2MUX = 1'b0;
	    ADDR1MUX = 1'b0;
	    ADDR2MUX = 2'b00;
	    MARMUX = 1'b0;
		 
	    Mem_OE = 1'b1;
	    Mem_WE = 1'b1;
		 
	    case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b10;		// Changed to select PC_out + 1
					LD_PC = 1'b1;
				end
			S_33_1 :
				begin
					Mem_OE = 1'b0;
				end
			S_33_2 : 
				begin 
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
            end
         S_35 : 
            begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
            end
         PauseIR1: ;
			PauseIR2: ;
         S_32 : 
            begin
					LD_BEN = 1'b1;
				end
         S_01 : 
            begin 
					SR2MUX = IR_5;		//This implements the ADDi feature.  
					ALUK = 2'b00;		//	*if(IR_5==1){ADD with SEXT[IR[4:0]]}
					GateALU = 1'b1;	//	*else {ADD with SR2_Out}
					LD_REG = 1'b1;
				end
			   
			S_BR :
				begin
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					PCMUX = 2'b01;
					LD_PC = 1'b1;
				end
					
			S_JSR :
				begin
					ADDR2MUX = 2'b00;
					ADDR1MUX = 1'b1;
					MARMUX = 1'b1;
					GateMARMUX = 1'b1;	
				end
			S_JSR_2 : 
				begin
					LD_REG = 1'b1;
					DRMUX = 1'b1;
				end
					
			S_AND :
				begin
					SR2MUX = IR_5;		//This implements the ANDi feature. 
					ALUK = 2'b01;		//	*if(IR_5==1){ADD with SEXT[IR[4:0]]}
					GateALU = 1'b1;	//	*else {ADD with SR2_Out}
					LD_REG = 1'b1;
					LD_CC = 1'b1; 	
				end
					 
			S_LDR : // (MAR <- Breg + SEXT(off6))
				begin
					ADDR1MUX = 1'b0; 
					ADDR2MUX = 2'b10; 
					MARMUX = 1'b1; 
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end
			S_LDR_2 : // (2 cycles required..MDR<-M[MAR])
				begin
					Mem_OE = 1'b0;
				end
			S_LDR_3 : 
				begin
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
			S_LDR_4 : // (DR<-MDR)
				begin
					GateMDR = 1'b1; 
					LD_REG = 1'b1;
					LD_CC = 1'b1; 
				end
										
			S_STR : // Technically the same state as S_LDR
				begin
					ADDR1MUX = 1'b0; 
					ADDR2MUX = 2'b10; 
					MARMUX = 1'b1; 
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end		
			S_STR_2 : // MDR<-SR
				begin
					SR1MUX = 1'b1; 
					ALUK = 2'b11;
					GateALU = 1'b1;
					LD_MDR = 1'b1; 
				end
			S_STR_3 : // M[MAR] <- MDR
				begin
					Mem_WE = 1'b0; 
					GateMDR = 1'b1; 
				end
			S_STR_4 :
				begin
					Mem_WE = 1'b0; 
					GateMDR = 1'b1; 
				end
				
			S_NOT :
				begin
					ALUK = 2'b11;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
				
			S_JMP :
				begin
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b11;
					PCMUX = 2'b01;
					LD_PC = 1'b1; 
				end

         default : ;
       endcase
   end 

	assign Mem_CE = 1'b0;
	assign Mem_UB = 1'b0;
	assign Mem_LB = 1'b0;
	
endmodule
