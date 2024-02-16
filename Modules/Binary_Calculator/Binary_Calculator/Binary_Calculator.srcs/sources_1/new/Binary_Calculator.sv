`timescale 1ns / 1ps

module Binary_Calculator
(
    input InputKey, 
    input ValidCmd,
    input RWMem,
    input [7:0] Addr,
    input [7:0] InA,
    input [7:0] InB,
    input [3:0] Sel,
    input ConfigDiv,
    input [31:0] Datain,
    input Reset,
    input Clk,
    output CalcActive,
    output CalcMode,
    output CalcBusy,
    output DOutValid,
    output DataOut,
    output ClkTx
);

    wire ResetTmp, ActiveCalcTmp, RWTmp, CtrlModeTmp;
    wire SampleDataTmp, TxDoneTmp, CtrlRWMemTmp, CtrlAccessMemTmp;
    wire [7:0] MuxInATmp; 
    wire [7:0] MuxInBTmp;
    wire [3:0] MuxSelTmp;
    wire [7:0] AluOutTmp;
    wire [3:0] AluFlagTmp;
    wire [31:0] ConcatOutTmp, TxDinTmp, MemoryOutTmp;
    
    assign ResetTmp = Reset & (~ActiveCalcTmp);
    assign RWTmp = RWMem & ActiveCalcTmp;
    assign CalcActive = ActiveCalcTmp;
    assign CalcMode = CtrlModeTmp;
    
    //initialize the Muxs
    Mux_8b M1(
        .Din(InA),
        .Select(ResetTmp),
        .Dout(MuxInATmp)
    );
    
    Mux_8b M2(
        .Din(InB),
        .Select(ResetTmp),
        .Dout(MuxInBTmp)
    );
    
    Mux_4b M3(
        .Din(Sel),
        .Select(ResetTmp),
        .Dout(MuxSelTmp)
    );
    
    Mux_32b M4(
        .Din_A(ConcatOutTmp),
        .Din_B(MemoryOutTmp),
        .Select(CtrlModeTmp),
        .Dout(TxDinTmp)
    );
    
    //initialize the ALU
    ALU ALU(
        .A(MuxInATmp),
        .B(MuxInBTmp),
        .Sel(MuxSelTmp),
        .Out(AluOutTmp),
        .Flag(AluFlagTmp)
    );
    
    //initialize the Concatenator
    Concatenator Concatenator(
        .InA(MuxInATmp),
        .InB(MuxInBTmp),
        .InC(AluOutTmp),
        .InD(MuxSelTmp),
        .InE(AluFlagTmp),
        .Out(ConcatOutTmp)
    );
    
    //initialize the Controller
    Controller Controller(
        .InputKey(InputKey),
        .Clk(Clk),
        .ValidCmd(ValidCmd),
        .Reset(Reset),
        .RW(RWTmp),
        .TransferDone(TxDoneTmp),
        .Active(ActiveCalcTmp),
        .Busy(CalcBusy),
        .RWMem(CtrlRWMemTmp),
        .AccessMem(CtrlAccessMemTmp),
        .Mode(CtrlModeTmp),
        .SampleData(SampleDataTmp),
        .TransferData(TransferDataTmp)
    );
    
    //initialize the Memory
    Memory Memory(
        .Din(ConcatOutTmp),
        .Addr(Addr),
        .R_W(CtrlRWMemTmp),
        .Valid(CtrlAccessMemTmp),
        .Reset(ResetTmp),
        .Clk(Clk),
        .Dout(MemoryOutTmp)
    );
    
    //initialize the FrequencyDivider
    FrequencyDivider FrequencyDivider(
        .Din(Datain),
        .ConfigDiv(ConfigDiv),
        .Reset(ResetTmp),
        .Clk(Clk),
        .Enable(ActiveCalcTmp),
        .ClkOut(ClkTx)
    );
    
    //initialize the SerialTranceiver
    SerialTranceiver SerialTranceiver(
        .DataIn(TxDinTmp),
        .Sample(SampleDataTmp),
        .StartTx(TransferDataTmp),
        .TxDone(TxDoneTmp),
        .Reset(ResetTmp),
        .Clk(Clk),
        .ClkTx(ClkTx),
        .TxBusy(DOutValid),
        .Dout(DataOut)
    );
    
endmodule

module tb_Binary_Calculator();
    reg InputKey; 
    reg ValidCmd;
    reg RWMem;
    reg [7:0] Addr;
    reg [7:0] InA;
    reg [7:0] InB;
    reg [3:0] Sel;
    reg ConfigDiv;
    reg [31:0] Datain;
    reg Reset;
    reg Clk;
    wire CalcActive;
    wire CalcMode;
    wire CalcBusy;
    wire DOutValid;
    wire DataOut;
    wire ClkTx ;   
    
    Binary_Calculator DUT(
        .InputKey(InputKey), 
        .ValidCmd(ValidCmd),
        .RWMem(RWMem),
        .Addr(Addr),
        .InA(InA),
        .InB(InB),
        .Sel(Sel),
        .ConfigDiv(ConfigDiv),
        .Datain(Datain),
        .Reset(Reset),
        .Clk(Clk),
        .CalcActive(CalcActive),
        .CalcMode(CalcMode),
        .CalcBusy(CalcBusy),
        .DOutValid(DOutValid),
        .DataOut(DataOut),
        .ClkTx(ClkTx)
    );
    
    initial begin
        Clk = 1'b0;
    end
    
    always #5 Clk = ~Clk;
    
    initial begin
    
        //case 0: Reset the DUT
        #10 Reset =1'b1;
        #22 Reset = 1'b0;
        
        //case 1: Let's put an Invalid Key and then a Valid Key
        #10 ValidCmd = 1'b1;
        //InvalidKey
        #10 InputKey = 1'b1;
        #10 ValidCmd = 1'b0;
        #10 InputKey = 1'b0;
        #10 ValidCmd = 1'b1;
        #10 InputKey = 1'b1;
        
        //now we do Reset to exit for Error state and to introduce the correct Key
        #10 Reset = 1'b1; ValidCmd = 1'b0;
        #12 Reset = 1'b0;
        //ValidKey and also we divide the frequency with 2
        #10 ConfigDiv = 1'b1; Datain = 32'h2;
        #10 InputKey = 1'b1; ValidCmd = 1'b1; ConfigDiv = 1'b0;
        #10 InputKey = 1'b0;
        #10 InputKey = 1'b1;
        #10 InputKey = 1'b0;
        #10 InputKey = 1'b1;
        #20 ValidCmd = 1'b0;
        
        //case 2: write some operation in memory
        //write add:
        #10; Addr = 8'h01; Sel = 4'h0; InA = 8'h11; InB = 8'h0A;
        #10; RWMem = 1'b1; ValidCmd = 1'b1;
        //#10; Addr = 8'h01; Sel = 4'h0; InA = 8'h11; InB = 8'h0A;
        
        //write substraction
        #20; Addr = 8'h02; Sel = 4'h1; InA = 8'h49; InB = 8'h12;
        //write mult
        #20; Addr = 8'h03; Sel = 4'h2; InA = 8'hF3; InB = 8'h02;
        //write divide
        #20; Addr = 8'h04; Sel = 4'h3; InA = 8'h56; InB = 8'h08;
        //shift-left
        #20; Addr = 8'h05; Sel = 4'h4; InA = 8'hAA; InB = 8'h02;
        //OR
        #20; Addr = 8'h06; Sel = 4'h7; InA = 8'hF3; InB = 8'h1B;
        //NXOR
        #20; Addr = 8'h12; Sel = 4'h9; InA = 8'h33; InB = 8'hAA;
        
        //case 3: Reset when we write in memory
        #40 Reset = 1'b1; ValidCmd = 1'b0;;
        #20 Reset = 1'b0;
        
        //case 4: Try to read from memory after reset
            //set ClkTx divided by 3
        #10 ConfigDiv = 1'b1; Datain = 32'h3;
            //read from address 1
        #10; Addr = 8'h01; Sel = 4'h0; InA = 8'h00; InB = 8'h00;
            //put the correct key
        #10 InputKey = 1'b1; ValidCmd = 1'b1; ConfigDiv = 1'b0;
        #10 InputKey = 1'b0;
        #10 InputKey = 1'b1;
        #10 InputKey = 1'b0;
        #10 InputKey = 1'b1; RWMem = 1'b0; 
        #20 ValidCmd = 1'b1;
            
        //case 5: try to set the ClkTx divided by 5
            #500 ConfigDiv = 1'b1; Datain = 32'h5;
            #20 ConfigDiv = 1'b0;
            
            
        //case 6:cross from Mode 1 Read to Mode 1 Write
            #50 RWMem = 1'b1;
        //case 7: Write a valid data from a address
            //write some data in memory
        //write substraction
        #460 Addr = 8'h02; Sel = 4'h1; InA = 8'h49; InB = 8'h12;
        //write mult
        #20; Addr = 8'h03; Sel = 4'h2; InA = 8'hF3; InB = 8'h02;
        //write divide
        #20; Addr = 8'h04; Sel = 4'h3; InA = 8'h56; InB = 8'h08;
        //shift-left
        #20; Addr = 8'h05; Sel = 4'h4; InA = 8'hAA; InB = 8'h02;
            //then we read from memory a valid data
        #30 RWMem = 1'b0; Addr = 8'h03;
            
        //case 8: cross between Mode 1 and Mode 0.
        #600 InputKey = 1'b0;
        //NAND operation
        #300; Addr = 8'hAA; Sel = 4'hA; InA = 8'h3C; InB = 8'h91;
           
        //case 9: when the mode 0 is active, and a reset is activated for 3 clock cycles.
        #350 Reset = 1'b1;
        #30 Reset = 1'b0;
    end
    
endmodule

