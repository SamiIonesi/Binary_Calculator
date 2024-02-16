`timescale 1ns / 1ps

module Eight_bit_adder #(parameter WIDTH = 8)(
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    input wire Cin,
    output wire[WIDTH - 1:0] S,
    output wire Cout
    );
    
    wire connection;
    
    Four_bit_adder FBA0 (.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(connection));
    Four_bit_adder FBA1 (.A(A[7:4]), .B(B[7:4]), .Cin(connection), .S(S[7:4]), .Cout(Cout));
endmodule