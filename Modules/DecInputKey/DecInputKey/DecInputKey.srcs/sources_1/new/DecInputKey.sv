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
            //Next_state <= S1;
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


module tb_DecInputKey();
    reg InputKey;
    reg ValidCmd;
    reg Reset;
    reg Clk;
    wire Active;
    wire Mode;

    DecInputKey dut(
     .InputKey(InputKey), 
     .ValidCmd(ValidCmd), 
     .Reset(Reset), 
     .Clk(Clk), 
     .Active(Active), 
     .Mode(Mode)
     );
     
     initial begin
        InputKey = 1'b0;
        ValidCmd = 1'b0;
        Reset = 1'b0;
        Clk = 1'b0;
     end
     
     always #10 Clk = ~Clk;
     
     initial begin
        //first we want to do reset
        #5;
        Reset = 1'b1;
        #12;
        Reset = 1'b0;
        
        //then we want to activate the ValidCmd and to put the Key
        #20;
        @(negedge Clk);
        ValidCmd = 1'b1;
        InputKey = 1'b1;
        @(negedge Clk);
        InputKey = 1'b0;
        @(negedge Clk);
        InputKey = 1'b1;
        @(negedge Clk);
        InputKey = 1'b0;
        @(negedge Clk);
        InputKey = 1'b1;     
           
        #50;
        ValidCmd = 1'b0;
        
        #20;
        ValidCmd = 1'b1;
        InputKey = 1'b1;
        
        #20;
        InputKey = 1'b0;
        
        //now let's try to reset
        #50;
        ValidCmd = 1'b0;
        Reset = 1'b1;
        #3;
        Reset = 1'b0;
        ValidCmd = 1'b1;
        
        //now let's go into a state of error from which we can only get out by resetting
        #10;
        InputKey = 1'b1;
        #5;
        ValidCmd = 1'b0;
        #10;
        InputKey = 1'b0;
        #10;
        InputKey = 1'b1;
        ValidCmd = 1'b1;
        #10;
        InputKey = 1'b0;
        #10;
        ValidCmd = 1'b0;
        InputKey = 1'b1;
        #10;
        InputKey = 1'b0;
        #10;
        InputKey = 1'b1;
        ValidCmd = 1'b1;
        #10;
        InputKey = 1'b0;
        #10;
        InputKey = 1'b1;
        #10;
        InputKey = 1'b0;
        ValidCmd = 1'b0;        
        Reset = 1'b1;
        #5;
        Reset = 1'b0;
        
        //now let's try again to put the correct Key
        #15;
        ValidCmd = 1'b1;
        InputKey = 1'b1;
        #20;
        InputKey = 1'b0;
        #20;
        InputKey = 1'b1;
        #15;
        InputKey = 1'b0;
        #5;
        ValidCmd = 1'b0;
        #20;
        ValidCmd = 1'b1;
        #35;
        InputKey = 1'b1;
        #30;
        $finish();                  
     end

endmodule 
