`timescale 1ns / 1ps

module Memory 
  #(parameter WIDTH = 8, parameter DinLENGTH = 32, parameter MemorySIZE = 2 ** WIDTH)
(Din, Addr, R_W, Valid, Reset, Clk, Dout);
    input Reset, Clk, R_W, Valid;
    input [WIDTH - 1:0] Addr;
    input [DinLENGTH - 1:0] Din;
    output reg [DinLENGTH - 1:0] Dout;
    
  reg [DinLENGTH - 1:0] memory [0:MemorySIZE - 1];
    shortint counter;
    
    always @(posedge Clk or posedge Reset) begin
        if(Reset) begin
            counter = 0;
            while(counter < MemorySIZE) begin
                memory[counter] <= 32'h0;
                counter++;
            end
            Dout <= 32'h0;
        end 
        else begin
            if(Valid) begin
                if(R_W) begin
                    memory[Addr] <= Din;
                    Dout <= 32'h0;
                end
                else begin
                    Dout <= memory[Addr];
                end
            end
            else begin
                Dout <= 32'h0;
            end          
        end
    end
endmodule


module tb_memory #(parameter WIDTH = 8, parameter DinLENGTH = 32, MemorySIZE = 256)();
    reg Reset, Clk, R_W, Valid;
    reg [WIDTH - 1:0] Addr;
    reg [DinLENGTH - 1:0] Din;
    wire [DinLENGTH - 1:0] Dout;
    event done;
    
    Memory dut(.Reset(Reset), .Clk(Clk), .R_W(R_W), .Valid(Valid), .Addr(Addr), .Din(Din), .Dout(Dout));
    
    initial begin
        Clk <= 0;
        Reset <= 0;
        Addr <= -1;
        Din <= 32'h0000000F;
    end
    
    always #5 Clk = ~Clk;
    always #10 Addr = Addr + 1;
    
    initial begin
        forever begin
            #10; 
            Din = Din + 1;
        end
    end
    
    initial begin
        //facem scrierea in memorie pentru 20 de valori
        Valid = 1'b1;
        repeat(20) #10 R_W = 1'b1;
        //facem suprascriere pentru 2 valori incepand cu h11
        repeat(2) begin 
        #10;
        Addr = 8'h10 + 1;
        Din = 32'h00001111;
        end
        //facem o serie de citiri din memorie
        #10;
        R_W = 1'b0;
        Addr = 8'h01;
        #10;
        Addr = 8'h0A;
        #10;
        Addr = 8'h11;
        #10;
        Addr = 8'h13;
        //dupa care facem o resetare a memoriei
        #5;
        Reset = 1'b1;
        //si citim din memorie dupa resetare sa vedem daca s-a facut
        #10;
        R_W = 1'b0;
        Addr = 8'h01;
        #10;
        R_W = 1'b0;
        Addr = 8'h11;          
        #40;
        ->done;
    end
    
    
//    initial begin
//        #5 R_W = 1'b1; Valid = 1'b1;
//        #10 R_W = 1'b0; Valid = 1'b0;
//        #10 R_W = 1'b1; Valid = 1'b1;
//        #10 R_W = 1'b0; Valid = 1'b0;
//        #10 R_W = 1'b1; Valid = 1'b1;
//        #10 R_W = 1'b0; Valid = 1'b0;
//        #10 R_W = 1'b1; Valid = 1'b1;
//        #10 R_W = 1'b0; Valid = 1'b0;
//        #10 R_W = 1'b1; Valid = 1'b1;
//        #10 R_W = 1'b0; Valid = 1'b0;
//        #10 R_W = 1'b1; Valid = 1'b1;
//        #10 R_W = 1'b0; Valid = 1'b0;        
//    end
    initial begin
        wait(done.triggered);
        $finish();
    end

endmodule
