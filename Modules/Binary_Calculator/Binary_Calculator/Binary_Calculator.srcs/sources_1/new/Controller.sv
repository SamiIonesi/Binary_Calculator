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