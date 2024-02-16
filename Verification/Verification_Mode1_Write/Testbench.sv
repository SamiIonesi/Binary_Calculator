//delcare the interface(work between classes and DUT)
interface Binary_Calculator_itf;
  //inputs
  logic InputKey; 
  logic ValidCmd;
  logic RWMem;
  logic ConfigDiv;
  logic Reset;
  logic Clk;
  logic [7:0] Addr;
  logic [7:0] InA;
  logic [7:0] InB;
  logic [3:0] Sel;
  logic [31:0] Datain;
  //outputs
  logic CalcActive;
  logic CalcMode;
  logic CalcBusy;
  logic DOutValid;
  logic DataOut;
  logic ClkTx;
endinterface

//this class will hold all the inputs and outputs of our DUT
class transaction;
  
  typedef enum bit[1:0] {Mode1_write = 2'b00 , Mode1_read = 2'b01, Mode0 = 2'b10} oper_type;
  
  randc oper_type oper;
  
  rand logic [7:0] InA;
  rand logic [7:0] InB;
  rand logic [7:0] Addr;
  rand logic [3:0] Sel;
  logic [31:0] Datain = 3;
  
  logic InputKey, ValidCmd, RWMem, ConfigDiv, Reset;
  
  logic DOutValid, DataOut, ClkTx, CalcActive, CalcMode, CalcBusy;
  
  //make a constraint for Frequency Divider
  constraint FrequencyDiv {
    Datain inside {[0:5]};
  }
  
  //make a constraint for Sel
  constraint CorrectSel {
    Sel inside {[0:12]};
  }
  
  function void display_test(input string tag);
    $display("[%0t]:[%s] -> Operation: %0d", $time(), tag, oper);
  endfunction
  
  //display the inputs
  function void display_inputs(input string tag);
    $display("[%s] -> InA: %0h, InB: %0h, Sel: %0h, Addr: %0h, Datain: %0h.", tag, InA, InB, Sel, Addr, Datain);
  endfunction
  
  
  //display the outputs
  function void display_outputs(input string tag);
    $display("[%0t]:[%s] -> DOutValid: %0b, DataOut: %0b, ClkTx: %0b, CalcActive: %0b, CalcMode: %0b, CalcBusy: %0b", $time(), tag, DOutValid, DataOut, ClkTx, CalcActive, CalcMode, CalcBusy);
  endfunction
  
  //make a custom constructor to do a deep copy of datamembers from our class
  function transaction copy();
    copy = new();
    copy.oper = this.oper;
    copy.InA = this.InA;
    copy.InB = this.InB;
    copy.Addr = this.Addr;
    copy.Sel = this.Sel;
    copy.Datain = this.Datain;
    copy.InputKey = this.InputKey;
    copy.ValidCmd = this.ValidCmd;
    copy.RWMem = this.RWMem;
    copy.ConfigDiv = this.ConfigDiv;
    copy.Reset = this.Reset;
    copy.DOutValid = this.DOutValid;
    copy.DataOut = this.DataOut;
    copy.ClkTx = this.ClkTx;
    copy.CalcActive = this.CalcActive;
    copy.CalcMode = this.CalcMode;
    copy.CalcBusy = this.CalcBusy;
  endfunction
  
endclass


class generator;
  transaction trans;
  mailbox #(transaction) mbx; 
  event done;
  event next_drv;
  event next_sco;
  int counter = 0;
  
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx; 
    trans = new();
  endfunction
  
  task main();
    
    repeat(counter) begin
      assert(trans.randomize()) else $display("Randomize failed.");
      $display("---------------------------------");
      trans.display_inputs("GEN");
      mbx.put(trans.copy);
      @(next_drv);
      @(next_sco);
    end
    ->done;
  endtask
endclass



class driver;
  virtual Binary_Calculator_itf BC_itf;
  mailbox #(transaction) mbx;
  transaction data;
  event next_drv;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    data = new();
  endfunction
  
  function void display_in();
    $display("[%0t]:[DRV] -> InA: %0h, InB: %0h, Sel: %0h, Addr: %0h, Datain: %0h, InputKey: %0b, ValidCmd: %0b, RWMem->: %0b, ConfigDiv: %0b, Reset: %0b ", $time(), data.InA, data.InB, data.Sel, data.Addr, data.Datain, data.InputKey, data.ValidCmd, data.RWMem, data.ConfigDiv, data.Reset);
  endfunction
  
  
  //doing a reset task
  task Reset(input int Period);
    BC_itf.Reset <= 1'b0;
    @(posedge BC_itf.Clk);
    BC_itf.Reset <= 1'b1;
    BC_itf.ValidCmd <= 1'b0;
    repeat(Period) @(posedge BC_itf.Clk);
    BC_itf.Reset <= 1'b0;
    @(posedge BC_itf.Clk);
    $display("[DRV] -> Reset done.");
  endtask
  
  //doing a task for correct InputKey
  task InputKey();
    @(negedge BC_itf.Clk);
    BC_itf.InputKey <= 1'b1;
    BC_itf.ValidCmd <= 1'b1;
    @(negedge BC_itf.Clk);
    BC_itf.InputKey <= 1'b0;
    @(negedge BC_itf.Clk);
    BC_itf.InputKey <= 1'b1;
    @(negedge BC_itf.Clk);
    BC_itf.InputKey <= 1'b0;
    @(negedge BC_itf.Clk);
    BC_itf.ValidCmd <= 1'b0;
    $display("[DRV] -> InputKey set corectly.");
  endtask
  
  //doing a tasks to set the frequency to ClkTx
  task SetFrequency();
    
    //mbx.get(data);
    @(negedge BC_itf.Clk);  
    BC_itf.ConfigDiv <= 1'b1;   
    BC_itf.Datain <= data.Datain;
    
    repeat(2) @(posedge BC_itf.Clk);
    BC_itf.ConfigDiv <= 1'b0;
    BC_itf.Datain <= 0;
    
    $display("[DRV] -> Frequency divided with %0d.", data.Datain);
    
  endtask
  
  task SetMode(input bit Mode, input bit RWMem);
    BC_itf.ValidCmd <= 1'b0;
    BC_itf.InputKey <= 1'b0;
    BC_itf.RWMem <= 1'b0;
    @(negedge BC_itf.Clk);
    BC_itf.ValidCmd <= 1'b1;
    BC_itf.InputKey <= Mode;
    BC_itf.RWMem <= RWMem;
    $display("[DRV] -> Mode set to %0b", Mode);
    $display("[DRV] -> RWMem set to %0b", RWMem);
  endtask
  
  task Mode1_Write();
    
    @(posedge BC_itf.Clk);
      BC_itf.InA <= data.InA;
      BC_itf.InB <= data.InB;
      BC_itf.Sel <= data.Sel;
      BC_itf.Addr <= data.Addr;
//       @(negedge BC_itf.Clk);
//       BC_itf.ValidCmd <= 1'b1;
//       BC_itf.RWMem <= 1'b1;

      wait(BC_itf.CalcBusy == 1'b1);
    
      //display_in();
    data.display_inputs("DRV");

  endtask
  
  //the main task for our driver class is to drive the stimulus to DUT
  task main();
    forever begin
      
      mbx.get(data);
      SetMode(1, 1);
      Mode1_Write();
      
      -> next_drv;
    end
  endtask 
endclass



class monitor;
  virtual Binary_Calculator_itf BC_itf;
  transaction trans;
  mailbox #(transaction) mbx;
  
  function void display_in();
    $display("[MON] -> InA: %0h, InB: %0h, Sel: %0h, Addr: %0h, Datain: %0h.", trans.InA, trans.InB, trans.Sel, trans.Addr, trans.Datain);
  endfunction
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    trans = new();
  endfunction
  
  task main();  
    forever begin
      
      wait(BC_itf.CalcBusy == 1'b1);
      @(negedge BC_itf.Clk);
      
      trans.InA = BC_itf.InA;
      trans.InB = BC_itf.InB;
      trans.Addr = BC_itf.Addr;
      trans.Sel = BC_itf.Sel;
      trans.Datain = BC_itf.Datain;
      trans.InputKey = BC_itf.InputKey;
      trans.ValidCmd = BC_itf.ValidCmd;
      trans.RWMem = BC_itf.RWMem;
      trans.ConfigDiv = BC_itf.ConfigDiv;
      trans.Reset = BC_itf.Reset;
      trans.DOutValid = BC_itf.DOutValid;
      trans.DataOut = BC_itf.DataOut;
      trans.ClkTx = BC_itf.ClkTx;
      trans.CalcActive = BC_itf.CalcActive;
      trans.CalcMode = BC_itf.CalcMode;
      trans.CalcBusy = BC_itf.CalcBusy;
      
      mbx.put(trans);
      display_in();
      $display("[MON] -> CalcBusy: %0h. Data Saved in memory.", trans.CalcBusy);
      
      @(negedge BC_itf.Clk);
      
    end
  endtask 
endclass


class scoreboard;
  transaction trans;
  mailbox #(transaction) mbx;
  event next;
  reg [31:0] memory_tmp [255:0];
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    trans = new();
  endfunction
  
  function void display_in();
    $display("[SCO] -> InA: %0h, InB: %0h, Sel: %0h, Addr: %0h, Datain: %0h.", trans.InA, trans.InB, trans.Sel, trans.Addr, trans.Datain);
  endfunction
  
  function logic [31:0] ConcatResult(input logic [7:0] A, input logic [7:0] B, input logic [3:0] Sel);
    reg [7:0] Out;
    reg [3:0] Flag;
    reg [8:0] AddTmp;
    reg [15:0] MultiplyTemp;
    reg [31:0] Result;
    
        case(Sel)
            //Adding 
            4'h0: begin
              AddTmp = A + B;
              
              if(AddTmp == 8'h00)
                Flag = 4'h1;
              else begin
              	if(AddTmp > 8'hFF)
                	Flag = 4'h2;
              	else
                	Flag = 4'h0;
              end
              Out = AddTmp;
            end
    
            //Substraction
            4'h1: begin
              if((A - B) == 8'h00) begin
                Flag = 4'h1;
                Out = A - B;
              end
              else begin
                if(A < B) begin
                  Flag = 4'h8;
                  Out = (~(A - B) + 1); //2's compliment
                end
                else begin
                    Flag = 4'h0;
                    Out = A - B;
                end
              end
            end
            
            //Multiplication
            4'h2: begin
              MultiplyTemp = A * B;
              if(MultiplyTemp == 16'h0000) begin
                Flag = 4'h1;
                Out = A * B;
              end
              else begin
                if(MultiplyTemp[15:8] == 8'h00) begin
                    Flag = 4'h0;
                    Out = MultiplyTemp[7:0];
                end
                else begin
                    Flag = 4'h4;
                    Out = MultiplyTemp[7:0];
                end 
              end
            end
            
            //Dividing
            4'h3: begin
                if(B != 8'h00)  begin
                    if(A < B) begin 
                        Flag = 4'h9;
                    end
                    else begin
                        Flag = 4'h0;
                    end
                    Out = A / B;
                end
                else begin
                  	Flag = 4'h1;
                    Out = 8'h00;
                end
            end
            
            //Shift-Left
            4'h4: begin
              if((A << B) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;
              Out = A << B;
            end
            
            //Shift-Right
            4'h5: begin
              if((A >> B) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;              
              Out = A >> B;
            end
            
            //AND
            4'h6: begin
              if((A & B) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;
              Out = A & B;
            end
            
            //OR
            4'h7: begin
              if((A | B) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;
              Out = A | B;
            end
            
            //XOR
            4'h8: begin
              if((A ^ B) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;
              Out = A ^ B;
            end
            
            //NXOR
            4'h9: begin
              if((~(A ^ B)) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;
              Out = ~(A ^ B);
            end
            
            //NAND
            4'hA: begin
              if((~(A & B)) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;
              Out = ~(A & B);
            end
            //NOR
            4'hB: begin
              if((~(A | B)) == 8'h00)
                Flag = 4'h1;
              else
                Flag = 4'h0;
              Out = ~(A | B);
            end
            
            4'hC, 
            4'hD, 
            4'hE, 
            4'hF: begin 
                Out = 8'h00;
                Flag = 4'h0;
            end    
        endcase
        
        Result = {Flag, Sel, Out, B, A};
    
    return Result;
    
  endfunction

    
  task main();
    forever begin
      mbx.get(trans);
        memory_tmp[trans.Addr] = ConcatResult(trans.InA, trans.InB, trans.Sel);
        display_in();
      $display("[SCO] -> Data: %0h saved to Address: %0h.", ConcatResult(trans.InA, trans.InB, trans.Sel), trans.Addr);
      
      $display("---------------------------------");
      -> next;
    end
    
  endtask
  
endclass


class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  mailbox #(transaction) gdmbx;  // Generator + Driver mailbox
  mailbox #(transaction) msmbx;  // Monitor + Scoreboard mailbox
  event nextgs;
  event nextgd;
  virtual Binary_Calculator_itf BC_itf;
  
  function new(virtual Binary_Calculator_itf BC_itf);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    this.BC_itf = BC_itf;
    drv.BC_itf = this.BC_itf;
    mon.BC_itf = this.BC_itf;
    gen.next_sco = nextgs;
    sco.next = nextgs;
    gen.next_drv = nextgd;
    drv.next_drv = nextgd;
  endfunction
  
  task pre_test();
    drv.Reset(1);
    drv.SetFrequency();
    drv.InputKey();
  endtask
  
  task test();
    fork
      gen.main();
      drv.main();
      mon.main();
      sco.main();
    join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);  
    $finish();
  endtask
  
  task main();
    pre_test();
    test();
    post_test();
  endtask
  
endclass



module testbench();
  
  Binary_Calculator_itf itf();
  environment env;
  
  //connect the variables that we have in an interface to the
  Binary_Calculator DUT (
    .InputKey(itf.InputKey),
    .ValidCmd(itf.ValidCmd),
    .RWMem(itf.RWMem),
    .ConfigDiv(itf.ConfigDiv),
    .Reset(itf.Reset),
    .Clk(itf.Clk),
    .Addr(itf.Addr),
    .InA(itf.InA),
    .InB(itf.InB),
    .Sel(itf.Sel),
    .Datain(itf.Datain),
    .CalcActive(itf.CalcActive),
    .CalcMode(itf.CalcMode),
    .CalcBusy(itf.CalcBusy),
    .DOutValid(itf.DOutValid),
    .DataOut(itf.DataOut),
    .ClkTx(itf.ClkTx)
  );
  
  //generate the clock signal
  initial begin
    itf.Clk <= 1'b0;
  end
  
  always #5 itf.Clk <= ~itf.Clk;
  
  initial begin
    env = new(itf);
    env.gen.counter = 5;
    env.main();
  end
    
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
