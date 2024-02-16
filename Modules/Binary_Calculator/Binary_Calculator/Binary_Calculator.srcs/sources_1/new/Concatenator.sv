`timescale 1ns / 1ps

module Concatenator
(InA, InB, InC, InD, InE, Out);
    input [7:0] InA, InB, InC;
    input [3:0] InD, InE;
    output reg [31:0] Out;
    
    assign Out = {InE, InD, InC, InB, InA};
    
endmodule