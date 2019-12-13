module SRAM (
	input wire				  CLK,

	input wire				  CSN1,
	input wire	[11:0]	ADDR1,
	input wire				  WE1, 
	input wire	[3:0]		BE1,
	input wire	[31:0]	DI1, 
	output wire [31:0]	DO1,

	input wire				  CSN2,
	input wire	[11:0]	ADDR2,
	input wire				  WE2, 
	input wire	[3:0]		BE2,
	input wire	[31:0]	DI2, 
	output wire [31:0]	DO2
);
	
	reg	[31:0]		outline1, outline2;
	reg	[31:0]		ram[0 : 4095];
	reg	[31:0]		tmp_rd1, tmp_rd2;
	reg	[31:0]		tmp_wd1, tmp_wd2;

	parameter ROMDATA = "mem.hex";

	initial	begin
		$readmemh(ROMDATA, ram);
	end
	
	assign DO1 = outline1;
	assign DO2 = outline2;

	always @ (posedge CLK) begin
		if (~CSN1) begin			// chip select at negative
			if (~WE1) begin		// read operation
				tmp_rd1 = ram[ADDR1];
				if (BE1[0]) outline1[ 7: 0] = tmp_rd1[7:0];
				if (BE1[1]) outline1[15: 8] = tmp_rd1[15:8];
				if (BE1[2]) outline1[23:16] = tmp_rd1[23:16];
				if (BE1[3]) outline1[31:24] = tmp_rd1[31:24];
			end
			else begin		// write operation
				if (BE1[0]) tmp_wd1[ 7: 0] = DI1[ 7: 0];
				if (BE1[1]) tmp_wd1[15: 8] = DI1[15: 8];
				if (BE1[2]) tmp_wd1[23:16] = DI1[23:16];
				if (BE1[3]) tmp_wd1[31:24] = DI1[31:24];

				ram[ADDR1] = tmp_wd1;
			end
		end

		if (~CSN2) begin			// chip select at negative
			if (~WE2) begin		// read operation
				tmp_rd2 = ram[ADDR2];
				if (BE2[0]) outline2[ 7: 0] = tmp_rd2[7:0];
				if (BE2[1]) outline2[15: 8] = tmp_rd2[15:8];
				if (BE2[2]) outline2[23:16] = tmp_rd2[23:16];
				if (BE2[3]) outline2[31:24] = tmp_rd2[31:24];
			end
			else begin		// write operation
				if (BE2[0]) tmp_wd2[ 7: 0] = DI2[ 7: 0];
				if (BE2[1]) tmp_wd2[15: 8] = DI2[15: 8];
				if (BE2[2]) tmp_wd2[23:16] = DI2[23:16];
				if (BE2[3]) tmp_wd2[31:24] = DI2[31:24];

				ram[ADDR2] = tmp_wd2;
			end
		end
	end
endmodule
