
module CortexM0 (
	input	wire		      CLK,
	input	wire	        RESET_N, // reset when negative
	
	// For instruction memory
	output wire	    		IREQ,
	output wire [31:0]	IADDR,
	input	wire  [31:0]	INSTR,

	// For data memory
	output wire	    		DREQ,
	output wire	[31:0]	DADDR,
	output wire	  			DRW,
	output wire	[ 1:0]	DSIZE,
	input	wire	[31:0]	DIN,
	output wire	[31:0]	DOUT
);

reg [31:0]	PC_branch, PC, EXE_PC;
reg	branch;
reg [6:0]	OPCODE;
reg	APSR_N, APSR_Z, APSR_C, APSR_V;

wire	WEN1;
wire [3:0]	WA1;
wire [31:0]	DI1;
wire	WEN2;
wire [3:0]	WA2;
wire [31:0]	DI2;

wire [3:0]	RA0;
wire [3:0]	RA1;
wire [3:0]	RA2;
wire [31:0]	DOUT0;
wire [31:0]	DOUT1;
wire [31:0]	DOUT2;


// Initialization Registers
initial begin
	PC <= 0;
	PC_branch <= 0;
	EXE_PC <= 0;
end

// Reset Registers
always @ (negedge CLK) begin
	if (RESET_N == 1'b0) begin
		PC <= 0;
		PC_branch <= 0;
		EXE_PC <= 0;
	end
end


fetch fetch(
	.CLK(CLK),
	.branch(branch),
	.PC(PC),
	.PC_branch(PC_branch),

	.PC_OUT(EXE_PC)
);


decode decode(
	IADDR(EXE_PC),
	OPCODE(OPCODE)
);

EXE	EXE(
);


REGFILE REGFILE (
  .CLK(CLK),
  .nRST(RESET_N),
  .WEN1(WEN1),
  .WA1(WA1), 
  .DI1(DI1), 
  .WEN2(WEN2),
  .WA2(WA2),
  .DI2(DI2),
  .RA0(RA0),
  .RA1(RA1),
  .RA2(RA2),
  .DOUT0(DOUT0),
  .DOUT1(DOUT1),
  .DOUT2(DOUT2)
);

// Implement your code here.



endmodule

///////////////////////////////////////////
// fetch module
module fetch(
	input	wire	CLK,
	input	wire	branch,
	input [31:0]	wire	PC,
	input [31:0]	wire	PC_branch,

	output [31:0]	wire	PC_OUT
);

reg [31:0]	PC, EXE_PC, PC_temp; // Program Counter

assign PC_OUT = PC_temp;

always @ (negedge CLK) begin
	// Update PC
	if (branch == 1'b0) begin
		EXE_PC <= PC - 2;
		PC_temp <= PC + 2;
	end
	else begin
		EXE_PC <= PC_branch;
		PC_temp <= PC_branch + 4;
	end
end

endmodule

///////////////////////////////////////////////
module decode(
	input wire	[31:0]	IADDR,
	output	wire	[6:0]	OPCODE
);

  /* 
	 LSLi
	 LSRi
	 ASRi
	 ADDr1
	 SUBr
	 ADD3i
	 SUB3i
	 MOVi
	 CMPi
	 ADD8i
	 SUB8i
   */
  if (IADDR[15: 14] == 2'h0) begin
	  /* LSLi */
	  if (IADDR[13: 11] == 2'h0) begin
		  assign OPCODE = 7'd1;
	  end
	  /* LSRi */
	  else if (IADDR[13: 11] == 2'h1) begin
		  assign OPCODE = 7'd2;
	  end
	  /* ASRi */
	  else if (IADDR[13: 11] == 2'h2) begin
		  assign OPCODE = 7'd3;
	  end
	  else if (IADDR[13: 11] == 2'h3) begin
		  /* ADDr1 */
		  if (IADDR[10: 9] == 2'h0) begin
			  assign OPCODE = 7'd4;
		  end
		  /* SUBr */
		  else if (IADDR[10:9] == 2'h1) begin
			  assign OPCODE = 7'd5;
		  end
		  /* ADD3i */
		  else if (IADDR[10:9] == 2'h2) begin
			  assign OPCODE = 7'd6;
		  end
		  /* SUB3i */
		  else if (IADDR[10:9] == 2'h3) begin
			  assign OPCODE = 7'd7;
		  end
	  end
	  /* MOVi */
	  else if (IADDR[13: 11] == 2'h4) begin
		  assign OPCODE = 7'd8;
	  end
	  /* CMPi */
	  else if (IADDR[13: 11] == 2'h5) begin
		  assign OPCODE = 7'd9;
	  end
	  /* ADD8i */
	  else if (IADDR[13: 11] == 2'h6) begin
		  assign OPCODE = 7'd10;
	  end
	  /* SUB8i */
	  else if (IADDR[13: 11] == 2'h7) begin
		  assign OPCODE = 7'd11;
	  end
  end

  /*
	 ANDr
	 EORr
	 LSLr
	 LSRr
	 ASRr
	 ADCr
	 SBCr
	 RORr
	 TSTr
	 RSBi
	 CMPr1
	 CMNr
	 ORRr
	 MUL
	 BICr
	 MVNr
   */
  else if (IADDR[15: 10] == 2'h10) begin



	  /* ANDr */
	  if (IADDR[9: 6] == 2'h0) begin
		  assign OPCODE = 7'd12;
	  end
	  /* EORr */
	  else if (IADDR[9: 6] == 2'h1) begin
		  assign OPCODE = 7'd13;
	  end
	  /* LSLr */
	  else if (IADDR[9: 6] == 2'h2) begin
		  assign OPCODE = 7'd14;
	  end
	  /* LSRr */
	  else if (IADDR[9: 6] == 2'h3) begin
		  assign OPCODE = 7'd15;
	  end
	  /* ASRr */
	  else if (IADDR[9: 6] == 2'h4) begin
		  assign OPCODE = 7'd16;
	  end
	  /* ADCr */
	  else if (IADDR[9: 6] == 2'h5) begin
		  assign OPCODE = 7'd17;
	  end
	  /* SBCr */
	  else if (IADDR[9: 6] == 2'h6) begin
		  assign OPCODE = 7'd18;
	  end
	  /* RORr */
	  else if (IADDR[9: 6] == 2'h7) begin
		  assign OPCODE = 7'd19;
	  end
	  /* TSTr */
	  else if (IADDR[9: 6] == 2'h8) begin
		  assign OPCODE = 7'd20;
	  end
	  /* RSBi */
	  else if (IADDR[9: 6] == 2'h9) begin
		  assign OPCODE = 7'd21;
	  end
	  /* CMPr1 */
	  else if (IADDR[9: 6] == 2'hA) begin
		  assign OPCODE = 7'd22;
	  end
	  /* CMNr */
	  else if (IADDR[9: 6] == 2'hB) begin
		  assign OPCODE = 7'd23;
	  end
	  /* ORRr */
	  else if (IADDR[9: 6] == 2'hC) begin
		  assign OPCODE = 7'd24;
	  end
	  /* MUL */
	  else if (IADDR[9: 6] == 2'hD) begin
		  assign OPCODE = 7'd25;
	  end
	  /* BICr */
	  else if (IADDR[9: 6] == 2'hE) begin
		  assign OPCODE = 7'd26;
	  end
	  /* MVNr */
	  else if (IADDR[9: 6] == 2'hF) begin
		  assign OPCODE = 7'd27;
	  end
  end

  /*
	 ADDr2
	 CMPr2
	 MOVr1
	 BX
	 BLX
   */
  else if (IADDR[15: 10] == 2'h11) begin
	  /* ADDr2 */
	  if (IADDR[9: 8] == 2'h0) begin
		  assign OPCODE = 7'd28;
	  end
	  /* CMPr2 */
	  else if (IADDR[9: 8] == 2'h1) begin
		  assign OPCODE = 7'd29;
	  end
	  /* MOVr1 */
	  else if (IADDR[9: 8] == 2'h2) begin
		  assign OPCODE = 7'd30;
	  end
	  else if (IADDR[9: 8] == 2'h3) begin
		  /* BX */
		  if (IADDR_[7) == 2'h0) begin
			  assign OPCODE = 7'd31;
		  end
		  /* BLX */
		  else if (IADDR_(7) == 2'h1) begin
			  assign OPCODE = 7'd32;
		  end
	  end
  end

  /*
	 LDR(PC-relative)
   */
  else if (IADDR(15: 11] == 2'h09) begin
	  assign OPCODE = 7'd33;
  end

  /*
	 STRr
	 STRHr
	 STRBr
	 LDRSBr
	 LDRr
	 LDRHr
	 LDRBr
	 LDRSHr
   */
  else if (IADDR[15: 12] == 2'h05) begin
	  /* STRr */
	  if (IADDR[11: 9] == 2'h0) begin
		  assign OPCODE = 7'd34;
	  end
	  /* STRHr */
	  else if (IADDR[11: 9] == 2'h1) begin
		  assign OPCODE = 7'd35;
	  end
	  /* STRBr */
	  else if (IADDR[11: 9] == 2'h2) begin
		  assign OPCODE = 7'd36;
	  end
	  /* LDRSBr */
	  else if (IADDR[11: 9] == 2'h3) begin
		  assign OPCODE = 7'd37;
	  end
	  /* LDRr */
	  else if (IADDR[11: 9] == 2'h4) begin
		  assign OPCODE = 7'd38;
	  end
	  /* LDRHr */
	  else if (IADDR[11: 9] == 2'h5) begin
		  assign OPCODE = 7'd39;
	  end
	  /* LDRBr */
	  else if (IADDR[11: 9] == 2'h6) begin
		  assign OPCODE = 7'd40;
	  end
	  /* LDRSHr */
	  else if (IADDR[11: 9] == 2'h7) begin
		  assign OPCODE = 7'd41
	  end
  end

  /*
	 STR5i
	 LDR5i
	 STRBi
	 LDRBi
   */
  else if (IADDR[15: 13] == 2'h03) begin
	  /* STR5i */
	  if (IADDR[12: 11] == 2'h0) begin
		  assign OPCODE = 7'd42;
	  end
	  /* LDR5i */
	  else if (IADDR[12: 11] == 2'h1) begin
		  assign OPCODE = 7'd43;
	  end
	  /* STRBi */
	  else if (IADDR[12: 11] == 2'h2) begin
		  assign OPCODE = 7'd44;
	  end
	  /* LDRBi */
	  else if (IADDR[12: 11] == 2'h3) begin
		  assign OPCODE = 7'd45;
	  end
  end

  /*
	 STRHi
	 LDRHi
	 STR8i
	 LDR8i
   */
  else if (IADDR[15: 13] == 2'h04) begin
	  /* STRHi */
	  if (IADDR[12: 11] == 2'h0) begin
		  assign OPCODE = 7'd46;
	  end
	  /* LDRHi */
	  else if (IADDR[12: 11] == 2'h1) begin
		  assign OPCODE = 7'd47;
	  end
	  /* STR8i */
	  else if (IADDR[12: 11] == 2'h2) begin
		  assign OPCODE = 7'd48;
	  end
	  /* LDR8i */
	  else if (IADDR[12: 11] == 2'h3) begin
		  assign OPCODE = 7'd49;
	  end
  end

  /*
	 ADR
   */
  else if (IADDR[15: 11] == 2'h14) begin
	  assign OPCODE = 7'd50;
  end

  /*
	 ADDSPi1
   */
  else if (IADDR[15: 11] == 2'h15) begin
	  assign OPCODE = 7'd51;
  end

  /*
	 ADDSPi2
	 SUBSPi
	 SXTH
	 SXTB
	 UXTH
	 UXTB
	 PUSH
	 REV
	 REV16
	 REVSH
	 POP
   */
  else if (IADDR[15: 12] == 2'h0B) begin
	  if (IADDR[11: 8] == 2'h0) begin
		  /* ADDSPi2 */
		  if (IADDR_[7) == 2'h0) begin
			  assign OPCODE = 7'd52;
		  end
		  /* SUBSPi */
		  else if (IADDR_(7) == 2'h1) begin
			  assign OPCODE = 7'd53;
		  end
	  end
	  else if (IADDR(11: 8] == 2'h2) begin
		  /* SXTH */
		  if (IADDR[7: 6] == 2'h0) begin
			  assign OPCODE = 7'd54;
		  end
		  /* SXTB */
		  else if (IADDR[7: 6] == 2'h1) begin
			  assign OPCODE = 7'd55;
		  end
		  /* UXTH */
		  else if (IADDR[7: 6] == 2'h2) begin
			  assign OPCODE = 7'd56;
		  end
		  /* UXTB */
		  else if (IADDR[7: 6] == 2'h3) begin
			  assign OPCODE = 7'd57;
		  end
	  end
	  /* PUSH */
	  else if (IADDR[11: 9] == 2'h2) begin
		  assign OPCODE = 7'd58;
	  end
	  else if (IADDR[11: 9] == 2'h5) begin
		  if (IADDR_[8) == 2'h0) begin
			  /* REV */
			  if (IADDR(7: 6] == 2'h0) begin
				  assign OPCODE = 7'd59;
			  end
			  /* REV16 */
			  else if (IADDR[7: 6] == 2'h1) begin
				  assign OPCODE = 7'd60;
			  end
			  /* REVSH */
			  else if (IADDR[7: 6] == 2'h3) begin
				  assign OPCODE = 7'd61;
			  end
		  end
	  end
	  /* POP */
	  else if (IADDR[11: 9] == 2'h6) begin
		  assign OPCODE = 7'd62;
	  end
  end

  /*
	 STM
   */
  else if (IADDR[15: 11] == 2'h18) begin
	  assign OPCODE = 7'd63;
  end

  /*
	 LDM
   */
  else if (IADDR[15: 11] == 2'h19) begin
	  assign OPCODE =  7'd64;
  end

  /*
	 B (conditional)
   */
  else if (IADDR[15: 12] == 2'h0D) begin
	  assign OPCODE = 7'd65;
  end

  /* Already Implemented. */
  else if (IADDR[15: 11] == 2'h1C) begin
	  assign OPCODE = 7'd66;
  end
  else if (IADDR[15: 11] == 2'h1E) begin
	  assign OPCODE = 7'd67;
	    end
  else begin
  end
endmodule

////////////////////////////////////////////////////////////////////////////
module	EXE(
	input	wire	[31:0]	IADDR,
	input	wire	[6:0]	OPCODE,

	output    wire               WEN1,    // WRITE ENABLE1 (ACTIVE HIGH)
	output    wire   [3:0]       WA1,    // WRITE ADDRESS1
	output    wire   [31:0]      DI1,     // DATA INPUT1
	output    wire               WEN2,    // WRITE ENABLE2 (ACTIVE HIGH)
	output    wire   [3:0]       WA2,     // WRITE ADDRESS2
	output    wire    [31:0]      DI2     // DATA INPUT2
	output    wire    [3:0]       RA0;    // READ ADDRESS 0
	output    wire   [3:0]       RA1;    // READ ADDRESS 1
	output    wire   [3:0]       RA2;    // READ ADDRESS 2

);

reg [4:0]	imm5;
reg [2:0]	Rm, Rd;
reg [7:0]	imm8;
reg [31:0]	imm32;
always @ (IADDR) begin
	case (OPCODE)
		7'd1:
		7'd2:
		7'd3:
		7'd4:
		7'd5:
		7'd6:
		7'd7:
		7'd8:
			Rd = IADDR[10:8];
			imm8 = IADDR[7:0];
			imm32 = {24'b0,  imm8};
			
			assign WEN1 = 1'b1;
			assign WA1 = Rd;
			assign DI1 = imm32;

			APSR_N = imm32[31];
			APSR_Z = (imm32 == 0);
		7'd9:
		7'd10:
		7'd11:
		7'd12:
		7'd13:
		7'd14:
		7'd15:
		7'd16:
		7'd17:
		7'd18:
		7'd19:
		7'd20:
		7'd21:
		7'd22:
		7'd23:
		7'd24:
		7'd25:
		7'd26:
		7'd27:
		7'd28:
		7'd29:
		7'd30:
		7'd31:
		7'd32:
		7'd33:
		7'd34:
		7'd35:
		7'd36:
		7'd37:
		7'd38:
		7'd39:
		7'd40:
		7'd41:
		7'd42:
		7'd43:
		7'd44:
		7'd45:
		7'd46:
		7'd47:
		7'd48:
		7'd49:
		7'd50:
		7'd51:
		7'd52:
		7'd53:
		7'd54:
		7'd55:
		7'd56:
		7'd57:
		7'd58:
		7'd59:
		7'd60:
		7'd61:
		7'd62:
		7'd63:
		7'd64:
		7'd65:
		7'd66:
		7'd67:
	endcase
end

endmodule
