`timescale 1ns / 1ps

module Full_Adder
(
    input A,
    input B,
    input Ci,
    output S,
    output C0   
);
    
    assign S = A ^ B ^ Ci;
    assign C0 = (A & B) | (Ci & (A ^ B));
    
endmodule

