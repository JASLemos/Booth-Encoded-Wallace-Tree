module CSA (
    input  signed [63:0] A, B, C,
    output signed [63:0] Sum, Carry
);  

    // 3 to 2 compressor

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : CSA_LOOP
            assign Sum[i] = A[i] ^ B[i] ^ C[i];
            assign Carry[i] = ((A[i] ^ B[i]) & C[i]) | (!(A[i] ^ B[i]) & A[i]);
        end
    endgenerate

endmodule