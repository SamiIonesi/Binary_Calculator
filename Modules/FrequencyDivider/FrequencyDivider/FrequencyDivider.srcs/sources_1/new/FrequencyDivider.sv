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
    int Counter;
    
    task ResetValues();
        InternRegister <= 1;
        ClkOut <= 0;
        Counter <= 0;       
    endtask
    
    //this case is used when we want to divide with 1
    always @(posedge Clk or negedge Clk or posedge Reset or Enable) begin
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
    
    always @(posedge Clk or posedge Reset or Enable) begin
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
        Counter <= Counter + 1;
    end
endmodule   

module tb_FrequencyDivider();
    reg [31:0] Din;
    reg Clk, Reset, Enable, ConfigDiv;
    wire ClkOut;
    
    FrequencyDivider dut (
      .Din(Din),
      .Clk(Clk),
      .Reset(Reset),
      .Enable(Enable),
      .ConfigDiv(ConfigDiv),
      .ClkOut(ClkOut)
    );
    
    initial begin
        Clk <= 1'b0;
        Enable <= 1'b0;
        ConfigDiv <= 1'b0;
        Reset <= 1'b1;
    end
    
    always #5 Clk = ~Clk;
    
    initial begin
        #7;
        Reset = 1'b0;
        
//        //case when we store in intern register the initial Din value
//        #10;
//        ConfigDiv = 1'b1;
        
        //case when we want to keep the same Clk to output as the initial one
        #20;
        ConfigDiv = 1'b0;
        Enable = 1'b1;
        
        //case when we want to store spesicifc value in internal register
        //and the we plot the divided frequency to output
        #100;
        Enable = 1'b0;  
        #10;
        Din = 4;
        #10;
        ConfigDiv = 1'b1;
        #10;
        ConfigDiv = 1'b0;
        Enable = 1'b1;
        
        //case when we want to activate Reset and the plot the initial values
        #100;
        Reset = 1'b1;
        #10;
        Reset = 1'b0;
        Enable = 1'b1;
        #50; 
        Enable = 1'b0;
        
        //What is happening if both Enable and ConfigDiv ar activ?
        //Answer: is not store nothing in internal register, the output keep the value that was stored before
        #10;
        Din = 2;
        ConfigDiv = 1'b1;
        Enable = 1'b1;
        #30;
        Enable = 1'b0;
        #10;
        ConfigDiv = 1'b0;
        Enable = 1'b1;
        
        //let's divide with a odd number
        #50;
        Din = 5;
        ConfigDiv = 1'b1;
        Enable = 1'b0;
        #10;
        ConfigDiv = 1'b0;
        Enable = 1'b1;
        
        #150;
        Enable = 1'b0;
        #30;
        Din = 32'hA;
        #15;
        ConfigDiv = 1'b1;
        #25;
        ConfigDiv = 1'b0;
        
        
        #20;
        $finish();
    end
endmodule
