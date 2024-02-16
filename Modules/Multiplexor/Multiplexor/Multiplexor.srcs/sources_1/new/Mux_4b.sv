`timescale 1ns / 1ps

//this multiplexor will be use for ALU's select
module Mux_4b #(parameter LENGTH = 4)
(
input [LENGTH - 1:0] Din,
input Select,
output reg [LENGTH - 1:0] Dout
);

    assign Dout = (Select == 1'b0) ? Din : 4'h0;
    
endmodule

module tb_mux_4b();
    reg [3:0] Din = 4'h0;
    reg Select = 1'b0;
    wire [3:0] Dout;
    shortint counter = 0;
    event done;
    
    Mux_4b dut(.Din(Din), .Select(Select), .Dout(Dout));
    
    initial begin
        while(counter < 10) begin
            Din <= $urandom_range(0,3);
            Select <= $urandom_range(0,1);
            counter++;
            #10;
        end
        ->done;
    end    
    initial begin
        wait(done.triggered);
        $finish();    
    end
endmodule