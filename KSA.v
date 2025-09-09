module KSA(
    input  [63:0] A, B,
    input         Cin,
    output [63:0] Sum,
    output        Cout
);

    // Initial generate/propagate
    wire [63:0] G0, P0;
    assign G0 = A & B;
    assign P0 = A ^ B;

    // Prefix levels
    wire [63:0] G1, P1;
    wire [63:0] G2, P2;
    wire [63:0] G3, P3;
    wire [63:0] G4, P4;
    wire [63:0] G5, P5;
    wire [63:0] G6, P6;

    // -----------------------
    // Level 1: distance = 1
    // -----------------------
    assign G1[0] = G0[0];
    assign P1[0] = P0[0];
    genvar i;
    generate
        for (i = 1; i < 64; i = i + 1) begin
            assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
            assign P1[i] = P0[i] & P0[i-1];
        end
    endgenerate

    // -----------------------
    // Level 2: distance = 2
    // -----------------------
    assign G2[1:0] = G1[1:0];
    assign P2[1:0] = P1[1:0];
    generate
        for (i = 2; i < 64; i = i + 1) begin
            assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
            assign P2[i] = P1[i] & P1[i-2];
        end
    endgenerate

    // -----------------------
    // Level 3: distance = 4
    // -----------------------
    assign G3[3:0] = G2[3:0];
    assign P3[3:0] = P2[3:0];
    generate
        for (i = 4; i < 64; i = i + 1) begin
            assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
            assign P3[i] = P2[i] & P2[i-4];
        end
    endgenerate

    // -----------------------
    // Level 4: distance = 8
    // -----------------------
    assign G4[7:0] = G3[7:0];
    assign P4[7:0] = P3[7:0];
    generate
        for (i = 8; i < 64; i = i + 1) begin
            assign G4[i] = G3[i] | (P3[i] & G3[i-8]);
            assign P4[i] = P3[i] & P3[i-8];
        end
    endgenerate
    
    // -----------------------
    // Level 5: distance = 16
    // -----------------------
    assign G5[15:0] = G4[15:0];
    assign P5[15:0] = P4[15:0];
    generate
        for (i = 16; i < 64; i = i + 1) begin
            assign G5[i] = G4[i] | (P4[i] & G4[i-16]);
            assign P5[i] = P4[i] & P4[i-16];
        end
    endgenerate
    
    // -----------------------
    // Level 6: distance = 32
    // -----------------------
    assign G6[31:0] = G5[31:0];
    assign P6[31:0] = P5[31:0];
    generate
        for (i = 32; i < 64; i = i + 1) begin
             assign G6[i] = G5[i] | (P5[i] & G5[i-32]);
             assign P6[i] = P5[i] & P5[i-32];          
        end
    endgenerate
    
    // -----------------------
    // Carry computation
    // -----------------------
    wire [64:0] C;
    assign C[0] = Cin;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            assign C[i+1] = G6[i] | (P6[i] & Cin);
        end
    endgenerate

    // -----------------------
    // Sum and Cout
    // -----------------------
    assign Sum  = P0 ^ C[63:0];
    assign Cout = C[64];

endmodule
