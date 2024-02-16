`timescale 1ns / 1ps

module Mux_4b #(parameter LENGTH = 4)
(
input [LENGTH - 1:0] Din,
input Select,
output reg [LENGTH - 1:0] Dout
);

    assign Dout = (Select == 1'b0) ? Din : 4'h0;
    
endmodule
