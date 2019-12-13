//`timescale 1ns/1ps

module TB ();

	parameter CLK_PER = 4;
	parameter NUM_CLK = 10000;


	// --------------------------------------------
	// Wires and Regs
	// --------------------------------------------
	reg				CLK;
	reg				RESET_N;

	wire			IREQ;
	wire	[31:0]	IADDR;
	wire	[31:0]	INSTR;

	wire			DREQ;
	wire	[31:0]	DADDR;
	wire			DWE;
	wire	[1:0]	DSIZE;
	wire	[31:0]	DIN;
	wire	[31:0]	DOUT;

	reg		[3:0]	DBE;


	always #(CLK_PER/2) CLK = ~CLK;

	initial begin
		CLK = 1'b0;
		RESET_N = 1'b0;

		#(CLK_PER/4);
		
		#(CLK_PER*4);
			RESET_N = 1;
	end

	
	CortexM0 CortexM0 (
		.CLK(CLK),
		.RESET_N(RESET_N),
		
		// For instruction memory
		.IREQ(IREQ),
		.IADDR(IADDR),
		.INSTR(INSTR),

		// For data memory
		.DREQ(DREQ),
		.DADDR(DADDR),
		.DRW(DWE),		// read/write
		.DSIZE(DSIZE),	// Data memory access size 
		.DIN(DIN),
		.DOUT(DOUT)
	);

	SRAM MEM (
		.CLK (CLK),
		.CSN1 (1'b0),		// always chip select
		.ADDR1 (IADDR[13:2]),
		.WE1 (1'b0),			// only read operation
		.BE1 (4'b1111),		// word access
		.DI1 (),				// not used
		.DO1 (INSTR),			// read data

		.CSN2 (~DREQ),
		.ADDR2 (DADDR[13:2]),
		.WE2 (DWE),
		.BE2 (DBE),
		.DI2 (DOUT),
		.DO2 (DIN)
	);

	always @* begin
		casex( {DSIZE, DADDR[1:0]} )
			{2'b00, 2'b00}	:	DBE = 4'b0001;
			{2'b00, 2'b01}	:	DBE = 4'b0010;
			{2'b00, 2'b10}	:	DBE = 4'b0100;
			{2'b00, 2'b11}	:	DBE = 4'b1000;
			{2'b01, 2'b00}	:	DBE = 4'b0011;
			{2'b01, 2'b10}	:	DBE = 4'b1100;
			{2'b10, 2'b00}	:	DBE = 4'b1111;
		endcase
	end

	// --------------------------------------------
	// Load test vector to inst and data memory
	// --------------------------------------------
	// Caution : Assumption : input file has hex data like below. 
	//			 input file : M[0x03]M[0x02]M[0x01]M[0x00]
	//                        M[0x07]M[0x06]M[0x05]M[0x04]
	//									... 
	//           If the first 4 bytes in input file is 1234_5678
	//           then, the loaded value is mem[0x0000] = 0x1234_5678 (LSB)

	defparam TB.MEM.ROMDATA = "mem.hex";

	// --------------------------------------------
	// For Dump variables
	// --------------------------------------------

	initial begin
		$dumpfile("myfile.dmp");
		$dumpvars;
	end

	initial begin
		#(CLK_PER * NUM_CLK); $finish;
	end


endmodule

