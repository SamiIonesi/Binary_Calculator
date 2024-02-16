`timescale 1ns / 1ps

module Mux_8b #(parameter LENGTH = 8)
(
input [LENGTH - 1:0] Din,
input Select,
output reg [LENGTH - 1:0] Dout
);

    always @(*) begin
        if(Select) begin
            Dout <= 8'h00;
        end
        else begin
            Dout <= Din;
        end
    end
endmodule
