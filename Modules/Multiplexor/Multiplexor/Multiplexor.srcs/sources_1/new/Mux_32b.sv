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

module tb_mux_32b #(parameter SIZE = 32);
    reg [SIZE - 1:0] Din_A, Din_B;
    reg Select;
    wire [SIZE - 1:0] Dout;
    shortint counter = 0;
    event done;
    
    initial begin
        Din_A = 0;
        Din_B = 0;
        Select = 1'b0;
    end
    
    Mux_32b dut(.Din_A(Din_A), .Din_B(Din_B), .Select(Select), .Dout(Dout));
    
    initial begin
        while(counter < 10) begin
            Din_A = $urandom_range(0,1000);
            Din_B = $urandom_range(0,1000);
            Select = $urandom();
            $display("Din_A = %0d, Din_B = %0d, Sel = %0d", Din_A, Din_B, Select);
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