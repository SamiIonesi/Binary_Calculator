`timescale 1ns / 1ps

module Control_RW_Flow(
    input ValidCmd,
    input RW,
    input Reset,
    input Clk,
    input TxDone,
    input Active,
    input Mode,
    output reg AccessMem,
    output reg RWMem,
    output reg SampleData, 
    output reg TxData,
    output reg Busy
);

    //declare the localparameters that is the states
    localparam IDLE = 3'h0;
    localparam ReadMemory = 3'h1;
    localparam SampleST = 3'h2;
    localparam StartTransferST = 3'h3;
    localparam WaitTransferDone = 3'h4;
    localparam WriteMemory = 3'h5;
    localparam Error = 3'bxxx;
    
    reg [2:0] Present_state;
    reg [2:0] Next_state;
    
    always @(*) begin
        case(Present_state)
            IDLE: begin
                AccessMem <= 1'b0;
                RWMem <= 1'b0;
                SampleData <= 1'b0;
                TxData <= 1'b0;
                Busy <= 1'b0;
                
                if(ValidCmd && Mode && Active && !RW) begin
                    Next_state <= ReadMemory;
                end
                else if(ValidCmd && Mode && Active && RW) begin
                    Next_state <= WriteMemory;
                end
                else if(ValidCmd && !Mode && Active)begin
                    Next_state <= SampleST;
                end
                else begin
                    Next_state <= IDLE;
                end
            end
            
            ReadMemory: begin
                AccessMem <= 1'b1;
                RWMem <= 1'b0;
                SampleData <= 1'b0;
                TxData <= 1'b0;
                Busy <= 1'b1;
                
                if(ValidCmd && Mode && Active && !RW) begin
                    Next_state <= SampleST;
                end              
            end
            
            SampleST: begin
                AccessMem <= 1'b0;
                RWMem <= 1'b0;
                SampleData <= 1'b1;
                TxData <= 1'b0;
                Busy <= 1'b1;
                
                if((Mode && Active && !TxDone) || (ValidCmd && Active && !Mode)) begin
                    Next_state <= StartTransferST;
                end          
           end
            
            StartTransferST: begin
                AccessMem <= 1'b0;
                RWMem <= 1'b0;
                SampleData <= 1'b0;
                TxData <= 1'b1;
                Busy <= 1'b1;
                
                if(Active && !TxDone && (Mode || !Mode)) begin
                    Next_state <= WaitTransferDone;
                end
            end
            
            WaitTransferDone: begin
                AccessMem <= 1'b0;
                RWMem <= 1'b0;
                SampleData <= 1'b0;
                TxData <= 1'b1;
                Busy <= 1'b1;
                
                if(TxDone) begin 
                    Next_state <= IDLE;
                end
                else begin 
                    $display("Waiting for trasfer to be done!");
                end   
            end
            
            WriteMemory: begin
                AccessMem <= 1'b1;
                RWMem <= 1'b1;
                SampleData <= 1'b0;
                TxData <= 1'b0;
                Busy <= 1'b1;
                //@(posedge Clk);
                Next_state <= IDLE;    
            end
            
            default: begin
                AccessMem <= 1'b0;
                RWMem <= 1'b0;
                SampleData <= 1'b0;
                TxData <= 1'b0;
                Busy <= 1'b0;
                
                Next_state <= Error;               
            end
        endcase
    end
    
    always @(posedge Clk or posedge Reset) begin
        if(Reset) begin 
            AccessMem <= 1'b0;
            RWMem <= 1'b0;
            SampleData <= 1'b0;
            TxData <= 1'b0;
            Busy <= 1'b0;
            Present_state <= IDLE;          
        end
        else begin
            Present_state <= Next_state;
        end
    end

endmodule