`timescale 1ns / 1ps

module Controller
(
    input InputKey,
    input Clk,
    input ValidCmd,
    input Reset,
    input RW,
    input TransferDone,
    output Active,
    output Mode,
    output RWMem,
    output AccessMem,
    output Busy,
    output SampleData,
    output TransferData
);

    wire Active_wire;
    wire Mode_wire;
    
    DecInputKey DUT_DIK(
    .InputKey(InputKey),
    .ValidCmd(ValidCmd),
    .Reset(Reset),
    .Clk(Clk),
    .Active(Active_wire),
    .Mode(Mode_wire)
    );
    
    assign Active = Active_wire;
    assign Mode = Mode_wire;
    
    Control_RW_Flow DUT_CRWF(
    .ValidCmd(ValidCmd),
    .RW(RW),
    .Reset(Reset),
    .Clk(Clk),
    .TxDone(TransferDone),
    .Active(Active_wire),
    .Mode(Mode_wire),
    .AccessMem(AccessMem),
    .RWMem(RWMem),
    .SampleData(SampleData),
    .TxData(TransferData),
    .Busy(Busy)
    );
    
endmodule

module tb_Controller();
    reg InputKey;
    reg Clk;
    reg ValidCmd;
    reg Reset;
    reg RW;
    reg TransferDone;
    wire Active;
    wire Mode;
    wire RWMem;
    wire AccessMem;
    wire Busy;
    wire SampleData;
    wire TransferData;
    event done;
    
    Controller DUT(
    .InputKey(InputKey),
    .Clk(Clk),
    .ValidCmd(ValidCmd),
    .RW(RW),
    .Reset(Reset),
    .TransferDone(TransferDone),
    .Active(Active),
    .Mode(Mode),
    .RWMem(RWMem),
    .AccessMem(AccessMem),
    .Busy(Busy),
    .SampleData(SampleData),
    .TransferData(TransferData)
    );
    
    initial begin
        InputKey = 1'b0;
        Clk = 1'b0;
        ValidCmd = 1'b0;
        Reset = 1'b0;
        RW = 1'b0;
        TransferDone = 1'b0;    
    end

    always #5 Clk = ~Clk;
    
    initial begin
        //for the start let's do a reset
        Reset = 1'b1;
        #12; 
        Reset = 1'b0;
        
        //now let's intoroduce the correct key
        #10;
        ValidCmd = 1'b1;
        @(negedge Clk) InputKey = 1'b1;
        @(negedge Clk) InputKey = 1'b0;
        @(negedge Clk) InputKey = 1'b1;
        @(negedge Clk) InputKey = 1'b0;
        RW = 1'b1;
        @(negedge Clk) InputKey = 1'b1;
                
        //now let's Write some data in memory
        #30;
        ValidCmd = 1'b1;
        
        //now let's read from memory some data
        #20;
        RW = 1'b0;
        
        #100;
        TransferDone = 1'b1;
        InputKey = 1'b0;
        #20;
        TransferDone = 1'b0;
        
        //now let's send some data directly to SerialTransceiver
        
        #200;
        TransferDone = 1'b1;
        #10;
        TransferDone = 1'b0;
        #20;
        ->done;
    end
    
    initial begin
        wait(done.triggered);
        $finish();
    end
endmodule