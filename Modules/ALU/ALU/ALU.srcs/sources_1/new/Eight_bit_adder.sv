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

//module tb_eight_bit_adder();
//    logic [7:0] A;
//    logic [7:0] B;
//    logic Cin = 0;
//    reg [7:0] S;
//    logic Cout;
//    logic [8:0] final_sum;
//    shortint counter = 0;
    
//    Eight_bit_adder dut(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
    
//    assign final_sum = {Cout, S[7], S[6], S[5], S[4], S[3], S[2], S[1], S[0]};
    
//    initial begin
//        A = 0;
//        B = 0;
        
//        while(counter < 20) begin
//            #20
//            A = $urandom();
//            B = $urandom();
//            counter++;
//        end
//    end
    
//    initial begin
//        #400;
//        $finish();
//    end
    
//endmodule