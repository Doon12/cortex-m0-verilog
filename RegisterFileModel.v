module REGFILE (
    input    wire                CLK, 
    input    wire                nRST,

    // WRITE PORT
    input    wire                WEN1,    // WRITE ENABLE1 (ACTIVE HIGH)
    input    wire    [3:0]       WA1,     // WRITE ADDRESS1
    input    wire    [31:0]      DI1,     // DATA INPUT1
    input    wire                WEN2,    // WRITE ENABLE2 (ACTIVE HIGH)
    input    wire    [3:0]       WA2,     // WRITE ADDRESS2
    input    wire    [31:0]      DI2,     // DATA INPUT2

    // READ PORT
    input    wire    [3:0]       RA0,    // READ ADDRESS 0
    input    wire    [3:0]       RA1,    // READ ADDRESS 1
    input    wire    [3:0]       RA2,    // READ ADDRESS 2
    output   wire    [31:0]      DOUT0,  // DATA OUTPUT 0
    output   wire    [31:0]      DOUT1,  // DATA OUTPUT 1
    output   wire    [31:0]      DOUT2   // DATA OUTPUT 2
);

    reg        [31:0]        REG[0:14];

    always @ (posedge CLK) begin
        if (~nRST) begin
            REG[0] <= 32'b0;REG[1] <= 32'b0;REG[2] <= 32'b0;REG[3] <= 32'b0;
            REG[4] <= 32'b0;REG[5] <= 32'b0;REG[6] <= 32'b0;REG[7] <= 32'b0;
            REG[8] <= 32'b0;REG[9] <= 32'b0;REG[10] <= 32'b0;REG[11] <= 32'b0;
            REG[12] <= 32'b0;REG[13] <= 32'b0;REG[14] <= 32'b0;
        end
        else begin
            if (WEN1)    REG[WA1] <= DI1;
            if (WEN2)    REG[WA2] <= DI2;
        end
    end

    assign              DOUT0    = REG[RA0];
    assign              DOUT1    = REG[RA1];
    assign              DOUT2    = REG[RA2];

endmodule
