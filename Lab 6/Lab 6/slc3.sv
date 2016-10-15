//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Given Code - SLC-3 top-level (External SRAM)
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//------------------------------------------------------------------------------


module slc3(
	input logic [15:0] S,
	input logic	Clk, Reset, Run, Continue,
	output logic [11:0] LED,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3,
	output logic CE, UB, LB, OE, WE,
	output logic [19:0] ADDR,
	inout wire [15:0] Data 
);

//Declaration of push button active high signals	
//TODO - Consider synchronizing these buttons!!! (Mike)
//logic Reset_ah, Continue_ah, Run_ah;

//assign Reset_ah = ~Reset;
//assign Continue_ah = ~Continue;
//assign Run_ah = ~Run;

// An array of 4-bit wires to connect the hex_drivers efficiently to wherever we want
// For Lab 1, they will direclty be connected to the IR register through an always_comb circuit
// For Lab 2, they will be patched into the MEM2IO module so that Memory-mapped IO can take place
logic [3:0] hex_4[3:0]; 
HexDriver hex_drivers[3:0] (hex_4, {HEX3, HEX2, HEX1, HEX0});
// This works thanks to http://stackoverflow.com/questions/1378159/verilog-can-we-have-an-array-of-custom-modules

logic [15:0] D_CPU_out, MDR_out;
logic [15:0] Data_Mem_In, Data_Mem_Out;
wire [15:0] Bus_Data;
wire [15:0] Data_Mem;

// Break the tri-state bus to the ram into input/outputs 
tristate #(.N(16)) tr0(
				.Clk(Clk),
				.OE(~WE), 
				.In(Data_Mem_Out), 
				.Out(Data_Mem_In), 
				.Data_Mem(Data)
);

// Our SRAM and I/O controller (note, this plugs into MDR/MAR)
Mem2IO memory_subsystem(
				.*,
//				.Data_Mem_In(Data),	// For physical tests
				.Data_Mem_In(Data_Mem), 	// For simulation
				.Reset(~Reset), 
				.A(ADDR), 
				.Switches(S),
//				.HEX0(hex_4[0]), 
//				.HEX1(hex_4[1]), 
//				.HEX2(hex_4[2]), 
//				.HEX3(hex_4[3]),
				.Data_CPU_In(MDR_out), 
				.Data_CPU_Out(D_CPU_out)
);

// The CPU, where the real sh*t gets done
CPU	Our_Lord_And_Savior_Harambe(
				.*,
				.Bus_Data,
				.HEX0(hex_4[0]),
				.HEX1(hex_4[1]),
				.HEX2(hex_4[2]),
				.HEX3(hex_4[3])
);

// Uncomment this module to simulate
test_memory	 fake_mem(
				.*, 
				.Reset(~Reset), 
				.I_O(Data_Mem), 
				.A(ADDR));


endmodule