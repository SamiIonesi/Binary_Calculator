`timescale 1ns / 1ps

module Four_bit_adder
(
    input [3:0] A,
    input [3:0] B,
    input wire Cin,
    output wire[3:0] S,
    output wire Cout
);
    
    wire [2:0] Cin_Cout;
    
    Full_Adder FA0 (.A(A[0]), .B(B[0]), .Ci(Cin), .S(S[0]), .C0(Cin_Cout[0]));
    Full_Adder FA1 (.A(A[1]), .B(B[1]), .Ci(Cin_Cout[0]), .S(S[1]), .C0(Cin_Cout[1]));
    Full_Adder FA2 (.A(A[2]), .B(B[2]), .Ci(Cin_Cout[1]), .S(S[2]), .C0(Cin_Cout[2]));
    Full_Adder FA3 (.A(A[3]), .B(B[3]), .Ci(Cin_Cout[2]), .S(S[3]), .C0(Cout));
    
endmodule