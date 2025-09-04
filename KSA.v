module KSA(
  input [63:0] A, B,
  input Cin,
  output [63:0] Sum,
  output Cout
);

  // Level 0: Initial Generate and Propagate signals
  wire [63:0] G0, P0;
  assign G0 = A & B;
  assign P0 = A ^ B;

  // Wires for each level of the prefix network
  wire [63:0] G1, P1, G2, P2, G3, P3, G4, P4, G5, P5, G6, P6;
  genvar i;

  // Level 1 (distance = 1)
  generate
    for (i = 0; i < 64; i = i + 1) begin: L1
      if (i < 1) begin // Buffer
        assign G1[i] = G0[i];
        assign P1[i] = P0[i];
      end else if (i == 1) begin // Gray Cell
        assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
        assign P1[i] = P0[i];
      end else begin // Black Cell
        assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
        assign P1[i] = P0[i] & P0[i-1];
      end
    end
  endgenerate

  // Level 2 (distance = 2)
  generate
    for (i = 0; i < 64; i = i + 1) begin: L2
      if (i < 2) begin // Buffer
        assign G2[i] = G1[i];
        assign P2[i] = P1[i];
      end else if(i == 2 || i == 3) begin // Gray Cells
        assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
        assign P2[i] = P1[i];
      end else begin // Black Cell
        assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
        assign P2[i] = P1[i] & P1[i-2];
      end
    end
  endgenerate

  // Level 3 (distance = 4)
  generate
    for (i = 0; i < 64; i = i + 1) begin: L3
      if (i < 4) begin // Buffer
        assign G3[i] = G2[i];
        assign P3[i] = P2[i];
      end else if(i > 3 && i < 8) begin // Gray Cells
        assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
        assign P3[i] = P2[i];
      end else begin // Black Cell
        assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
        assign P3[i] = P2[i] & P2[i-4];
      end
    end
  endgenerate

  // Level 4 (distance = 8)
  generate
    for (i = 0; i < 64; i = i + 1) begin: L4
      if (i < 8) begin // Buffer
        assign G4[i] = G3[i];
        assign P4[i] = P3[i];
      end
      else if(i >= 8 && i < 16) begin // Gray Cells
        assign G4[i] = G3[i] | (P3[i] & G3[i-8]);
        assign P4[i] = P3[i];
      end else begin // Black Cell
        assign G4[i] = G3[i] | (P3[i] & G3[i-8]);
        assign P4[i] = P3[i] & P3[i-8];
      end
    end
  endgenerate
  
  // Level 5 (distance = 16)
  generate
    for (i = 0; i < 64; i = i + 1) begin: L5
      if (i < 16) begin // Buffer
        assign G5[i] = G4[i];
        assign P5[i] = P4[i];
      end else if(i >= 16 && i < 32) begin // Gray Cells
        assign G5[i] = G4[i] | (P4[i] & G4[i-16]);
        assign P5[i] = P4[i];
      end else begin // Black Cell
        assign G5[i] = G4[i] | (P4[i] & G4[i-16]);
        assign P5[i] = P4[i] & P4[i-16];
      end
    end
  endgenerate
  
  // Level 6 (distance = 32)
  generate
    for (i = 0; i < 64; i = i + 1) begin: L6
      if (i < 32) begin // Buffer
        assign G6[i] = G5[i];
        assign P6[i] = P5[i];
      end else begin // Gray Cells 
        assign G6[i] = G5[i] | (P5[i] & G5[i-32]);
        assign P6[i] = P5[i];
      end
    end
  endgenerate

  // Final Sum and Carry Calculation
  wire [64:0] C;
  assign C[0] = Cin;

  generate
    for(i = 0; i < 64; i = i + 1) begin: Carries
      assign C[i+1] = G6[i] | (P6[i] & Cin);
    end
  endgenerate

  assign Sum  = P0 ^ C[63:0];
  assign Cout = C[64];      
  
endmodule
