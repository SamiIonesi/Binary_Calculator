`timescale 1ns / 1ps

//functioneasa ca un PISO(Parallel Input Serial Output)
module SerialTranceiver
#(parameter SIZE = 32)
(DataIn, Sample, StartTx, TxDone, Reset, Clk, ClkTx, TxBusy, Dout);
    input [SIZE - 1:0] DataIn;
    input Sample;
    input StartTx;
    input Reset;
    input Clk;
    input ClkTx;
    output reg TxDone;
    output reg TxBusy;
    output reg Dout;
    
    reg [SIZE -1: 0] InternRegister;
    reg [SIZE -1: 0] Count_bits;
    reg TxBusyIntern;
    
    task ResetValues();
        TxBusy <= 1'b0;
        TxBusyIntern <= 1'b0;
        InternRegister <= 32'h0;
        Count_bits <= 32'h0;
        Dout <= 1'b0;
        TxDone <= 1'b0;
    endtask
    
    always @(posedge Clk or posedge Reset) begin
        if(Reset) begin
            ResetValues();
        end
        else begin
            //in this case we are saving the DataIn inside the intern register
            if(Sample && !StartTx) begin
                if(!TxBusyIntern) begin
                    InternRegister <= DataIn;
                end
                 else begin
                     InternRegister <= InternRegister;
                 end
            end
            //in this case we will start to sent data to output, bit by bit
            else if(!Sample && StartTx) begin
                if(!TxDone) begin
                    TxBusyIntern <= 1;
                end
                else begin
                    TxBusyIntern <= 0;
                end
            end
            else if(Sample && StartTx) begin
                $display("This case is not possible");
            end
            
            if(Count_bits == (SIZE + 1)) begin
                TxDone <= 1'b1;
                TxBusyIntern <= 1'b0;
                TxBusy <= 1'b0;
                Dout <= 1'b0;
                Count_bits <= 0;
            end
            else begin
                TxDone <= 1'b0;
            end
        end
    end 
    
    always @(posedge ClkTx, posedge Reset) begin
        if(Reset) begin
            ResetValues();
        end
        else begin
        	if (Count_bits <= SIZE) begin
                if(TxBusyIntern) begin
                    TxBusy <= 1'b1;
                    Dout <= InternRegister[SIZE -1];
                    InternRegister <= InternRegister << 1;
                    Count_bits++;
                end
        	end
      
        if(Count_bits == (SIZE + 1)) begin
         	TxBusy <= 1'b0;
            TxBusyIntern <= 1'b0;
           
        end
      
        end
    
    end
endmodule