module Knowles(
    input [63:0] A, B,
    input Cin,
    output [63:0] Sum,
    output Cout
);

    /*
   Equations:
       Sum[i] = A[i] ^ B[i] ^ G[i-1:-1]
       G[i:j] = G[i:k] + P[i:k] & G[k-1:j]
       P[i:j] = P[i:k] & P[k-1:j]
  */
  
  // 6 levels for a 64 bit Adder
  wire [63:0] G0, P0, G1, P1, G2, P2, G3, P3, G4, P4, G5, P5, G6;

  // level 0, pre processing stage
  assign G0 = A & B;
  assign P0 = A ^ B;

  // Level 1
  genvar i;
  generate;
    for(i = 0;i < 64;i = i + 1)
    begin
      assign G1[i] = (i > 0) ? (G0[i] | (G0[i-1] & P0[i])) : G0[i];
      assign P1[i] = (i >= 2) ? (P0[i] & P0[i-1]) : P0[i];
    end
  endgenerate

  // Level 2
  generate
    for(i=0;i<64;i=i+1) begin: Stage2
      assign G2[i] = (i > 1) ? (G1[i] | (G1[i-2] & P1[i])) : G1[i];
      assign P2[i] = (i >= 4) ? (P1[i] & P1[i-2]) : P1[i];
    end
  endgenerate

  // Level 3
  generate
    for(i=0;i<64;i=i+1) begin: Stage3
        assign G3[i] = (i > 3) ? (G2[i] | (G2[i-4] & P2[i])) : G2[i];
        assign P3[i] = (i >= 8) ? (P2[i] & P2[i-4]) : P2[i];
    end
  endgenerate

  // Level 4
  generate
    for(i=0;i<64;i=i+1) begin: Stage4
      assign G4[i] = (i > 7) ? (G3[i] | (G3[i-8] & P3[i])) : G3[i];
      assign P4[i] = (i >= 16) ? (P3[i] & P3[i-8]) : P3[i];
    end
  endgenerate

  // Level 5
  generate
    for(i=0;i<64;i=i+1) begin: Stage5
      assign G5[i] = (i > 15) ? (G4[i] | (G4[i-16] & P4[i])) : G4[i];
      assign P5[i] = (i >= 32) ? (P4[i] & P4[i-16]) : P4[i];
    end
  endgenerate

  // Level 6
  generate
    for(i=0;i<64;i=i+1) begin: Stage6
      assign G6[i] = (i >= 32) ? (G5[i] | (G5[i-32] & P5[i])) : G5[i];
    end
  endgenerate

  // Carries
  wire [63:0] C;
  assign C[0] = G0[0] | (P0[0] & Cin); 

  generate
    for(i=1;i<64;i=i+1) begin: Carries
      assign C[i] = G6[i - 1];
    end
  endgenerate

  // Outputs
  assign Sum = P0 ^ C;
  assign Cout = C[63];
    
endmodule
