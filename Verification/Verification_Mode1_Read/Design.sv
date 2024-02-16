`timescale 1ns / 1ps

module Full_Adder
(
    input A,
    input B,
    input Ci,
    output S,
    output C0   
);
    
    assign S = A ^ B ^ Ci;
    assign C0 = (A & B) | (Ci & (A ^ B));
    
endmodule

module Four_bit_adder
(
    input [3:0] A,
    input [3:0] B,
    input wire Cin,
    output wire[3:0] S,
    output wire Cout
);
    
    wire [2:0] Cin_Cout;
    
    Full_Adder FA0 (.A(A[0]), .B(B[0]), .Ci(Cin), .S(S[0]), .C0(Cin_Cout[0]));
    Full_Adder FA1 (.A(A[1]), .B(B[1]), .Ci(Cin_Cout[0]), .S(S[1]), .C0(Cin_Cout[1]));
    Full_Adder FA2 (.A(A[2]), .B(B[2]), .Ci(Cin_Cout[1]), .S(S[2]), .C0(Cin_Cout[2]));
    Full_Adder FA3 (.A(A[3]), .B(B[3]), .Ci(Cin_Cout[2]), .S(S[3]), .C0(Cout));
    
endmodule

module Eight_bit_adder #(parameter WIDTH = 8)(
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    input wire Cin,
    output wire[WIDTH - 1:0] S,
    output wire Cout
    );
    
    wire connection;
    
    Four_bit_adder FBA0 (.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(connection));
    Four_bit_adder FBA1 (.A(A[7:4]), .B(B[7:4]), .Cin(connection), .S(S[7:4]), .Cout(Cout));
endmodule


module ALU 
#(parameter SIZE_EIGHT = 8, parameter SIZE_FOUR = 4)
(A, B, Sel, Out, Flag);
    input [SIZE_EIGHT -1:0] A;
    input [SIZE_EIGHT -1:0] B;
    input [SIZE_FOUR -1:0] Sel;
    output reg [SIZE_EIGHT -1:0] Out;
    output reg [SIZE_FOUR -1:0] Flag;
    
    reg ZeroFlag;
    reg CarryFlag;
    reg OverflowFlag;
    reg UnderflowFlag;
    
    //assign Flag = {UnderflowFlag, OverflowFlag, CarryFlag, ZeroFlag};
    
    wire [SIZE_EIGHT -1:0] AdderOut;
    wire AdderCarry;
    reg [15:0] MultiplyTemp;
    
    task Zero();
        CarryFlag <= 1'b0;
        OverflowFlag <= 1'b0;
        UnderflowFlag <= 1'b0;
    endtask
    
    Eight_bit_adder EBA(.A(A), .B(B), .Cin(1'b0), .S(AdderOut), .Cout(AdderCarry));
    
  always @(*) begin
        case(Sel)
            //Adding 
            4'h0: begin
                if(AdderCarry) begin
                    CarryFlag <= AdderCarry;
                    Out <= AdderOut;
                  	UnderflowFlag <= 1'b0;
                  	OverflowFlag <= 1'b0;
                  	
                end
                else begin
                    CarryFlag <= 1'b0;
                  	UnderflowFlag <= 1'b0;
                  	OverflowFlag <= 1'b0;
                    Out <= AdderOut;
                end
            end
            
            //Substraction
            4'h1: begin
                //Zero();
                if(A < B) begin
                    UnderflowFlag <= 1'b1;
                 	Out <= ~(A - B) + 1; //2's compliment
                end
                else begin
                    UnderflowFlag <= 1'b0;
                    Out <= A - B;
                end
              CarryFlag <= 1'b0;
              OverflowFlag <= 1'b0;
            end
            
            //Multiplication
            4'h2: begin
                //Zero();
                MultiplyTemp = A * B;
                if(MultiplyTemp[15:8] == 8'h00) begin
                    OverflowFlag <= 1'b0;
                    Out <= MultiplyTemp[7:0];
                end
                else begin
                    OverflowFlag <= 1'b1;
                    Out <= MultiplyTemp[7:0];
                end 
              	CarryFlag <= 1'b0;
                UnderflowFlag <= 1'b0;
            end
            
            //Dividing
            4'h3: begin
                if(B != 8'h00)  begin
                    if(A < B) begin 
                        UnderflowFlag <= 1'b1;
                    end
                    else begin
                        UnderflowFlag <= 1'b0;
                    end
                    Out <= A / B;
                  	CarryFlag <= 1'b0;
                	OverflowFlag <= 1'b0;
                end
                else begin
                  	Flag <= 8'h1;
                    Out <= 8'h00;
                end
            end
            
            //Shift-Left
            4'h4: begin
                Zero();
                Out <= A << B;
            end
            
            //Shift-Right
            4'h5: begin
                Zero();              
                Out <= A >> B;
            end
            
            //AND
            4'h6: begin
                Zero();
                Out <= A & B;
            end
            
            //OR
            4'h7: begin
                Zero();
                Out <= A | B;

            end
            
            //XOR
            4'h8: begin
                Zero();
                Out <= A ^ B;
            end
            
            //NXOR
            4'h9: begin
                Zero();
                Out <= ~(A ^ B);
            end
            
            //NAND
            4'hA: begin
                Zero();
                Out <= ~(A & B);
            end
            //NOR
            4'hB: begin
                Zero();
                Out <= ~(A | B);
            end
            
            4'hC, 
            4'hD, 
            4'hE, 
            4'hF: begin 
                Out <= 8'h00;
                Flag <= 8'h00;
            end    
        endcase
        
        if(Out == 8'h00 && (Sel >= 4'h0 && Sel <= 4'hB)) begin
            ZeroFlag <= 1'b1;
        end
        else begin
            ZeroFlag <= 1'b0;
        end
      
      	Flag[0] = ZeroFlag;
  		Flag[1] = CarryFlag;
  		Flag[2] = OverflowFlag;
  		Flag[3] = UnderflowFlag;
    end
endmodule

module Mux_8b #(parameter LENGTH = 8)
(
input [LENGTH - 1:0] Din,
input Select,
output reg [LENGTH - 1:0] Dout
);

    always @(*) begin
        if(Select) begin
            Dout <= 8'h00;
        end
        else begin
            Dout <= Din;
        end
    end
endmodule

module Mux_4b #(parameter LENGTH = 4)
(
input [LENGTH - 1:0] Din,
input Select,
output reg [LENGTH - 1:0] Dout
);

    assign Dout = (Select == 1'b0) ? Din : 4'h0;
    
endmodule

module Mux_32b #(parameter LENGTH = 32)
(
input wire [LENGTH - 1:0] Din_A, 
input wire [LENGTH - 1:0] Din_B,
input wire Select,
output reg [LENGTH - 1:0] Dout
);

    assign Dout = Select ? Din_B : Din_A;
    
endmodule

module Concatenator
(InA, InB, InC, InD, InE, Out);
    input [7:0] InA, InB, InC;
    input [3:0] InD, InE;
    output reg [31:0] Out;
    
    assign Out = {InE, InD, InC, InB, InA};
    
endmodule

module Memory 
  #(parameter WIDTH = 8, parameter DinLENGTH = 32, parameter MemorySIZE = 2 ** WIDTH)
(Din, Addr, R_W, Valid, Reset, Clk, Dout);
    input Reset, Clk, R_W, Valid;
    input [WIDTH - 1:0] Addr;
    input [DinLENGTH - 1:0] Din;
    output reg [DinLENGTH - 1:0] Dout;
    
  reg [DinLENGTH - 1:0] memory [0:MemorySIZE - 1];
  shortint counter;
    
    always @(posedge Clk or posedge Reset) begin
        if(Reset) begin
            counter = 0;
            while(counter < MemorySIZE) begin
                memory[counter] <= 32'h0;
                counter++;
            end
            Dout <= 32'h0;
        end 
        else begin
            if(Valid) begin
                if(R_W) begin
                    memory[Addr] <= Din;
                    Dout <= 32'h0;
                end
                else begin
                    Dout <= memory[Addr];
                end
            end
            else begin
                Dout <= 32'h0;
            end          
        end
    end
endmodule

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
    
  always @(posedge Clk or Present_state) begin
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
                    //$display("Waiting for trasfer to be done!");
                end   
            end
            
            WriteMemory: begin
                AccessMem <= 1'b1;
                RWMem <= 1'b1;
                SampleData <= 1'b0;
                TxData <= 1'b0;
                Busy <= 1'b1;
                
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

    wire ResetTmp, ActiveCalcTmp, RWTmp, CtrlModeTmp, TransferDataTmp;
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

