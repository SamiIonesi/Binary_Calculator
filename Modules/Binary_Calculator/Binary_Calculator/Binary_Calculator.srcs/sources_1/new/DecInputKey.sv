`timescale 1ns / 1ps

module DecInputKey
(InputKey, ValidCmd, Reset, Clk, Active, Mode);
    input InputKey;
    input ValidCmd;
    input Reset;
    input Clk;
    output reg Active;
    output reg Mode;
    
    
    //declare the localparameters that will be the states
    localparam S0 = 3'b000;
    localparam S1 = 3'b001;
    localparam S2 = 3'b010;
    localparam S3 = 3'b011;
    localparam S4 = 3'b100;
    localparam S5 = 3'b101;
    localparam Error = 3'bxxx;
    
    reg [2:0] Present_state;
    reg [2:0] Next_state;

    always @(InputKey or Present_state) begin
        case(Present_state)
                S0: begin
                    Active <= 1'b0;
                    Mode <= 1'b0;
                    if(InputKey == 1'b1) begin
                        Next_state <= S1;
                    end
                    else begin
                        Next_state <= Error;
                    end
                end
                
                S1: begin
                    Active <= 1'b0;
                    Mode <= 1'b0;
                    if(InputKey == 1'b0) begin
                        Next_state <= S2;
                    end
                    else begin
                        Next_state <= Error;
                    end
                end
                
                S2: begin
                    Active <= 1'b0;
                    Mode <= 1'b0;
                    if(InputKey == 1'b1) begin
                        Next_state <= S3;
                    end
                    else begin
                        Next_state <= Error;
                    end
                end
                
                S3: begin
                    Active <= 1'b0;
                    Mode <= 1'b0;
                    if(InputKey == 1'b0) begin
                        Next_state <= S4;
                    end
                    else begin
                        Next_state <= Error;
                    end
                end
                
                S4: begin
                    Active <= 1'b0;
                    Mode <= 1'b0;
                    Next_state <= S5;
                end
                
                S5: begin
                    Active <= 1'b1;
                    //Mode <= Mode;
                    Next_state <= S5;
                end
                
                Error: begin
                    Active <= 1'b0;
                    Mode <= 1'b0;
                    Next_state <= Error;
                end
                
                default: begin
                    Active <= 1'bx;
                    Mode <= 1'bx;
                    Next_state <= Error;
                end
            endcase
    end
    
    always @(posedge Clk or posedge Reset) begin
        if(Reset) begin
            Active <= 1'b0;
            Mode <= 1'b0;
            Present_state <= S0;
            //Next_state <= S0;
        end 
        else begin
            if(ValidCmd) begin
                Present_state = Next_state;
                if(Present_state == 5) begin
                    Mode = InputKey;
                end
            end
        end
    end 
endmodule