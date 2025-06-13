module KSA(
    input [63:0] A, B,
    input Cin,
    output [63:0] Sum,
    output Cout
);

  wire [63:0] G0, P0, G1, P1, G2, P2, G3, P3, G4, P4, G5, P5, G6, P6;
  wire [63:0] C;

  // Level 0: Initial generate and propagate
  assign G0 = A & B;
  assign P0 = A ^ B;

  genvar i;

  // Stage 1: distance = 1
  generate
    for(i = 0; i < 64; i = i + 1) begin: Stage1
      assign G1[i] = (i > 0) ? (G0[i] | (P0[i] & G0[i-1])) : G0[i];
      assign P1[i] = (i > 0) ? (P0[i] & P0[i-1]) : P0[i];
    end
  endgenerate

  // Stage 2: distance = 2
  generate
    for(i = 0; i < 64; i = i + 1) begin: Stage2
      assign G2[i] = (i > 1) ? (G1[i] | (P1[i] & G1[i-2])) : G1[i];
      assign P2[i] = (i > 1) ? (P1[i] & P1[i-2]) : P1[i];
    end
  endgenerate

  // Stage 3: distance = 4
  generate
    for(i = 0; i < 64; i = i + 1) begin: Stage3
      assign G3[i] = (i > 3) ? (G2[i] | (P2[i] & G2[i-4])) : G2[i];
      assign P3[i] = (i > 3) ? (P2[i] & P2[i-4]) : P2[i];
    end
  endgenerate

  // Stage 4: distance = 8
  generate
    for(i = 0; i < 64; i = i + 1) begin: Stage4
      assign G4[i] = (i > 7) ? (G3[i] | (P3[i] & G3[i-8])) : G3[i];
      assign P4[i] = (i > 7) ? (P3[i] & P3[i-8]) : P3[i];
    end
  endgenerate

  // Stage 5: distance = 16
  generate
    for(i = 0; i < 64; i = i + 1) begin: Stage5
      assign G5[i] = (i > 15) ? (G4[i] | (P4[i] & G4[i-16])) : G4[i];
      assign P5[i] = (i > 15) ? (P4[i] & P4[i-16]) : P4[i];
    end
  endgenerate

  // Stage 6: distance = 32
  generate
    for(i = 0; i < 64; i = i + 1) begin: Stage6
      assign G6[i] = (i > 31) ? (G5[i] | (P5[i] & G5[i-32])) : G5[i];
      assign P6[i] = (i > 31) ? (P5[i] & P5[i-32]) : P5[i];
    end
  endgenerate

  // Carry generation
  assign C[0] = G0[0] | (P0[0] & Cin);

  generate
    for(i = 1; i < 64; i = i + 1) begin: CarryGen
      assign C[i] = G6[i-1] | (P6[i-1] & Cin);
    end
  endgenerate

  // Sum and Cout
  assign Sum  = P0 ^ {C[62:0], Cin};
  assign Cout = C[63];

endmodule
