`timescale 1ns / 1ps

module Mux_32b #(parameter LENGTH = 32)
(
input wire [LENGTH - 1:0] Din_A, 
input wire [LENGTH - 1:0] Din_B,
input wire Select,
output reg [LENGTH - 1:0] Dout
);

    assign Dout = Select ? Din_B : Din_A;
    
endmodule