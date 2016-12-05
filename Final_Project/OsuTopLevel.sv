//-------------------------------------------------------------------------
//      OsuTopLevel.sv                                                   --
//      Michael Olson                                                    --
//      Fall 2016                                                        --
//                                                                       --
//      ECE 385 Final Project                                            --
//                                                                       --
//      Last Edited: November 14, 2016                                   --
//-------------------------------------------------------------------------


module  OsuTopLevel 	( input         CLOCK_50,
                       input[3:0]    KEY,    				//bit 0 is set up as Reset
							  output [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
							//output [8:0]  LEDG,
							  output [17:0] LEDR,
							
							//VGA Interface 
                       output [7:0]  VGA_R,					//VGA Red
							                VGA_G,					//VGA Green
												 VGA_B,					//VGA Blue
							  output        VGA_CLK,				//VGA Clock
							                VGA_SYNC_N,			//VGA Sync signal
												 VGA_BLANK_N,			//VGA Blank signal
												 VGA_VS,					//VGA virtical sync signal	
												 VGA_HS,					//VGA horizontal sync signal
							  
							  // CY7C67200 Interface
							  inout [15:0]  OTG_DATA,						//	CY7C67200 Data bus 16 Bits
							  output [1:0]  OTG_ADDR,						//	CY7C67200 Address 2 Bits
							  output        OTG_CS_N,						//	CY7C67200 Chip Select
												 OTG_RD_N,						//	CY7C67200 Write
												 OTG_WR_N,						//	CY7C67200 Read
												 OTG_RST_N,						//	CY7C67200 Reset
							  input			 OTG_INT,						//	CY7C67200 Interrupt
							  
							  // SDRAM Interface for Nios II Software
							  output [12:0] DRAM_ADDR,				// SDRAM Address 13 Bits
							  inout [31:0]  DRAM_DQ,				// SDRAM Data 32 Bits
							  output [1:0]  DRAM_BA,				// SDRAM Bank Address 2 Bits
							  output [3:0]  DRAM_DQM,				// SDRAM Data Mast 4 Bits
							  output			 DRAM_RAS_N,			// SDRAM Row Address Strobe
							  output			 DRAM_CAS_N,			// SDRAM Column Address Strobe
							  output			 DRAM_CKE,				// SDRAM Clock Enable
							  output			 DRAM_WE_N,				// SDRAM Write Enable
							  output			 DRAM_CS_N,				// SDRAM Chip Select
							  output			 DRAM_CLK,				// SDRAM Clock
							  
							  // PS2 Mouse Interface
							  inout PS2_CLK,							// Connect to corresponding pins on Cyclone IV board
							  inout PS2_DAT
							);
    
    logic Reset_h, vssig, Clk;
    logic [9:0] drawxsig, drawysig, mousexsig, mouseysig, mousesizesig;
	 logic [15:0] keycode;
	 
	 assign Clk = CLOCK_50;
    assign {Reset_h}=~ (KEY[0]);  // The push buttons are active low
	 
	 wire [1:0] hpi_addr;
	 wire [15:0] hpi_data_in, hpi_data_out;
	 wire hpi_r, hpi_w,hpi_cs;
	 
	 
	 wire [7:0] the_command, received_data;
	 wire send_command, command_was_sent, error_communication_timed_out, received_data_en;
	 
	 //Tristate these
	 //PS2_CLK
	 //PS2_DAT
	 //---------------------MERGE-----------------------
	 logic [9:0] targetxsig, targetysig, targetsizesig;
	 assign Reset_sh =~ (KEY[2]);
	 assign Press_h =~ (KEY[3]);
	 //-------------------------------------------------
	 

	 // USB IO
	 hpi_io_intf hpi_io_inst(   .from_sw_address(hpi_addr),
										 .from_sw_data_in(hpi_data_in),
										 .from_sw_data_out(hpi_data_out),
										 .from_sw_r(hpi_r),
										 .from_sw_w(hpi_w),
										 .from_sw_cs(hpi_cs),
		 								 .OTG_DATA(OTG_DATA),    
										 .OTG_ADDR(OTG_ADDR),    
										 .OTG_RD_N(OTG_RD_N),    
										 .OTG_WR_N(OTG_WR_N),    
										 .OTG_CS_N(OTG_CS_N),    
										 .OTG_RST_N(OTG_RST_N),   
										 .OTG_INT(OTG_INT),
										 .Clk(Clk),
										 .Reset(Reset_h)
	 );
	 
	 //The connections for nios_system might be named different depending on how you set up Qsys ~~~Seems good (Jacob)
	 lab8_soc nios_system(
										 .clk_clk(Clk),
										 .keycode_export(keycode),  
										 .otg_hpi_address_export(hpi_addr),
										 .otg_hpi_cs_export(hpi_cs),
										 .otg_hpi_data_in_port(hpi_data_in),
										 .otg_hpi_data_out_port(hpi_data_out),
										 .otg_hpi_r_export(hpi_r),
										 .otg_hpi_w_export(hpi_w),
										 .reset_reset_n(KEY[0]),
										 .sdram_clk_clk(DRAM_CLK),  
										 .sdram_wire_addr(DRAM_ADDR), 
										 .sdram_wire_ba(DRAM_BA),   
										 .sdram_wire_cas_n(DRAM_CAS_N),
										 .sdram_wire_cke(DRAM_CKE),  
										 .sdram_wire_cs_n(DRAM_CS_N), 
										 .sdram_wire_dq(DRAM_DQ),   
										 .sdram_wire_dqm(DRAM_DQM),  
										 .sdram_wire_ras_n(DRAM_RAS_N),
										 .sdram_wire_we_n(DRAM_WE_N));
	
	//VGA Controller
    vga_controller vgasync_instance(
								.Clk(Clk),       		// 50 MHz clock
                        .Reset(Reset_sh),   	// reset signal
                        .hs(VGA_HS),        			// Horizontal sync pulse.  Active low
								.vs(VGA_VS),        	// Vertical sync pulse.  Active low
								.pixel_clk(VGA_CLK),	// 25 MHz pixel clock output
								.blank(VGA_BLANK_N),    // Blanking interval indicator.  Active low.
								.sync(VGA_SYNC_N),		// Composite Sync signal.  Active low.  We don't use it in this lab,
															//   but the video DAC on the DE2 board requires an input for it.
								.DrawX(drawxsig),  	// horizontal coordinate
								.DrawY(drawysig)		// vertical coordinate
								);
   
	 //Mouse Cursor
//	 PS2_Controller(		.CLOCK_50(Clk), 
//								.reset(Reset_h),
//								.the_command(the_command),				// Input - Don't need after enabling data reporting
//								.send_command(send_command),			// Input - Simple enable flag
//								.PS2_CLK(PS2_CLK),						// Bidirectional - 50MHz - has a special DE2 pin
//								.PS2_DAT(PS2_DAT),						// Bidirectional - has a special DE2 pin
//								.command_was_sent(command_was_sent),// Output - simple boolean T/F
//								.error_communication_timed_out(error_communication_timed_out),	// Output - simple boolean T/F
//								.received_data(received_data),		// 8-bit output of the recieved data (total data 24 bits)
//								.received_data_en(received_data_en)	// If 1, then new data has been received
//								);
//	 
//    MouseCursor cursor(	.Reset(Reset_h), 
//								.frame_clk(CLK_25),
//								.keycode(keycode),
//								.MouseX(mousexsig), 
//								.MouseY(mouseysig), 
//								.MouseS(mousesizesig)
//								);
   
	//Keyboard Mouse
	mouse mouse_instance(.Reset(Reset_sh), 
								.frame_clk(VGA_VS),
								.keycode(keycode),
								.mouseX(mousexsig), 
								.mouseY(mouseysig), 
								.mouseS(mousesizesig)
								);
	// Hit circle							
	target target_instance(
	                     .Pressed(Press_h),
	                     .Reset(Reset_sh), 
								.frame_clk(VGA_VS),
								.TargetX(targetxsig), 
								.TargetY(targetysig), 
								.TargetS(targetsizesig)
								);
	 //Color Mapper   
    color_mapper color_instance( 
								.frame_clk(VGA_VS),
	                     .Pressed(Press_h),  
								.DrawX(drawxsig), 
								.DrawY(drawysig),
								.MouseX(mousexsig), 
								.MouseY(mouseysig), 
								.MouseSize(mousesizesig),
								.TargetX(targetxsig), 
								.TargetY(targetysig), 
								.TargetSize(targetsizesig),
								.Red(VGA_R), 
								.Green(VGA_G), 
								.Blue(VGA_B)
								);
	 
	 //Hex Displays									  
	 HexDriver hex_inst_0 (keycode[3:0], HEX0);
	 HexDriver hex_inst_1 (keycode[7:4], HEX1);
	 HexDriver hex_inst_2 (keycode[11:8], HEX2);
	 HexDriver hex_inst_3 (keycode[15:12], HEX3);
	 
	 HexDriver hex_inst_4 (4'b1001, HEX4);
	 HexDriver hex_inst_5 (4'b0110, HEX5);
	 HexDriver hex_inst_6 (4'b1001, HEX6);
	 HexDriver hex_inst_7 (4'b0110, HEX7);
	 
//	 HexDriver hex_inst_4 (received_data[3:0], HEX4);
//	 HexDriver hex_inst_5 (received_data[7:4], HEX5);
//	 HexDriver hex_inst_6 (4'b0000, HEX6);
//	 HexDriver hex_inst_7 (4'b0000, HEX7);
	 
//	 assign LEDR[7] = received_data[7];
//	 assign LEDR[6] = received_data[6];
//	 assign LEDR[5] = received_data[5];
//	 assign LEDR[4] = received_data[4];
//	 assign LEDR[3] = received_data[3];
//	 assign LEDR[2] = received_data[2];
//	 assign LEDR[1] = received_data[1];
//	 assign LEDR[0] = received_data[0];
	 
	 //Menu Buttons
	 
	 //Audio Controller
	 
endmodule
