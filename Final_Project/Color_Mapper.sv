//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Jacob Brown   12-04-2016                               --
//-------------------------------------------------------------------------


module  color_mapper (
				input [9:0] DrawX,
								DrawY,
								// Mouse Signals
								MouseX,
								MouseY,
								MouseSize,
								// Target Signals
								TargetX,
								TargetY,
								TargetSize,
								// Other Signals
				input			Pressed, frame_clk,
				            // Color signals
            output logic [7:0]  Red, Green, Blue );
    
	 // Boolean logic
    logic mouse_on, target_on, mouse_in_target;
	 
	 // Mouse Variables
    int MouseDistX, MouseDistY, Mouse_Size;
	 
	 assign MouseDistX = DrawX - MouseX;
    assign MouseDistY = DrawY - MouseY;
    assign Mouse_Size = MouseSize;
	 
	 // Target Variables
	 int TargetDistX, TargetDistY, Target_Size, TargetXIdx, TargetYIdx;
	 
	 assign TargetDistX = DrawX - TargetX;
    assign TargetDistY = DrawY - TargetY;
	 assign Target_Size = TargetSize;
	 
	 // assign TargetLeftX = TargetX - TargetSize;
	 // assign TargetRightX = TargetX + TargetSize;
	 assign TargetXIdx = DrawX - (TargetX - TargetSize);
	 
	 // assign TargetTopY = TargetY - TargetSize;
	 // assign TargetBottomY = TargetY + TargetSize;
	 assign TargetYIdx = DrawY - (TargetY - TargetSize);
	 
	 logic [29:0][29:0] Target_Data;
	 circle t(.c(Target_Data));
	 
	 // Hit or miss variables
	 logic just_pressed = 1'b0;
	 logic flashing = 1'b0;
	 logic flashed = 1'b0;
	 int press_delay = 3;
	 int hit = 0;
	 int miss = 0;
	 
	 // Drawing mouse logic
    always_comb
    begin:Mouse_on_proc
        if ( ( MouseDistX*MouseDistX + MouseDistY*MouseDistY) <= (Mouse_Size * Mouse_Size) ) 
            mouse_on = 1'b1;
        else 
            mouse_on = 1'b0;
    end
	 
	 // Drawing target logic
//	 always_comb
//    begin:Target_on_proc
//        if ( ( TargetDistX*TargetDistX + TargetDistY*TargetDistY) <= (Target_Size * Target_Size) ) 
//            target_on = 1'b1;
//        else 
//            target_on = 1'b0;
//    end 
	 
//	 always_comb
//    begin:Target_on_proc
//        if ( (DrawX >= TargetLeftX) && (DrawX < TargetRightX) &&
//		       (DrawY >= TargetTopY) && (DrawY < TargetBottomY))
//		  begin
//			  if(Target_Data[TargetYIdx][TargetXIdx] == 1'b1)
//				  target_on = 1'b1;
//			  else
//			     target_on = 1'b0;
//		  end 
//        else 
//            target_on = 1'b0;
//    end 
	 
	 always_comb
    begin:Target_on_proc
        if ( (TargetXIdx >= 0) && (TargetXIdx < 30) &&
		       (TargetYIdx >= 0) && (TargetYIdx < 30))
		  begin
			  if(Target_Data[TargetYIdx][TargetXIdx] == 1'b1)
				  target_on = 1'b1;
			  else
			     target_on = 1'b0;
		  end 
        else 
            target_on = 1'b0;
    end 
	 
	 // If the mouse is in the target logic
	 always_comb
	 begin:Mouse_on_Target
        if ( (MouseX <= (TargetX+TargetSize)) && (MouseX >= (TargetX-TargetSize)) &&
		       (MouseY <= (TargetY+TargetSize)) && (MouseY >= (TargetY-TargetSize)) ) 
            mouse_in_target = 1'b1;
        else 
            mouse_in_target = 1'b0;
    end 
	 
	 always_ff @ (posedge frame_clk)
	 begin: Pressed_signals
		  // Logic for handling held button
        if((just_pressed == 1'b1))
        begin
				if(Pressed == 1'b1 || flashing == 1'b1)
				begin
					// Logic for flash handling
					if(flashed == 1'b1)
					begin
						// Nothing, already flashed, they just won't release the button
					end
					else if(press_delay > 0)
					begin
						flashing <=  1'b1;
						press_delay <= (press_delay - 1);
					end
					else // else if((press_delay == 0))
					begin
						press_delay <= 2'b11;
						flashing <= 1'b0;
						flashed <= 1'b1;
						hit <= 1'b0;
						miss <= 1'b0;
					end
				end
				else // else if(Pressed == 0'b0)
				begin
					just_pressed <= 1'b0; // Button released
					flashed <= 1'b0; // Reset flashed boolean
				end
	     end	
		  else
		  begin
			  // Logic for "hit"
			  if((Pressed == 1'b1) && (mouse_in_target == 1'b1))
			  begin
					hit <= 1'b1;
					miss <= 1'b0;
					just_pressed <= 1'b1;
			  end
			  // Logic for "miss"
			  else if((Pressed == 1'b1) && (mouse_in_target == 1'b0))
			  begin
					hit <= 1'b0;
					miss <= 1'b1;
					just_pressed <= 1'b1;
			  end
			  else
			  // Normal behavior
			  begin
					hit <= 1'b0;
					miss <= 1'b0;
					just_pressed <= 1'b0;
			  end
		  end
	 end
    
	 // Coloring handling
    always_comb
    begin:RGB_Display
	     // Mouse coloring
        if ((mouse_on == 1'b1)) 
        begin 
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
		  // Target coloring
        else if ((target_on == 1'b1))
        begin
		      Red = 8'h80;
				Green = 8'hFF;
				Blue = 8'h00;
        end	
	     // Else for background color	  
        else 
        begin
		      // Hit!
		      if((hit == 1'b1))
				begin
				    Red = 8'h00; 
                Green = 8'hFF;
                Blue = 8'h00;
				end
				// Miss!
				else if((miss == 1'b1))
				begin
				    Red = 8'hFF; 
                Green = 8'h00;
                Blue = 8'h00;
				end
				// Normal background
				else
				begin
                Red = 8'h3f; 
                Green = 8'h00;
                Blue = 8'h3f;
			   end
        end      
    end 
    
endmodule
