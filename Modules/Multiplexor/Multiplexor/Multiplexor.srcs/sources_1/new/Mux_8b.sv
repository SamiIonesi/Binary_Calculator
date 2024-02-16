`timescale 1ns / 1ps

//this multiplexor will represent the inputs for operator A and B
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

module tb_mux_8b();
    reg [7:0] Din = 8'h00;
    reg Select = 1'b0;
    wire [7:0] Dout;
    shortint counter = 0;
    event done;
    
    Mux_8b dut(.Din(Din), .Select(Select), .Dout(Dout));
    
    initial begin
        while(counter < 10) begin
            Din <= $urandom_range(0,7);
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
