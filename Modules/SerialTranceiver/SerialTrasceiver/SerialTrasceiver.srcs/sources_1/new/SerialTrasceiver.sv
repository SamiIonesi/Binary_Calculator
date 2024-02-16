`timescale 1ns / 1ps

//functioneasa ca un PISO(Parallel Input Serial Output)
module SerialTrasceiver
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
                Dout <= 1'b0;
                Count_bits <= 0;
            end
            else begin
                TxDone <= 1'b0;
            end
        end
    end 
    
    always @(posedge ClkTx or posedge Reset) begin
        if(Reset) begin
            ResetValues();
        end
        else begin
          //in this case we will start to sent data to output, bit by bit
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
          end
        end
    end
endmodule

module tb_SerialTransciever();
    reg[31:0] DataIn;
    reg Sample;
    reg StartTx;
    reg Reset;
    reg Clk;
    reg ClkTx;
    wire TxDone;
    wire TxBusy;
    wire Dout;
    
    SerialTrasceiver dut
    (.DataIn(DataIn), 
     .Sample(Sample), 
     .StartTx(StartTx), 
     .Reset(Reset), 
     .Clk(Clk),
     .ClkTx(ClkTx),
     .TxDone(TxDone),
     .TxBusy(TxBusy),
     .Dout(Dout)
     );
     
     initial begin
        Sample <= 1'b0;
        StartTx <= 1'b0;
        Clk <= 1'b0;      
        ClkTx <= 1'b0;
     end
     
     always #5 Clk = ~Clk;
     always #15 ClkTx = ~ClkTx;
     
     
     initial begin
        //the first case is when we want to reset the values
        Reset = 1'b1;
        #8
        Reset = 1'b0;
        
        //other scenario is when we want to save the DataIn in the intern register
        #10;
        DataIn = 32'hFF_22_33_45;
        Sample = 1'b1;
        
        //after that we want to send the data to the serial output
        #20;
        Sample = 1'b0;
        StartTx = 1'b1;
        
        #50;
        StartTx = 1'b0;
        
        //let's try the case when TxBusy = 1 and we set Sample = 1
        #20;
        DataIn = 32'h21_11;
        Sample = 1'b1;
        #10; 
        Sample = 1'b0;  
  		//we want to test the case when we want to Reset the values when a transfer is in proces
  		#500;
  		Reset = 1'b1;
  		#13;
  		Reset = 1'b0;
       
        //now we want to make a whole trasnfer to be proceded
       DataIn = 32'hF2_59_FD_1B;
       #10;
       Sample = 1'b1;
       #12;
       Sample = 1'b0;
       #5;
       StartTx = 1'b1;
       #10;
       StartTx = 1'b0;
       #2000;
       
     end
  
    initial begin
        $dumpfile("dump.vcd");
      	$dumpvars;
        #4000;
        $finish();
    end
endmodule
