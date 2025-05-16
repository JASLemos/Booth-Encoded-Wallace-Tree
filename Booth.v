module Booth #(
    parameter WIDTH = 32,
    parameter N = WIDTH / 2 // For radix-4, N = WIDTH / 2
  )(
    input  [WIDTH-1:0] x,
    input  [WIDTH-1:0] y,
    output [2*WIDTH-1:0] p
  );

  reg [2:0] cc [0:N-1]; // Control codes (radix-4 recoding)
  reg signed [WIDTH:0] pp [0:N-1]; // Partial products (+ sign bit)
  reg signed [2*WIDTH-1:0] spp [0:N-1]; // Shifted partial products
  reg signed [2*WIDTH-1:0] prod; // Final product
  reg signed [WIDTH:0] inv_x; // -x (2's complement with sign extension)

  integer kk, ii;

  always @(*)
  begin
    // Two's complement of x with sign extension
    inv_x = {~x[WIDTH-1], ~x} + 1;

    // Generate control codes for radix-4 Booth encoding
    cc[0] = {y[1], y[0], 1'b0};
    for (kk = 1; kk < N; kk = kk + 1)
    begin
      cc[kk] = {y[2*kk + 1], y[2*kk], y[2*kk - 1]};
    end

    // Generate partial products based on Booth encoding
    for (kk = 0; kk < N; kk = kk + 1)
    begin
      case (cc[kk])
        3'b000, 3'b111:
          pp[kk] = 0;
        3'b001, 3'b010:
          pp[kk] = {x[WIDTH-1], x};         // +x
        3'b011:
          pp[kk] = {x, 1'b0};               // +2x
        3'b100:
          pp[kk] = {inv_x[WIDTH-1:0], 1'b0};// -2x
        3'b101, 3'b110:
          pp[kk] = inv_x;                   // -x
        default:
          pp[kk] = 0;
      endcase

      // Sign-extend and shift left by 2 * kk
      spp[kk] = $signed(pp[kk]) <<< (2 * kk);
    end
  end

  // Level 1, 5 to 3 compression
  wire [63:0] S0, C0, S1, C1, S2, C2, S3, C3, S4, C4;

  CSA csa1(.A(spp[0]), .B(spp[1]), .C(spp[2]), .Sum(S0), .Carry(C0));
  CSA csa2(.A(spp[3]), .B(spp[4]), .C(spp[5]), .Sum(S1), .Carry(C1));
  CSA csa3(.A(spp[6]), .B(spp[7]), .C(spp[8]), .Sum(S2), .Carry(C2));
  CSA csa4(.A(spp[9]), .B(spp[10]), .C(spp[11]), .Sum(S3), .Carry(C3));
  CSA csa5(.A(spp[12]), .B(spp[13]), .C(spp[14]), .Sum(S4), .Carry(C4));

  // Level 2, 3 to 2 compression
  wire [63:0] S5, C5, S6, C6, S7, C7;

  CSA csa6(.A(S0), .B({C0[62:0],1'b0}), .C(S1), .Sum(S5), .Carry(C5));
  CSA csa7(.A({C1[62:0],1'b0}), .B(S2), .C({C2[62:0],1'b0}), .Sum(S6), .Carry(C6));
  CSA csa8(.A(S3), .B({C3[62:0],1'b0}), .C(S4), .Sum(S7), .Carry(C7));

  // Level 3, 2 to 2 compression
  wire [63:0] S8, C8, S9, C9;

  CSA csa9(.A(S5), .B({C5[62:0],1'b0}), .C(S6), .Sum(S8), .Carry(C8));
  CSA csa10(.A({C6[62:0],1'b0}), .B(S7), .C({C7[62:0],1'b0}), .Sum(S9), .Carry(C9));

  // Level 4
  wire [63:0] S10, C10, S11, C11;

  CSA csa11(.A(S8), .B({C8[62:0],1'b0}), .C(S9), .Sum(S10), .Carry(C10));
  CSA csa12(.A({C9[62:0],1'b0}), .B({C4[62:0],1'b0}), .C(spp[15]), .Sum(S11), .Carry(C11));

  // Level 5
  wire [63:0] S12, C12;

  CSA csa13(.A(S10), .B({C10[62:0],1'b0}), .C(S11), .Sum(S12), .Carry(C12));

  // Level 6
  wire [63:0] S13, C13;
  CSA csa14(.A(S12), .B({C12[62:0],1'b0}), .C({C11[62:0],1'b0}), .Sum(S13), .Carry(C13));

  // Final adder
  Knowles CPA(.A(S13), .B({C13[62:0],1'b0}), .Cin(1'b0), .Sum(p));
  //KSA KoggeStone(.A(S13), .B({C13[62:0],1'b0}), .Cin(1'b0), .Sum(p));
  //CLA #(.WIDTH(64)) CPA(.A(S13), .B({C13[62:0],1'b0}), .Cin(1'b0), .S(p));

endmodule
