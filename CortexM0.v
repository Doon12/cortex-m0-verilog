
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

assign IADDR = EXE_PC;

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
	INSTR(INSTR),
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
	input wire	[31:0]	INSTR,
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
  if (INSTR[15: 14] == 2'h0) begin
	  /* LSLi */
	  if (INSTR[13: 11] == 2'h0) begin
		  assign OPCODE = 7'd1;
	  end
	  /* LSRi */
	  else if (INSTR[13: 11] == 2'h1) begin
		  assign OPCODE = 7'd2;
	  end
	  /* ASRi */
	  else if (INSTR[13: 11] == 2'h2) begin
		  assign OPCODE = 7'd3;
	  end
	  else if (INSTR[13: 11] == 2'h3) begin
		  /* ADDr1 */
		  if (INSTR[10: 9] == 2'h0) begin
			  assign OPCODE = 7'd4;
		  end
		  /* SUBr */
		  else if (INSTR[10:9] == 2'h1) begin
			  assign OPCODE = 7'd5;
		  end
		  /* ADD3i */
		  else if (INSTR[10:9] == 2'h2) begin
			  assign OPCODE = 7'd6;
		  end
		  /* SUB3i */
		  else if (INSTR[10:9] == 2'h3) begin
			  assign OPCODE = 7'd7;
		  end
	  end
	  /* MOVi */
	  else if (INSTR[13: 11] == 2'h4) begin
		  assign OPCODE = 7'd8;
	  end
	  /* CMPi */
	  else if (INSTR[13: 11] == 2'h5) begin
		  assign OPCODE = 7'd9;
	  end
	  /* ADD8i */
	  else if (INSTR[13: 11] == 2'h6) begin
		  assign OPCODE = 7'd10;
	  end
	  /* SUB8i */
	  else if (INSTR[13: 11] == 2'h7) begin
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
  else if (INSTR[15: 10] == 2'h10) begin
	  /* ANDr */
	  if (INSTR[9: 6] == 2'h0) begin
		  assign OPCODE = 7'd12;
	  end
	  /* EORr */
	  else if (INSTR[9: 6] == 2'h1) begin
		  assign OPCODE = 7'd13;
	  end
	  /* LSLr */
	  else if (INSTR[9: 6] == 2'h2) begin
		  assign OPCODE = 7'd14;
	  end
	  /* LSRr */
	  else if (INSTR[9: 6] == 2'h3) begin
		  assign OPCODE = 7'd15;
	  end
	  /* ASRr */
	  else if (INSTR[9: 6] == 2'h4) begin
		  assign OPCODE = 7'd16;
	  end
	  /* ADCr */
	  else if (INSTR[9: 6] == 2'h5) begin
		  assign OPCODE = 7'd17;
	  end
	  /* SBCr */
	  else if (INSTR[9: 6] == 2'h6) begin
		  assign OPCODE = 7'd18;
	  end
	  /* RORr */
	  else if (INSTR[9: 6] == 2'h7) begin
		  assign OPCODE = 7'd19;
	  end
	  /* TSTr */
	  else if (INSTR[9: 6] == 2'h8) begin
		  assign OPCODE = 7'd20;
	  end
	  /* RSBi */
	  else if (INSTR[9: 6] == 2'h9) begin
		  assign OPCODE = 7'd21;
	  end
	  /* CMPr1 */
	  else if (INSTR[9: 6] == 2'hA) begin
		  assign OPCODE = 7'd22;
	  end
	  /* CMNr */
	  else if (INSTR[9: 6] == 2'hB) begin
		  assign OPCODE = 7'd23;
	  end
	  /* ORRr */
	  else if (INSTR[9: 6] == 2'hC) begin
		  assign OPCODE = 7'd24;
	  end
	  /* MUL */
	  else if (INSTR[9: 6] == 2'hD) begin
		  assign OPCODE = 7'd25;
	  end
	  /* BICr */
	  else if (INSTR[9: 6] == 2'hE) begin
		  assign OPCODE = 7'd26;
	  end
	  /* MVNr */
	  else if (INSTR[9: 6] == 2'hF) begin
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
  else if (INSTR[15: 10] == 2'h11) begin
	  /* ADDr2 */
	  if (INSTR[9: 8] == 2'h0) begin
		  assign OPCODE = 7'd28;
	  end
	  /* CMPr2 */
	  else if (INSTR[9: 8] == 2'h1) begin
		  assign OPCODE = 7'd29;
	  end
	  /* MOVr1 */
	  else if (INSTR[9: 8] == 2'h2) begin
		  assign OPCODE = 7'd30;
	  end
	  else if (INSTR[9: 8] == 2'h3) begin
		  /* BX */
		  if (INSTR_[7) == 2'h0) begin
			  assign OPCODE = 7'd31;
		  end
		  /* BLX */
		  else if (INSTR_(7) == 2'h1) begin
			  assign OPCODE = 7'd32;
		  end
	  end
  end

  /*
	 LDR(PC-relative)
   */
  else if (INSTR(15: 11] == 2'h09) begin
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
  else if (INSTR[15: 12] == 2'h05) begin
	  /* STRr */
	  if (INSTR[11: 9] == 2'h0) begin
		  assign OPCODE = 7'd34;
	  end
	  /* STRHr */
	  else if (INSTR[11: 9] == 2'h1) begin
		  assign OPCODE = 7'd35;
	  end
	  /* STRBr */
	  else if (INSTR[11: 9] == 2'h2) begin
		  assign OPCODE = 7'd36;
	  end
	  /* LDRSBr */
	  else if (INSTR[11: 9] == 2'h3) begin
		  assign OPCODE = 7'd37;
	  end
	  /* LDRr */
	  else if (INSTR[11: 9] == 2'h4) begin
		  assign OPCODE = 7'd38;
	  end
	  /* LDRHr */
	  else if (INSTR[11: 9] == 2'h5) begin
		  assign OPCODE = 7'd39;
	  end
	  /* LDRBr */
	  else if (INSTR[11: 9] == 2'h6) begin
		  assign OPCODE = 7'd40;
	  end
	  /* LDRSHr */
	  else if (INSTR[11: 9] == 2'h7) begin
		  assign OPCODE = 7'd41
	  end
  end

  /*
	 STR5i
	 LDR5i
	 STRBi
	 LDRBi
   */
  else if (INSTR[15: 13] == 2'h03) begin
	  /* STR5i */
	  if (INSTR[12: 11] == 2'h0) begin
		  assign OPCODE = 7'd42;
	  end
	  /* LDR5i */
	  else if (INSTR[12: 11] == 2'h1) begin
		  assign OPCODE = 7'd43;
	  end
	  /* STRBi */
	  else if (INSTR[12: 11] == 2'h2) begin
		  assign OPCODE = 7'd44;
	  end
	  /* LDRBi */
	  else if (INSTR[12: 11] == 2'h3) begin
		  assign OPCODE = 7'd45;
	  end
  end

  /*
	 STRHi
	 LDRHi
	 STR8i
	 LDR8i
   */
  else if (INSTR[15: 13] == 2'h04) begin
	  /* STRHi */
	  if (INSTR[12: 11] == 2'h0) begin
		  assign OPCODE = 7'd46;
	  end
	  /* LDRHi */
	  else if (INSTR[12: 11] == 2'h1) begin
		  assign OPCODE = 7'd47;
	  end
	  /* STR8i */
	  else if (INSTR[12: 11] == 2'h2) begin
		  assign OPCODE = 7'd48;
	  end
	  /* LDR8i */
	  else if (INSTR[12: 11] == 2'h3) begin
		  assign OPCODE = 7'd49;
	  end
  end

  /*
	 ADR
   */
  else if (INSTR[15: 11] == 2'h14) begin
	  assign OPCODE = 7'd50;
  end

  /*
	 ADDSPi1
   */
  else if (INSTR[15: 11] == 2'h15) begin
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
  else if (INSTR[15: 12] == 2'h0B) begin
	  if (INSTR[11: 8] == 2'h0) begin
		  /* ADDSPi2 */
		  if (INSTR_[7) == 2'h0) begin
			  assign OPCODE = 7'd52;
		  end
		  /* SUBSPi */
		  else if (INSTR_(7) == 2'h1) begin
			  assign OPCODE = 7'd53;
		  end
	  end
	  else if (INSTR(11: 8] == 2'h2) begin
		  /* SXTH */
		  if (INSTR[7: 6] == 2'h0) begin
			  assign OPCODE = 7'd54;
		  end
		  /* SXTB */
		  else if (INSTR[7: 6] == 2'h1) begin
			  assign OPCODE = 7'd55;
		  end
		  /* UXTH */
		  else if (INSTR[7: 6] == 2'h2) begin
			  assign OPCODE = 7'd56;
		  end
		  /* UXTB */
		  else if (INSTR[7: 6] == 2'h3) begin
			  assign OPCODE = 7'd57;
		  end
	  end
	  /* PUSH */
	  else if (INSTR[11: 9] == 2'h2) begin
		  assign OPCODE = 7'd58;
	  end
	  else if (INSTR[11: 9] == 2'h5) begin
		  if (INSTR_[8) == 2'h0) begin
			  /* REV */
			  if (INSTR(7: 6] == 2'h0) begin
				  assign OPCODE = 7'd59;
			  end
			  /* REV16 */
			  else if (INSTR[7: 6] == 2'h1) begin
				  assign OPCODE = 7'd60;
			  end
			  /* REVSH */
			  else if (INSTR[7: 6] == 2'h3) begin
				  assign OPCODE = 7'd61;
			  end
		  end
	  end
	  /* POP */
	  else if (INSTR[11: 9] == 2'h6) begin
		  assign OPCODE = 7'd62;
	  end
  end

  /*
	 STM
   */
  else if (INSTR[15: 11] == 2'h18) begin
	  assign OPCODE = 7'd63;
  end

  /*
	 LDM
   */
  else if (INSTR[15: 11] == 2'h19) begin
	  assign OPCODE =  7'd64;
  end

  /*
	 B (conditional)
   */
  else if (INSTR[15: 12] == 2'h0D) begin
	  assign OPCODE = 7'd65;
  end

  /* Already Implemented. */
  else if (INSTR[15: 11] == 2'h1C) begin
	  assign OPCODE = 7'd66;
  end
  else if (INSTR[15: 11] == 2'h1E) begin
	  assign OPCODE = 7'd67;
	    end
  else begin
  end
endmodule

////////////////////////////////////////////////////////////////////////////
module	EXE(
	input	wire	[31:0]	INSTR,
	input	wire	[6:0]	OPCODE,

	// Input pin
	input	wire	[31:0]	PC_IN,
	input	wire	[31:0]  SP_IN,
	input	wire	[31:0]		APSR_N_IN,
	input	wire	[31:0]		APSR_Z_IN,
	input	wire	[31:0]		APSR_C_IN,
	input	wire	[31:0]		APSR_V_IN,

	// Register WRITE PORT
	output    wire               WEN1,    // WRITE ENABLE1 (ACTIVE HIGH)
	output    wire   [3:0]       WA1,    // WRITE ADDRESS1
	output    wire   [31:0]      DI1,     // DATA INPUT1
	output    wire               WEN2,    // WRITE ENABLE2 (ACTIVE HIGH)
	output    wire   [3:0]       WA2,     // WRITE ADDRESS2
	output    wire    [31:0]      DI2     // DATA INPUT2
	// Register READ PORT
	output    wire    [3:0]       RA0,    // READ ADDRESS 0
	output    wire   [3:0]       RA1,    // READ ADDRESS 1
	output    wire   [3:0]       RA2,    // READ ADDRESS 2
	input	  wire	 [31:0]	     DOUT0,  // DATA OUTPUT 0
	input	  wire	 [31:0]	     DOUT1,  // DATA OUTPUT 0
	input	  wire	 [31:0]	     DOUT2,  // DATA OUTPUT 0

	// For data memory
	output wire	    		DREQ,
	output wire	[31:0]	DADDR,
	output wire	  			DRW,
	output wire	[ 1:0]	DSIZE,
	input	wire	[31:0]	DIN,
	output wire	[31:0]	DOUT

	// Output pin
	output	wire	[31:0]	PC_OUT,
	output	wire	BRANCH_OUT,
	output	wire	[31:0]	SP_OUT,
	output	wire	[31:0]	LR_OUT,
	output	wire	[31:0]		APSR_N_OUT,
	output	wire	[31:0]		APSR_Z_OUT,
	output	wire	[31:0]		APSR_C_OUT,
	output	wire	[31:0]		APSR_V_OUT,
);

// parse INSTR
reg [4:0]	imm5;
reg [2:0]	imm3, m, d, n, t;
reg [3:0] mm;
reg dn, D, N;
reg [7:0]	imm8;
reg [31:0]	imm32;

always @ (INSTR) begin
	case (OPCODE)
		7'd1: begin
		/* lsli */
			imm5 <= INSTR[10:6];
			d <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	result, carry, Rd, Rm, shift_n;

			// Rm = R[m]
			assign RA1 = m;
			Rm <= DOUT1;
			shift_n <= {27'b0, imm5};

			if (imm5 == 5'b0) begin
				// Register READ port
				assign RA0 = d;
				Rd <= DOUT0;

				// Register WRITE Port
				// R[d] = Rm
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = Rm;

				// Set flags
				assign APSR_N_OUT = Rd;
				assign APSR_Z_OUT = (Rd == 0);
			end
			else begin
				Shift_C lsli_shift_c (
					.result(result),
					.carry_out(carry),
					.value(Rm),
					.SRType(SRType_LSL),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

				// Register WRITE Port
				// R[d] = result
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = result;

				// Set flags
				assign APSR_N_OUT = result[31];
				assign APSR_Z_OUT = (result == 0);
				assign APSR_C_OUT = carry;
			end
		end
		7'd2: begin
		/* lsri */
			imm5 <= INSTR[10:6];
			d <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	result, carry, Rd, Rm, shift_n;

			// Rm = R[m]
			assign RA1 = m;
			Rm <= DOUT1;
			shift_n <= {27'b0, imm5};

			Shift_C lsri_shift_c (
				.result(result),
				.carry_out(carry),
				.value(Rm),
				.SRType(SRType_LSR),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
		end

		7'd3: begin
		/* asri */
			imm5 <= INSTR[10:6];
			d <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	result, carry, Rm, shift_n;

			// Rm = R[m]
			assign RA1 = m;
			Rm <= DOUT1;
			shift_n <= {27'b0, imm5};

			Shift_C asri_shift_c (
				.result(result),
				.carry_out(carry),
				.value(Rm),
				.SRType(SRType_ASR),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
		end
		7'd4: begin
		/* addr1 */
			m <= INSTR[8:6];
			n <= INSTR[5:3];
			d <= INSTR[2:0];

			reg [31:0]	shifted, result, carry, overflow, Rm, Rn, shift_n;

			// Rm = R[m]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;
			shift_n <= 32'b0;

			Shift addr1_shift (
				.result(shifted),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			ADDwithCarry addr1_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(shifted),
				.cin(0)
			);

			if (d == 32'd15) begin
				asssign PC_OUT = result & 32'hFFFFFFFE;
			end
			else begin
				// Register WRITE Port
				// R[d] = result
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = result;
				
				// Set flags
				assign APSR_N_OUT = result[31];
				assign APSR_Z_OUT = (result == 0);
				assign APSR_C_OUT = carry;
				assign APSR_V_OUT = overflow;
			end
		end

		7'd5: begin
		/* subr */
			m <= INSTR[8:6];
			n <= INSTR[5:3];
			d <= INSTR[2:0];

			reg [31:0]	shifted, result, carry, overflow, Rm, Rn, shift_n;

			// Rm = R[m]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;
			shift_n <= 32'b0;

			Shift subr_shift (
				.result(shifted),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			ADDwithCarry subr_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(!shifted),
				.cin(1'b1)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd6: begin
		/* add3i */
			imm3 <= INSTR[8:6];
			n <= INSTR[5:3];
			d <= INSTR[2:0];
			imm32 <= {29'b0 : imm3};

			reg [31:0]	result, carry, overflow, Rd, Rn;

			// Rd = R[d]
			// Rn = R[n]
			assign RA0 = n;
			assign RA1 = d;
			Rn <= DOUT0;
			Rd <= DOUT1;
			
			ADDwithCarry add3i_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(imm32),
				.cin(1'b0)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd7: begin
		/* sub3i */
			imm3 <= INSTR[8:6];
			n <= INSTR[5:3];
			d <= INSTR[2:0];
			imm32 <= {29'b0 : imm3};

			reg [31:0]	result, carry, overflow, Rd, Rn;

			// Rd = R[d]
			// Rn = R[n]
			assign RA0 = n;
			assign RA1 = d;
			Rn <= DOUT0;
			Rd <= DOUT1;
			
			ADDwithCarry add3i_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(!imm32),
				.cin(1'b1)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd8: begin
		/* movi */
			d <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {24'b0, imm8};

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = imm32;

			// Set flags
			assign APSR_N_OUT = imm32[31];
			assign APSR_Z_OUT = (imm32 == 0);
			assign APSR_C_OUT = APSR_C_IN;
		end

		7'd9: begin
		/* cmpi */
			n <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {24'b0, imm8};

			reg [31:0]	result, carry, overflow, Rn;

			// Rn = R[n]
			assign RA0 = n;
			Rn <= DOUT0;
			
			ADDwithCarry cmpi_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(!imm32),
				.cin(1'b1)
			);

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd10: begin
		/* add8i */
			d <= INSTR[10:8];
			n <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {24'b0, imm8};

			reg [31:0]	result, carry, overflow, Rn;

			// Rn = R[n]
			assign RA0 = n;
			Rn <= DOUT0;
			
			ADDwithCarry add8i_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(imm32),
				.cin(1'b0)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd11: begin
		/* sub8i */
			d <= INSTR[10:8];
			n <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {24'b0, imm8};

			reg [31:0]	result, carry, overflow, Rn;

			// Rn = R[n]
			assign RA0 = n;
			Rn <= DOUT0;
			
			ADDwithCarry sub8i_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(!imm32),
				.cin(1'b1)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd12: begin
		/* andr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shifted, carry, result, shift_n;

			shift_n <= 32'b0;

			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			Shift_C andr_shift_c (
					.result(shifted),
					.carry_out(carry),
					.value(Rm),
					.SRType(SRType_LSL),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

			// Register WRITE Port
			// R[d] = R[n] & shifted
			result <= Rn & shifted;
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd13: begin
		/* eorr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shifted, carry, result, shift_n;

			shift_n <= 32'b0;

			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			Shift_C eorr_shift_c (
					.result(shifted),
					.carry_out(carry),
					.value(Rm),
					.SRType(SRType_LSL),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

			// Register WRITE Port
			// R[d] = R[n] ^ shifted
			result <= Rn ^ shifted;
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd14:  begin
		/* lslr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, carry, result, Rm, Rn;
			
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n = {24'b0, Rm[7:0]};

			Shift_C lslr_shift_c (
					.result(result),
					.carry_out(carry),
					.value(Rm),
					.SRType(SRType_LSL),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd15: begin
		/* lsrr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, carry, result, Rm, Rn;
			
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n = {24'b0, Rm[7:0]};

			Shift_C lsrr_shift_c (
					.result(result),
					.carry_out(carry),
					.value(Rn),
					.SRType(SRType_LSR),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd16: begin
		/* asrr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, carry, result, Rm, Rn;
			
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n = {24'b0, Rm[7:0]};

			Shift_C asrr_shift_c (
					.result(result),
					.carry_out(carry),
					.value(Rn),
					.SRType(SRType_ASR),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd17: begin
		/* adcr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, shifted, carry, result, overflow, Rm, Rn;
			
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n = 32'b0;

			Shift adcr_shift (
				.result(shifted),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			ADDwithCarry adcr_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(shifted),
				.cin(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd18: begin
		/* sbcr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, shifted, carry, result, overflow, Rm, Rn;
			
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n = 32'b0;

			Shift sbcr_shift (
				.result(shifted),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			ADDwithCarry adcr_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(!shifted),
				.cin(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd19: begin
		/* rorr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, carry, result, Rm, Rn;
			
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n = {24'b0, Rm[7:0]};
			
			Shift_C rorr_shift_c (
				.result(result),
				.carry_out(carry),
				.value(Rn),
				.SRType(SRType_ROR),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end


		7'd20: begin
		/* tstr */
			d <= INSTR[2:0];
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, shifted, carry, result, Rm, Rn;
			
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n = 32'b0;
			
			Shift_C tstr_shift_c (
				.result(shifted),
				.carry_out(carry),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = Rn & shifted
			result <= Rn & shifted;
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd21: begin
		/* rsbr */
			d <= INSTR[2:0];
			n <= INSTR[5:3];
			imm32 <= 32'h00000000;

			reg [31:0]	shift_n, carry, result, overflow, Rn;
			
			// Rn = R[n]
			assign RA1 = n;
			Rn <= DOUT1;

			ADDwithCarry rsbr_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(!Rn),
				.y(imm32),
				.cin(1'b1)
			);

		
			// Register WRITE Port
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd22: begin
		/* cmpr1 */
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, shifted, carry, result, overflow, Rn, Rm;
			
			// Rn = R[n]
			// Rm = R[m]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			shifted_n <= 32'b0;

			Shift cmpr1_shift (
				.result(shifted),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			ADDwithCarry cmpr1_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(!shifted),
				.cin(1'b1)
			);

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd23: begin
		/* cmnr */
			n <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, shifted, carry, result, overflow, Rn, Rm;
			
			// Rn = R[n]
			// Rm = R[m]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			shifted_n <= 32'b0;

			Shift cmnr_shift (
				.result(shifted),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			ADDwithCarry cmnr_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(shifted),
				.cin(1'b0)
			);

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd24: begin
		/* orrr */
			n <= INSTR[2:0];
			d <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0]	shift_n, shifted, carry, result, Rn, Rm;
			
			// Rn = R[n]
			// Rm = R[m]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			shifted_n <= 32'b0;

			Shift_C orrr_shift_c (
				.result(shifted),
				.carry_out(carry),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);
	
			// Register WRITE Port
			// R[d] = Rn | shifted
			result <= Rn | shifted;
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd25: begin
		/* mul */
			d <= INSTR[2:0];
			m <= INSTR[2:0];
			n <= INSTR[5:3];

			reg [31:0]	op1, op2, Rn, Rm, Rd;
			wire [64:0]	result;
			
			// Rn = R[n]
			// Rm = R[m]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			assign result = Rn * Rm;

			// Register WRITE Port
			// R[d] = Rn | shifted
			Rd <= result[31:0];
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = Rd;

			// Set flags
			assign APSR_N_OUT = Rd[31];
			assign APSR_Z_OUT = (Rd == 0);
			assign APSR_C_OUT = APSR_C_IN;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd26: begin
		/* bicr */
			d <= INSTR[2:0];
			m <= INSTR[5:3];
			n <= INSTR[2:0];

			reg [31:0] shift_n, result, shifted, carry, Rn, Rm;

			// Rn = R[n]
			// Rm = R[m]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			shift_n <= 32'b0;

			Shift_C bicr_shift_c (
				.result(shifted),
				.carry_out(carry),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shifted_n),
				.carry_in(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = Rn & NOT(shifted)
			result <= Rn & !shifted;
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd27: begin
		/* mvnr */
			d <= INSTR[2:0];
			m <= INSTR[5:3];

			reg [31:0] shift_n, result, shifted, carry, Rm;

			// Rn = R[n]
			// Rm = R[m]
			assign RA1 = m;
			Rm <= DOUT1;

			shift_n <= 32'b0;

			Shift_C bicr_shift_c (
				.result(shifted),
				.carry_out(carry),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shifted_n),
				.carry_in(APSR_C_IN)
			);

			// Register WRITE Port
			// R[d] = NOT(shifted)
			result <= !shifted;
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = APSR_V_IN;
		end

		7'd28: begin
		/* addr2 */
			dn <= INSTR[7];
			mm <= INSTR[6:3];
			d <= INSTR[2:0];
			n <= INSTR[2:0];

			reg [31:0] shift_n, shifted, result, carry, overflow, Rm, Rn, Rd;

			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			assign RA1 = d;
			Rm <= DOUT0;
			Rn <= DOUT1;
			Rd <= DOUT2;

			shift_n <= 32'b0;

			if ( {DN, n} == 4'hD || mm == 5'hD) begin
				/* SEE ADD (SP plus register) */
				d <= 4'd13;

				Shift addr2_shift_1 (
					.result(shifted),
					.value(Rm),
					.SRType(SRType_LSL),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

				ADDwithCarry addr2_add_with_carry_1 (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(SP_IN),
				.y(shifted),
				.cin(32'b0)
				);

				// Register WRITE Port
				// R[d] = result
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = result;

				// no flag settings
				assign APSR_N_OUT = APSR_N_IN;
				assign APSR_Z_OUT = APSR_Z_IN;
				assign APSR_C_OUT = APSR_C_IN;
				assign APSR_V_OUT = APSR_V_IN;
			end
			else begin
				reg [31:0] Rd2, Rm2;
				Rd2 <= (dn << 3) | Rd;
				Rm2 <= Rm;

				Shift addr2_shift_2 (
					.result(shifted),
					.value(Rm2),
					.SRType(SRType_LSL),
					.amount(shift_n),
					.carry_in(APSR_C_IN)
				);

				ADDwithCarry addr2_add_with_carry_2 (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(shifted),
				.cin(32'b0)
				);

				if (d == 4'd15) begin
					assign PC_OUT = result & 32'hFFFFFFFE;
				end
				else begin
					// Register WRITE Port
					// R[d] = result
					assign WEN1 = 1'b1;
					assign WA1 = d;
					assign DI1 = result;

					// Set flags
					assign APSR_N_OUT = result[31];
					assign APSR_Z_OUT = (result == 0);
					assign APSR_C_OUT = carry;
					assign APSR_V_OUT = overflow;
				end
			end
		end

		7'd29: begin
		/* cmpr2 */
			N <= INSTR[7];
			mm <= INSTR[6:3];
			n <= INSTR[2:0];

			reg [31:0] shift_n, shifted, result, carry, overflow, Rm, Rn, Rd;

			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = m;
			assign RA1 = n;
			Rm <= DOUT0;
			Rn <= DOUT1;

			shift_n <= 32'b0;
			
			Shift cmpr2_shift (
				.result(shifted),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			ADDwithCarry cmpr2_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(Rn),
				.y(!shifted),
				.cin(1'b1)
			);

			// Set flags
			assign APSR_N_OUT = result[31];
			assign APSR_Z_OUT = (result == 0);
			assign APSR_C_OUT = carry;
			assign APSR_V_OUT = overflow;
		end

		7'd30: begin
		/* movr1 */
			D <= INSTR[7];
			mm <= INSTR[6:3];
			d <= INSTR[2:0];

			reg [31:0] dd, Rm;
			dd <= (D<<3) | d;

			// Rm = R[m]
			assign RA0 = m;
			Rm <= DOUT0;


			if (dd == 4'd15) begin
				assign BRANCH_OUT = 1'b1;
				assign PC_OUT = Rm & 32'hFFFFFFFE;
			end
			else begin
				// Register WRITE Port
				// R[d] = result
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = Rm;
			end
		end

		7'd31: begin
		/* bx */
			mm <= INSTR[6:3];

			reg [31:0] Rm;
			// Rmm = R[mm]
			assign RA0 = mm;
			Rm <= DOUT0;

			assign BRANCH_OUT = 1'b1;
			assign PC_OUT = Rm & 32'FFFFFFFE;
		end

		7'd32: begin
		/* blx */
			mm <= INSTR[6:3];

			reg [31:0] Rm;
			wire [31:0] temp;
			// Rmm = R[mm]
			assign RA0 = mm;
			Rm <= DOUT0;

			assign temp = PC_IN - 2;
			assign LR_OUT = temp | 32'h00000001;
			assign BRANCH_OUT = 1'b1;
			assign PC_OUT = Rm & 32'FFFFFFFE;
		end

		7'd33: begin
		/* ldrpcrel */
			t <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {24'b0, imm8};

			wire [31:0] base, address;
			assign base = (PC_IN >> 2) << 2;
			assign address = base + imm32;

			// word = read_word (address)
			reg [31:0] word;
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b10;
			word <= DIN;

			// R[t] = word
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = word;
		end
		7'd34: begin
		/* strr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rt, offset, address;
			// Rm = R[m]
			// Rt = R[t]
			assign RA0 = t;
			assign RA1 = m;
			Rt <= DOUT0;
			Rm <= DOUT1;

			Shift strr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* MemU[address, 4] = R[t] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 1;
			assign DSIZE = 2'b10;
			assign DOUT = Rt;
		end

		7'd35: begin
		/* strhr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rt, offset, address;
			// Rm = R[m]
			// Rt = R[t]
			assign RA0 = t;
			assign RA1 = m;
			Rt <= DOUT0;
			Rm <= DOUT1;

			Shift strhr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* MemU[address, 2] = R[t]<15, 0> */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 1;
			assign DSIZE = 2'b01;
			assign DOUT = Rt;
		end

		7'd36: begin
		/* strbr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rt, offset, address;
			// Rm = R[m]
			// Rt = R[t]
			assign RA0 = t;
			assign RA1 = m;
			Rt <= DOUT0;
			Rm <= DOUT1;

			Shift strbr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* MemU[address, 1] = R[t]<7,0> */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 1;
			assign DSIZE = 2'b00;
			assign DOUT = Rt;
		end

		7'd37: begin
		/* ldrsbr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rn, Rt, offset, address;
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			Shift ldrsbr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* Rt = signExtend( MemU[address, 1], 32) */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b00;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd38: begin
		/* ldrr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rn, Rt, offset, address;
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			Shift ldrr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* Rt = MemU[address, 4] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b10;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd39: begin
		/* ldrhr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rn, Rt, offset, address;
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			Shift ldrhr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* Rt = MemU[address, 2] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b01;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd40: begin
		/* ldrbr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rn, Rt, offset, address;
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			Shift ldrbr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* Rt = MemU[address, 1] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b00;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd41: begin
		/* ldrshr */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			m <= INSTR[8:6];

			reg [31:0] shift_n;
			shift_n <= 32'b0;

			reg [31:0] Rm, Rn, Rt, offset, address;
			// Rm = R[m]
			// Rn = R[n]
			assign RA0 = n;
			assign RA1 = m;
			Rn <= DOUT0;
			Rm <= DOUT1;

			Shift ldrshr_shift (
				.result(offset),
				.value(Rm),
				.SRType(SRType_LSL),
				.amount(shift_n),
				.carry_in(APSR_C_IN)
			);

			address <= Rn + offset;

			/* Rt = MemU[address, 2] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b01;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd42: begin
		/* str5i */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			imm5 <= INSTR[10:6];
			imm32 <= {27'b0, imm5};

			reg [31:0] Rn, Rt, address;
			// Rt = R[t]
			// Rn = R[n]
			assign RA0 = t;
			assign RA1 = n;
			Rt <= DOUT0;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* MemU[address, 4] = R[t] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 1;
			assign DSIZE = 2'b10;
			assign DOUT = Rt;
		end

		7'd43: begin
		/* ldr5i */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			imm5 <= INSTR[10:6];
			imm32 <= {27'b0, imm5};

			reg [31:0] Rn, Rt, address;
			// Rn = R[n]
			assign RA1 = n;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* Rt = MemU[address, 4] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b10;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd44: begin
		/* strbi */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			imm5 <= INSTR[10:6];
			imm32 <= {27'b0, imm5};

			reg [31:0] Rn, Rt, address;
			// Rt = R[t]
			// Rn = R[n]
			assign RA0 = t;
			assign RA1 = n;
			Rt <= DOUT0;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* MemU[address, 1] = R[t]<7, 0> */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 1;
			assign DSIZE = 2'b00;
			assign DOUT = Rt;
		end

		7'd45: begin
		/* ldrbi */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			imm5 <= INSTR[10:6];
			imm32 <= {27'b0, imm5};

			reg [31:0] Rn, Rt, address;
			// Rn = R[n]
			assign RA1 = n;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* Rt = MemU[address, 1] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b00;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd46: begin
		/* strhi */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			imm5 <= INSTR[10:6];
			imm32 <= {26'b0, (imm5<<1)};

			reg [31:0] Rn, Rt, address;
			// Rt = R[t]
			// Rn = R[n]
			assign RA0 = t;
			assign RA1 = n;
			Rt <= DOUT0;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* MemU[address, 2] = R[t]<15, 0> */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 1;
			assign DSIZE = 2'b01;
			assign DOUT = Rt;
		end

		7'd47: begin
		/* ldrhi */
			t <= INSTR[2:0];
			n <= INSTR[5:3];
			imm5 <= INSTR[10:6];
			imm32 <= {26'b0, (imm5<<1)};

			reg [31:0] Rn, Rt, address;
			// Rn = R[n]
			assign RA1 = n;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* Rt = MemU[address, 2] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b01;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd48: begin
		/* str8i */
			t <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {22'b0, (imm8<<2)};

			reg [31:0] Rn, Rt, address;
			// Rt = R[t]
			// Rn = R[n], n = 13
			assign RA0 = t;
			assign RA1 = 32'd13;
			Rt <= DOUT0;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* MemU[address, 4] = R[t] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 1;
			assign DSIZE = 2'b10;
			assign DOUT = Rt;
		end

		7'd49: begin
		/* ldrhi */
			t <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {22'b0, (imm8<<2)};

			reg [31:0] Rn, Rt, address;
			// Rn = R[n], n = 13
			// Rt = R[t]
			assign RA1 = 32'd13;
			Rn <= DOUT1;

			address = Rn + imm32;

			/* Rt = MemU[address, 4] */
			assign DREQ = 1;
			assign DADDR = address;
			assign DWE = 0;
			assign DSIZE = 2'b10;
			Rt <= DIN;

			// R[t] = Rt
			assign WEN1 = 1'b1;
			assign WA1 = t;
			assign DI1 = Rt;
		end

		7'd50: begin
		/* adr */
			d <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {22'b0 ,(imm8<<2)};
			reg [31:0] result;
			result <= (PC_IN & 32'hFFFFFFFC) + imm32;
			
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;
		end

		7'd51: begin
		/* addspi1 */
			d <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			imm32 <= {22'b0, (imm8<<2)};

			reg [31:0] result, carry, overflow;

			ADDwithCarry addspi1_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(SP_IN),
				.y(imm32),
				.cin(0)
			);

			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;
		end

		7'd52: begin
		/* addspi2 */
			reg [31:0] temp_d;
			temp_d <= 32'd13;
			imm7 <= INSTR[6:0];
			imm32 <= {23'b0, (imm7<<2)};

			reg [31:0] result, carry, overflow;

			ADDwithCarry addspi2_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(SP_IN),
				.y(imm32),
				.cin(0)
			);

			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;
		end
		7'd53: begin
		/* subspi */
			reg [31:0] temp_d;
			temp_d <= 32'd13;
			imm7 <= INSTR[6:0];
			imm32 <= {23'b0, (imm7<<2)};

			reg [31:0] result, carry, overflow;

			ADDwithCarry subspi_add_with_carry (
				.result(result),
				.carry(carry),
				.overflow(overflow),
				.x(SP_IN),
				.y(!imm32),
				.cin(1)
			);

			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;
		end

		7'd54: begin
		/* sxth */
			m <= INSTR[5:3];
			d <= INSTR[2:0];
			reg [31:0] rotated;
			assign RA0 = m;
			rotated <= DOUT0;

			// R[d] = signed rotated[15:0]
			if (rotated[7] == 1'b1) begin
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = {16'hFFFF, rotated[15:0]};
			end
			else begin
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = {16'b0, rotated[15:0]};
			end
		end

		7'd55: begin
		/* sxtb */
			m <= INSTR[5:3];
			d <= INSTR[2:0];
			reg [31:0] rotated;
			assign RA0 = m;
			rotated <= DOUT0;

			// R[d] = signed rotated[7:0]
			if (rotated[7] == 1'b1) begin
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = {24'hFFFFFF, rotated[7:0]};
			end
			else begin
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = {24'b0, rotated[7:0]};
			end
		end

		7'd56: begin
		/* uxth */
			m <= INSTR[5:3];
			d <= INSTR[2:0];
			reg [31:0] rotated;
			assign RA0 = m;
			rotated <= DOUT0;

			// R[d] = rotated[15:0]
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = {16'b0, rotated[15:0]};
		end

		7'd57: begin
		/* uxtb */
			m <= INSTR[5:3];
			d <= INSTR[2:0];
			reg [31:0] rotated;
			assign RA0 = m;
			rotated <= DOUT0;

			// R[d] = rotated[7:0]
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = {16'b0, rotated[7:0]};
		end

		7'd58: begin
		/* push */
			N <= INSTR[8];
			imm8 <= INSTR[7:0];
			reg [31:0] registers, address, address_next, count;
			registers <= (N<<14) | imm8;
			BitCount push_BitCount (
				.value(registers),
				.count(count)
			);
			address <= SP_IN - 4 * count;
			address_next <= address;

			integer i;
			for (i = 0; i < 15; i = i + 1) begin
				address <= address_next;
				if (registers[i] == 1'b1) begin
					/* MemU[address, 4] = R[i] */
					reg [31:0] Ri;
					assign RA0 = i;
					Ri <= DOUT0;
					assign DREQ = 1;
					assign DADDR = address;
					assign DWE = 1;
					assign DSIZE = 2'b10;
					assign DOUT = Ri;

					address_next <= address + 4;
				end
				else begin
					address_next <= address;
				end
			end

			assign SP_OUT = SP_IN - 4 * count;
		end

		7'd59: begin
		/* rev */
			m <= INSTR[5:3];
			d <= INSTR[2:0];
			reg [31:0] Rm;
			assign RA0 = m;
			Rm <= DOUT0;

			reg [31:0] first, second, third, fourth;
			reg [31:0] result;
			first <= Rm[7:0] << 24;
			second <= Rm[15:8] << 16;
			third <= Rm[23:16] << 8;
			fourth <= Rm[31:24];

			result <= first | second | third | fourth;
	
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;
		end

		7'd60: begin
		/* rev16 */
			m <= INSTR[5:3];
			d <= INSTR[2:0];
			reg [31:0] Rm;
			assign RA0 = m;
			Rm <= DOUT0;

			reg [31:0] first, second, third, fourth;
			reg [31:0] result;
			first <= Rm[23:16] << 24;
			second <= Rm[31:24] << 16;
			third <= Rm[7:0] << 8;
			fourth <= Rm[15:8];

			result <= first | second | third | fourth;
	
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;
		end
			
		7'd61: begin
		/* revsh */
			m <= INSTR[5:3];
			d <= INSTR[2:0];
			reg [31:0] Rm;
			assign RA0 = m;
			Rm <= DOUT0;

			reg [31:0] first, second;
			reg [31:0] result;
			reg [31:0] signRm;
			signRm <= { 24{Rm[7]} , Rm[7:0]};
			first <= signRm & 32'hFFFFFFFF;
			second <= Rm[15:8];

			result <= first | second;
	
			// R[d] = result
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = result;
		end
			
		7'd62: begin
		/* pop */
			N <= INSTR[8];
			reg [31:0] register_list, registers;
			register_list <= INSTR[7:0];
			registers <= (N << 15) | register_list;

			address_next <= SP_IN;

			for (i = 0; i < 15; i = i + 1) begin
				address <= address_next;
				if (registers[i] == 1'b1) begin
					reg [31:0] Ri;
					assign DREQ = 1;
					assign DADDR = address;
					assign DWE = 0;
					assign DSIZE = 2'b10;
					Ri <= DIN;

					// R[i] = Ri
					assign WEN1 = 1'b1;
					assign WA1 = i;
					assign DI1 = Ri;

					address_next <= address + 4;
				end
				else begin
					address_next <= address;
				end
		end

		7'd63: begin
		/* stm */
			d <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			reg [31:0] registers, address, address_next, count;
			
			assign RA0 = d;
			address <= DOUT0;

			integer i;
			for (i = 0; i < 15; i = i + 1) begin
				address <= address_next;
				/* MemU[address, 4] = R[i] */
				reg [31:0] Ri;
				assign RA0 = i;
				Ri <= DOUT0;

				assign DREQ = 1;
				assign DADDR = address;
				assign DWE = 1;
				assign DSIZE = 2'b10;
				assign DOUT = Ri;
				address_next <= address + 4;
			end

			reg [31:0] Rd, newRd, count;
			assign RA1 = d;
			Rd <= DOUT1;

			BitCount stm_BitCount (
				.value(address),
				.count(count)
			);

			newRd = Rd + 4 * count;
			
			// R[d] = newRd
			assign WEN1 = 1'b1;
			assign WA1 = d;
			assign DI1 = newRd;
		end

		7'd64: begin
		/* ldm */
			d <= INSTR[10:8];
			imm8 <= INSTR[7:0];
			reg [31:0] registers, address, address_next, count;
			
			assign RA0 = d;
			address <= DOUT0;

			integer i;
			for (i = 0; i < 7; i = i + 1) begin
				if (registers[i] == 1'b1) begin
					// word = read_word (address)
					reg [31:0] word;
					assign DREQ = 1;
					assign DADDR = address;
					assign DWE = 0;
					assign DSIZE = 2'b10;
					word <= DIN;

					// R[i] = word
					assign WEN1 = 1'b1;
					assign WA1 = i;
					assign DI1 = word;
				end
			end

			if (registers[d] == 1'b0) begin
				reg [31:0] Rd, newRd, count;
				assign RA1 = d;
				Rd <= DOUT1;

				BitCount stm_BitCount (
					.value(address),
					.count(count)
				);

				newRd = Rd + 4 * count;

				// R[d] = newRd
				assign WEN1 = 1'b1;
				assign WA1 = d;
				assign DI1 = newRd;
			end
		end

		7'd65: begin
		/* b_conditional */
			reg [31:0] cond, address;
			imm8 <= INSTR[7:0];
			cond <= INSTR[11:8];
			reg cond_pass;
			InitBlock b_c_InitBlock (
				.condition(cond),
				.pass(cond_pass)
			);

			if (cond_pass) begin
				reg signImm8;
				signImm8 <= {23{imm8[7]} , (imm8<<1)};
				address <= PC_IN + signImm8;
				assign BRANCH_OUT = 1'b1;
				assign PC_OUT = address & 32'hFFFFFFFE;
			end
		end

		7'd66: begin
		/* b_unconditional */
			reg [31:0] address;
			reg [31:0] imm11;
			imm11 <= INSTR[10:0];
			reg signImm11;
			signImm11 <= {20{imm11[10]} , (imm11<<1)};
			address <= PC_IN + signImm8;
			assign BRANCH_OUT = 1'b1;
			assign PC_OUT = address & 32'hFFFFFFFE;
		end

		7'd67: begin
		/* bl */
			reg [31:0] S, imm10, J1, J2, imm11, I1, I2, address;
			S <= INSTR[26];
			imm10 <= INSTR[25:16];
			J1 <= INSTR[13];
			J2 <= INSTR[11];
			imm11 <= INSTR[10:0];

			I1 <= !(J1 ^ S);
			I2 <= !(J2 ^ S);
			reg [31:0] tempImm32;
			tempImm32 <= (S << 24) | (I1 << 23) | (I2 << 22) | (imm10 << 12) | (imm11 << 1);
			imm32 <= {7{tempImm32[24]}, tempImm32[24:0]};

			assign LR_OUT = PC_IN | 32'h00000001;
			address <= PC_IN + imm32;
			assign BRANCH_OUT = 1'b1;
			assign PC_OUT = address & 32'hFFFFFFFE;
		end
	endcase
end

endmodule
