module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic [15:0] S;
logic Clk = 0;
logic Reset, Run, Continue;
logic [11:0] LED;
logic [6:0]  HEX0, HEX1, HEX2, HEX3;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
wire [15:0] Data;
logic [15:0] IR;
		
// Instantiating the Processor
slc3 Big_Papa(.*);	

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block as in a software program
initial begin: TEST_VECTORS
S = 16'b0000000000000110;	// opJMP(R1)

Reset = 0;
Run = 1;
Continue = 1;

#2 Reset = 1;
	
//#2 ADDR = 16'hFFFF;

#1 Run = 0;
#2 Run = 1;

#4 S = 16'b1;

#6 Continue = ~Continue;
#2 Continue = ~Continue;

#2 Continue = ~Continue;
#2 Continue = ~Continue;
#2 S = 16'b0;

#2 Continue = ~Continue;
#2 Continue = ~Continue;
#2 S = 16'b0011001100110011;

#2 Continue = ~Continue;
#2 Continue = ~Continue;
#2 S = 16'b0101010101010101;

#2 Continue = ~Continue;
#2 Continue = ~Continue;
#2 S = 16'b1;

#2 Continue = ~Continue;
#2 Continue = ~Continue;
#4	;// Do nothing

#2 Continue = ~Continue;
#2 Continue = ~Continue;
#4	;// Do nothing

#2 Continue = ~Continue;
#2 Continue = ~Continue;
#4	;// Do nothing
end
endmodule