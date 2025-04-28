module KSA #(parameter N = 32) (
    input [N-1:0] A, B,
    output [N-1:0] Sum
);
    
    // Pre-processing stage
    wire [N-1:0] P, G;
    assign P = A ^ B;
    assign G = A & B;

    // Generate propagate and generate signals
    wire [N-1:0] G_stage [0:$clog2(N)];
    wire [N-1:0] P_stage [0:$clog2(N)];

    assign G_stage[0] = G;
    assign P_stage[0] = P;

    genvar i, j;
    generate
        for (i = 1; i <= $clog2(N); i = i + 1) begin : stage
            for (j = 0; j < N; j = j + 1) begin : bit
                if (j >= (1 << (i - 1))) begin
                    assign G_stage[i][j] = G_stage[i-1][j] | (P_stage[i-1][j] & G_stage[i-1][j - (1 << (i - 1))]);
                    assign P_stage[i][j] = P_stage[i-1][j] & P_stage[i-1][j - (1 << (i - 1))];
                end else begin
                    assign G_stage[i][j] = G_stage[i-1][j];
                    assign P_stage[i][j] = P_stage[i-1][j];
                end
            end
        end
    endgenerate

    // Carries
    wire [N-1:0] C;
    assign C[0] = G[0];
    generate
        for (i = 1; i < N; i = i + 1) begin : carry
            assign C[i] = G_stage[$clog2(N)][i];
        end
    endgenerate

    // Assigning outputs
    assign Sum = P ^ {C[N-2:0], 1'b0};

endmodule