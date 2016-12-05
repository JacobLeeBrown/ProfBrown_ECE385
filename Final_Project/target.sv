//-------------------------------------------------------------------------
//    Target.sv                                                            --
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


module  target ( input Pressed, Reset, frame_clk,
               output [9:0]  TargetX, TargetY, TargetS );
    
    logic [9:0] Target_X_Pos, Target_Y_Pos, Target_Size;
	 
	 int press_delay = 0;
	 
    parameter [9:0] Target_X_Center=160;  // Center position on the X axis
    parameter [9:0] Target_Y_Center=120;  // Center position on the Y axis
	 
    assign Target_Size = 15;  // assigns the value 15 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk)
    begin: Move_Target
        if (Reset)  // Asynchronous Reset
        begin
				Target_Y_Pos <= Target_Y_Center;
				Target_X_Pos <= Target_X_Center;
        end
		  else
		  begin
				  if (Pressed && (press_delay == 0))
				  begin
						if(Target_X_Pos == 160 && Target_Y_Pos == 120)
							 Target_X_Pos <= 480;
						else if(Target_X_Pos == 480 && Target_Y_Pos == 120)
							 Target_Y_Pos <= 360;
						else if(Target_X_Pos == 480 && Target_Y_Pos == 360)
							 Target_X_Pos <= 160;
						else if(Target_X_Pos == 160 && Target_Y_Pos == 360)
							 Target_Y_Pos <= 120;
						press_delay <= 1;
				  end
				  else if(!Pressed)
				  begin
						press_delay <= 0;
				  end
		   end
    end
       
    assign TargetX = Target_X_Pos;
   
    assign TargetY = Target_Y_Pos;
   
    assign TargetS = Target_Size;
    

endmodule
