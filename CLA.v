module CLA
  #(parameter WIDTH = 32)
  (
    input [WIDTH-1:0] A, B,
    input Cin,
    output [WIDTH-1:0] S,
    output Cout
  );

  wire [WIDTH:0] Ci; // Carry intermediate for intermediate computation

  assign Ci[0] = Cin;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : carry_gen
      if (i == 0) begin
        assign Ci[i + 1] = (A[i] & B[i]) | ((A[i] ^ B[i]) & Ci[i]);
      end else begin
        assign Ci[i + 1] = (A[i] & B[i]) | ((A[i] ^ B[i]) & Ci[i]);
      end
    end
  endgenerate

  assign S = A ^ B ^ Ci[WIDTH-1:0];
  assign Cout = Ci[WIDTH];

endmodule
