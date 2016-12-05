//-------------------------------------------------------------------------
//    Mouse.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  mouse ( input Reset, frame_clk,
					input logic [15:0] keycode,
               output [9:0]  mouseX, mouseY, mouseS );
    
    logic [9:0] Mouse_X_Pos, Mouse_X_Motion, Mouse_Y_Pos, Mouse_Y_Motion, Mouse_Size;
	 
    parameter [9:0] Mouse_X_Center=320;  // Center position on the X axis
    parameter [9:0] Mouse_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Mouse_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Mouse_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Mouse_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Mouse_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Mouse_X_Step=3;      // Step size on the X axis
    parameter [9:0] Mouse_Y_Step=3;      // Step size on the Y axis
	 parameter [9:0] Screen_Border=5;	  // Extra buffer to make sure mouse stays in screen
	 
	 // Single keys
	 logic [15:0] W_Key = 26;
	 logic [15:0] A_Key = 4;
	 logic [15:0] S_Key = 22;
	 logic [15:0] D_Key = 7;
	 
	 // Combination of 2 keys
	 logic [15:0] WA_Keys = 6660;
	 logic [15:0] WS_Keys = 6678;
	 logic [15:0] WD_Keys = 6663;
	 logic [15:0] AS_Keys = 1046;
	 logic [15:0] AD_Keys = 1031;
	 logic [15:0] SD_Keys = 5639;
	 logic [15:0] AW_Keys = 1050;
	 logic [15:0] SW_Keys = 5658;
	 logic [15:0] DW_Keys = 1818;
	 logic [15:0] SA_Keys = 5636;
	 logic [15:0] DA_Keys = 1796;
	 logic [15:0] DS_Keys = 1814;
	 
	 logic [15:0] Last_key = 0;
	 logic [2:0]  Hit_Wall = 5;
	 logic [3:0]  Dir = 8;

    assign Mouse_Size = 4;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Mouse
        if (Reset)  // Asynchronous Reset
        begin 
            Mouse_Y_Motion <= 10'd0; //Mouse_Y_Step;
				Mouse_X_Motion <= 10'd0; //Mouse_X_Step;
				Mouse_Y_Pos <= Mouse_Y_Center;
				Mouse_X_Pos <= Mouse_X_Center;
        end
           
        else 
        begin 
				// Case statement for all possible key inputs
		      case(keycode)
				    W_Key  :
					 begin
					     Mouse_Y_Motion <= (~(Mouse_Y_Step) + 1'b1);
					     Mouse_X_Motion <= 0;
						  Dir <= 0;
					 end
				    A_Key  :
					 begin
					     Mouse_X_Motion <= (~(Mouse_X_Step) + 1'b1);
					     Mouse_Y_Motion <= 0;
						  Dir <= 2;
					 end
				    S_Key  :
					 begin
					     Mouse_Y_Motion <= Mouse_Y_Step;
					     Mouse_X_Motion <= 0;
						  Dir <= 4;
					 end
				    D_Key  :
					 begin
					     Mouse_X_Motion <= Mouse_X_Step;
					     Mouse_Y_Motion <= 0;
						  Dir <= 6;
					 end
				    WA_Keys, AW_Keys:
					 begin
					     Mouse_Y_Motion <= (~(Mouse_Y_Step) + 1'b1);
					     Mouse_X_Motion <= (~(Mouse_X_Step) + 1'b1);
						  Dir <= 1;
					 end
				    WD_Keys, DW_Keys:
					 begin
					     Mouse_Y_Motion <= (~(Mouse_Y_Step) + 1'b1);
					     Mouse_X_Motion <= Mouse_X_Step;
						  Dir <= 7;
					 end
				    AS_Keys, SA_Keys:
					 begin
					     Mouse_Y_Motion <= Mouse_Y_Step;
					     Mouse_X_Motion <= (~(Mouse_X_Step) + 1'b1);
						  Dir <= 3;
					 end
				    SD_Keys, DS_Keys:
					 begin
					     Mouse_Y_Motion <= Mouse_Y_Step;
					     Mouse_X_Motion <= Mouse_X_Step;
						  Dir <= 5;
					 end
				    AD_Keys, DA_Keys, WS_Keys, SW_Keys:
					 begin
					     Mouse_Y_Motion <= 0;
					     Mouse_X_Motion <= 0;
						  Dir <= 8;
					 end
					 default:
					 begin
					     Mouse_Y_Motion <= 0;
					     Mouse_X_Motion <= 0;
						  Dir <= 8;
					 end
				endcase
				
				/* If you hit any border, stop the mouse in that direction! */
				
				// Moving downward
				if ( (Mouse_Y_Pos + Mouse_Size) + Mouse_Y_Motion >= (Mouse_Y_Max - Screen_Border) )
				begin
					if(Dir == 0 || Dir == 1 || Dir == 7) ; // Allow normal behavior
					else Mouse_Y_Motion <= 0;	// Stop vertical motion
				end
				// Moving upward
				else if ( (Mouse_Y_Pos - Mouse_Size) + Mouse_Y_Motion <= (Mouse_Y_Min + Screen_Border) )
				begin
					if(Dir == 3 || Dir == 4 || Dir == 5) ; // Allow normal behavior
					else Mouse_Y_Motion <= 0;	// Stop vertical motion
				end
				// Not along top or bottom wall, continue with business as usual
				else
				begin
					//Mouse_Y_Motion <= Mouse_Y_Motion;
				end
				
				// Moving rightward
				if ( (Mouse_X_Pos + Mouse_Size) + Mouse_X_Motion >= (Mouse_X_Max - Screen_Border) )
				begin
					if(Dir == 1 || Dir == 2 || Dir == 3) ; // Allow normal behavior
					else Mouse_X_Motion <= 0;	// Stop horizontal motion
				end
				// Moving leftward
				else if ( (Mouse_X_Pos - Mouse_Size) + Mouse_X_Motion <= (Mouse_X_Min + Screen_Border) )
				begin
					if(Dir == 5 || Dir == 6 || Dir == 7) ; // Allow normal behavior
					else Mouse_X_Motion <= 0;	// Stop horizontal motion
				end
				// Not along left or right wall, conitinue with business as usual
				else 
				begin
					//Mouse_X_Motion <= Mouse_X_Motion;
				end
				
				Mouse_Y_Pos <= (Mouse_Y_Pos + Mouse_Y_Motion);
				Mouse_X_Pos <= (Mouse_X_Pos + Mouse_X_Motion);
		end  
    end
       
    assign mouseX = Mouse_X_Pos;
   
    assign mouseY = Mouse_Y_Pos;
   
    assign mouseS = Mouse_Size;
    

endmodule
