`timescale 1ns / 1ps

module Concatenator
(InA, InB, InC, InD, InE, Out);
    input [7:0] InA, InB, InC;
    input [3:0] InD, InE;
    output reg [31:0] Out;
    
    assign Out = {InE, InD, InC, InB, InA};
endmodule

module tb_concatenator;
    reg [7:0] InA = 0, InB = 0, InC = 0;
    reg [3:0] InD = 0, InE = 0;
    wire [31:0] Out;
    shortint counter = 0;
    event done;
    
    Concatenator dut(
    .InA(InA), 
    .InB(InB), 
    .InC(InC), 
    .InD(InD), 
    .InE(InE), 
    .Out(Out)
    );
    
    initial begin 
        while(counter < 10) begin
            InA <= $urandom_range(0, 255);
            InB <= $urandom_range(0, 255); 
            InC <= $urandom_range(0, 255); 
            InD <= $urandom_range(0, 15); 
            InE <= $urandom_range(0, 15);
            counter++;
            #20;         
        end    
        -> done;
    end
    
    initial begin
        wait(done.triggered);
        $finish();
    end
endmodule