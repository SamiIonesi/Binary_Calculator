`timescale 1ns / 1ps

module FrequencyDivider
#(parameter SIZE = 32)
(Din, ConfigDiv, Reset, Clk, Enable, ClkOut);
    input [SIZE - 1:0] Din;
    input ConfigDiv;
    input Reset;
    input Clk;
    input Enable;
    output reg ClkOut;
    
    reg [SIZE -1:0] InternRegister = 1;
    reg [SIZE -1:0] Counter;
    
    task ResetValues();
        InternRegister <= 1;
        ClkOut <= 0;
        Counter <= 0;       
    endtask
    
    //this case is used when we want to divide with 1
    always @(posedge Clk, negedge Clk, posedge Reset, Enable) begin
        if(Reset) begin
            ResetValues();
        end
        else begin
            if(Enable) begin
                if(InternRegister == 1) begin
                    if(Clk)
                        ClkOut <= 1'b1;
                    else
                        ClkOut <= 1'b0;             
                end
            end
            else begin
                ClkOut <= 1'b0;
            end
        end
    end
    
    always @(posedge Clk, posedge Reset, Enable) begin
        Counter <= Counter + 1;
        if(Reset) begin
            ResetValues();
        end           
        else begin
            if(!Enable) begin
                ClkOut <= 0;
                if(ConfigDiv) begin
                    //store to intern register the value that we are given as Din
                    InternRegister <= Din;
                end
                else begin
                    //store to intern register the value that is already stored
                    InternRegister <= InternRegister;
                end
            end
            else begin
            //this case is used when we want to divide with more than 2
                if(InternRegister >= 2) begin
                    if(Counter % InternRegister < InternRegister/2)
                      ClkOut <= 1;
                    else          
                      ClkOut <= 0;
                end
            end
        end
    end
endmodule   
