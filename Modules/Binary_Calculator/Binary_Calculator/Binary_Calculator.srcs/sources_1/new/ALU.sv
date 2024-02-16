`timescale 1ns / 1ps

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
    
    assign Flag = {UnderflowFlag, OverflowFlag, CarryFlag, ZeroFlag};
    
    reg [SIZE_EIGHT -1:0] AdderOut;
    reg AdderCarry;
    reg [15:0] MultiplyTemp;
    
    task Zero();
        ZeroFlag = 1'b0;
        CarryFlag = 1'b0;
        OverflowFlag = 1'b0;
        UnderflowFlag = 1'b0;
    endtask
    
    Eight_bit_adder EBA(.A(A), .B(B), .Cin(1'b0), .S(AdderOut), .Cout(AdderCarry));
    
    always @(*) begin
        case(Sel)
            //Adding 
            4'h0: begin
                Zero();
                if(AdderCarry) begin
                    CarryFlag <= AdderCarry;
                    Out <= AdderOut;
                end
                else begin
                    CarryFlag <= 1'b0;
                    Out <= AdderOut;
                end
            end
            
            //Substraction
            4'h1: begin
                Zero();
                if(A < B) begin
                    UnderflowFlag <= 1'b1;
                    Out <= ~(A - B) + 1;
                end
                else begin
                    UnderflowFlag <= 1'b0;
                    Out <= A - B;
                end        
            end
            
            //Multiplication
            4'h2: begin
                Zero();
                MultiplyTemp = A * B;
                if(MultiplyTemp[15:8] == 8'h00) begin
                    OverflowFlag <= 1'b0;
                    Out <= MultiplyTemp[7:0];
                end
                else begin
                    OverflowFlag <= 1'b1;
                    Out <= MultiplyTemp[7:0];
                end                 
            end
            
            //Dividing
            4'h3: begin
                Zero();
                if(B != 8'h00)  begin
                    if(A < B) begin 
                        UnderflowFlag <= 1'b1;
                    end
                    else begin
                        UnderflowFlag <= 1'b0;
                    end
                    Out <= A / B;  
                end
                else begin
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
    end
endmodule



/*
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
    
//     task Zero();
//         ZeroFlag <= 1'b0;
//         CarryFlag <= 1'b0;
//         OverflowFlag <= 1'b0;
//         UnderflowFlag <= 1'b0;
//     endtask
    
    Eight_bit_adder EBA(.A(A), .B(B), .Cin(1'b0), .S(AdderOut), .Cout(AdderCarry));
    
  always @(*) begin
        case(Sel)
            //Adding 
            4'h0: begin
                //Zero();
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
                    Out <= ~(A - B) + 1;
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
                //Zero();
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
                //Zero();
                Out <= A << B;
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
            end
            
            //Shift-Right
            4'h5: begin
                //Zero();            
                Out <= A >> B;
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
            end
            
            //AND
            4'h6: begin
                //Zero();
                Out <= A & B;
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
            end
            
            //OR
            4'h7: begin
                //Zero();
                Out <= A | B;
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
            end
            
            //XOR
            4'h8: begin
                //Zero();
                Out <= A ^ B;
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
            end
            
            //NXOR
            4'h9: begin
                //Zero();
                Out <= ~(A ^ B);
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
            end
            
            //NAND
            4'hA: begin
                //Zero();
                Out <= ~(A & B);
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
            end
            //NOR
            4'hB: begin
                //Zero();
                Out <= ~(A | B);
              	CarryFlag <= 1'b0;
         		OverflowFlag <= 1'b0;
         		UnderflowFlag <= 1'b0;
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
*/