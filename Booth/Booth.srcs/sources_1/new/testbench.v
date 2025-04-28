`timescale 1ns / 1ps
module testbench();

    reg [31:0] x,y;
    wire [63:0] p;

    Booth DUT(
        .x(x),
        .y(y),
        .p(p)
        );
        
    initial begin
        x = 0;
        y = 0;
        
        #10;
        x = 243;
        y = 243;
        
        #10;
        x = -243;
        y = -243;
        
        #10;
        x = 243;
        y = -243;
        #30;
        $finish;
    
    end

endmodule
