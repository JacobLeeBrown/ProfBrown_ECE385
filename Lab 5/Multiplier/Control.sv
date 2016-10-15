//Two-always example for state machine

module control (input  logic Clk, Reset, ClearA_LoadB, Run, M_in,
                output logic Shift_En, ClA_LdB, LoadA, Add, Subtr);

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., P as the state values
    enum logic [4:0] {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R}   curr_state, next_state; 
    
	// updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= A;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always
    begin
        
		  next_state = curr_state;	//required because we haven't enumerated all possibilities below
        unique case (curr_state) 
            A : if (Run)
                    next_state = B;
            B : next_state = C;
            C : next_state = D;
            D : next_state = E;
            E : next_state = F;
				F : next_state = G;
				G : next_state = H;
				H : next_state = I;
				I : next_state = J;
				J : next_state = K;
				K : next_state = L;
				L : next_state = M;
				M : next_state = N;
				N : next_state = O;
				O : next_state = P;
				P : next_state = Q;
				Q : next_state = R;
				R : if (~Run) 
		            next_state = A;
        endcase
   
		// Assign outputs based on ‘state’
		// A and P are the "hold" states
		// every other listed state is either an "ADD" or "SUB" state
		// default state is shifting
        case (curr_state) 
            A: 
                begin
						  LoadA = 1'b0;
                    ClA_LdB = ClearA_LoadB;
                    Shift_En = 1'b0;
                end
            B: 
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Add = 1'b1;
                end
            D: 
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Add = 1'b1;
                end
            G: 
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Add = 1'b1;
                end
            I: 
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Add = 1'b1;
                end
            K: 
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Add = 1'b1;
                end
            M: 
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Add = 1'b1;
                end
            O:
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Add = 1'b1;
                end
            Q:
                begin
                    LoadA = 1'b1;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                    if(M_in)
                        Subtr = 1'b1;
                end
            R: 
                begin
						  LoadA = 1'b0;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b0;
                end
            default:
                begin 
                    LoadA = 1'b0;
                    Add = 1'b0;
                    Subtr = 1'b0;
                    ClA_LdB = 1'b0;
                    Shift_En = 1'b1;
                end
        endcase
    end

endmodule
