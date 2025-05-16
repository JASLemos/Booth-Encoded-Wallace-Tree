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
  wire [63:0] G_stage [6:0];
  wire [63:0] P_stage [5:0];

  // Level 0
  assign G_stage[0] = A & B;
  assign P_stage[0] = A ^ B;

  genvar i;
  // Stage 1, j=1
  generate
    for(i=0;i<64;i=i+1) begin: Stage1
      assign G_stage[1][i] = (i > 0) ? (G_stage[0][i] | (G_stage[0][i-1] & P_stage[0][i])) : G_stage[0][i];
      assign P_stage[1][i] = (i >= 2) ? (P_stage[0][i] & P_stage[0][i-1]) : P_stage[0][i];
    end
  endgenerate

  // Stage 2, j=2
  generate
    for(i=0;i<64;i=i+1) begin: Stage2
      assign G_stage[2][i] = (i > 1) ? (G_stage[1][i] | (G_stage[1][i-2] & P_stage[1][i])) : G_stage[1][i];
      assign P_stage[2][i] = (i >= 4) ? (P_stage[1][i] & P_stage[1][i-2]) : P_stage[1][i];
    end
  endgenerate

  // Stage 3
  generate
    for(i=0;i<64;i=i+1) begin: Stage3
      assign G_stage[3][i] = (i > 3) ? (G_stage[2][i] | (G_stage[2][i-4] & P_stage[2][i])) : G_stage[2][i];
      assign P_stage[3][i] = (i >= 8) ? (P_stage[2][i] & P_stage[2][i-4]) : P_stage[2][i];
    end
  endgenerate

  // Stage 4
  generate
    for(i=0;i<64;i=i+1) begin: Stage4
      assign G_stage[4][i] = (i > 7) ? (G_stage[3][i] | (G_stage[3][i-8] & P_stage[3][i])) : G_stage[3][i];
      assign P_stage[4][i] = (i >= 16) ? (P_stage[3][i] & P_stage[3][i-8]) : P_stage[3][i];
    end
  endgenerate

  // Stage 5
  generate
    for(i=0;i<64;i=i+1) begin: Stage5
      assign G_stage[5][i] = (i > 15) ? (G_stage[4][i] | (G_stage[4][i-16] & P_stage[4][i])) : G_stage[4][i];
      assign P_stage[5][i] = (i >= 32) ? (P_stage[4][i] & P_stage[4][i-16]) : P_stage[4][i];
    end
  endgenerate

  // Stage 6
  // Only generates in the last level
  generate
    for(i=0;i<64;i=i+1) begin: Stage6
      assign G_stage[6][i] = (i >= 32) ? (G_stage[5][i] | (G_stage[5][i-32] & P_stage[5][i])) : G_stage[5][i];
    end
  endgenerate
  
  // Carries
  wire [63:0] C;
  assign C[0] = G_stage[0][0] | (P_stage[0][0] & Cin); 

  generate
    for(i=1;i<64;i=i+1) begin: Carries
      assign C[i] = G_stage[6][i - 1];
    end
  endgenerate

  // Outputs
  assign Sum = P_stage[0] ^ C;
  assign Cout = C[63];
    
endmodule