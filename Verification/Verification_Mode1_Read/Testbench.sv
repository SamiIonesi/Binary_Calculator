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
      assert(trans.randomize) else $display("Randomize failed.");
      mbx.put(trans.copy);
      $display("---------------------------------");
      trans.display_inputs("GEN");
      @(next_drv);
      @(next_sco);
    end
    -> done;
  endtask
  
endclass



class driver;
  virtual Binary_Calculator_itf BC_itf;
  mailbox #(transaction) mbx;
  mailbox #(logic [31:0]) mbx_ds;
  //logic [31:0] ConcatData; 
  transaction data;
  event next_drv;
  
  bit [31:0] memory_tmp [255:0];
  
  function new(mailbox #(transaction) mbx, mailbox #(logic [31:0]) mbx_ds);
    this.mbx = mbx;
    this.mbx_ds = mbx_ds;
    data = new();
  endfunction
  
  function void display_in();
    $display("[%0t]:[DRV] -> InA: %0h, InB: %0h, Sel: %0h, Addr: %0h, Datain: %0h, InputKey: %0b, ValidCmd: %0b, RWMem->: %0b, ConfigDiv: %0b, Reset: %0b ", $time(), data.InA, data.InB, data.Sel, data.Addr, data.Datain, data.InputKey, data.ValidCmd, data.RWMem, data.ConfigDiv, data.Reset);
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
    @(posedge BC_itf.Clk);  
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
  
  task Write();
    @(negedge BC_itf.Clk);
    BC_itf.ValidCmd <= 1'b1;
    BC_itf.RWMem <= 1'b1;
    BC_itf.InA <= data.InA;
    BC_itf.InB <= data.InB;
    BC_itf.Sel <= data.Sel;
    BC_itf.Addr <= data.Addr;
    display_in();
  endtask
  
  //the main task for our driver class is to drive the stimulus to DUT
  task main();
    forever begin
      
      mbx.get(data);
      
      //set all inputs to 0
      BC_itf.ValidCmd <= 1'b0;
      BC_itf.InputKey <= 1'b0;
      BC_itf.RWMem <= 1'b0;
      BC_itf.InA <= 8'h00;
      BC_itf.InB <= 8'h00;
      BC_itf.Sel <= 4'h0;
      BC_itf.Addr <= 8'h00;
      
      //set random inputs
      @(posedge BC_itf.Clk);
      BC_itf.InA <= data.InA;
      BC_itf.InB <= data.InB;
      BC_itf.Sel <= data.Sel;
      BC_itf.Addr <= data.Addr;
      mbx_ds.put(memory_tmp[data.Addr]);
      
      //set the mode
      SetMode(1, 0);
      
      //wait for start the transfer
      wait(BC_itf.DOutValid == 1'b1);
      $display("[DRV] -> Transfer started! Data Sent to Serial: %0h, from Addr: %0h.", memory_tmp[data.Addr], data.Addr);
      
      //wait for transfer to be done
      wait(BC_itf.DOutValid == 1'b0);
      
      //set all inputs to 0
      BC_itf.ValidCmd <= 1'b0;
      BC_itf.InputKey <= 1'b0;
      BC_itf.RWMem <= 1'b0;
      BC_itf.InA <= 8'h00;
      BC_itf.InB <= 8'h00;
      BC_itf.Sel <= 4'h0;
      BC_itf.Addr <= 8'h00;
     
      -> next_drv;
    end
    
  endtask 
  
endclass



class monitor;
  virtual Binary_Calculator_itf BC_itf;
  transaction trans;
  //mailbox #(transaction) mbx;
  mailbox #(logic [31:0]) mbx_ms;
  logic [31:0] SerialData; 
  
  function void display_in();
    $display("[%0t]:[MON] -> InA: %0h, InB: %0h, Sel: %0h, Addr: %0h, Datain: %0h, InputKey: %0b, ValidCmd: %0b, RWMem->: %0b, ConfigDiv: %0b, Reset: %0b ", $time(), trans.InA, trans.InB, trans.Sel, trans.Addr, trans.Datain, trans.InputKey, trans.ValidCmd, trans.RWMem, trans.ConfigDiv, trans.Reset);
  endfunction
  
  function new(mailbox #(logic [31:0]) mbx_ms);
    //this.mbx = mbx;
    this.mbx_ms = mbx_ms;
    //trans = new();
  endfunction
  
  task main(); 
    
    wait(BC_itf.DOutValid == 1'b1);
    
    for (int i = 0; i <= 31; i++) begin
      @(negedge BC_itf.ClkTx);
      SerialData[31 - i] = BC_itf.DataOut;
    end
    
    wait(BC_itf.DOutValid == 1'b0);
    @(posedge BC_itf.ClkTx);
    
    $display("[MON] -> Transfer ended! Data Receaved from Serial: %0h.", SerialData);
    mbx_ms.put(SerialData);
    
  endtask
  
endclass



class scoreboard;
  transaction trans;
  mailbox #(logic [31:0]) mbx_ds;
  logic [31:0] ConcatData; 
  mailbox #(logic [31:0]) mbx_ms;
  event next;
  
  //reg [31:0] memory_tmp [255:0];
  logic [31:0] Data_ms;
  
  function new( mailbox #(logic [31:0]) mbx_ms, mailbox #(logic [31:0]) mbx_ds);
    this.mbx_ms = mbx_ms;
    this.mbx_ds = mbx_ds;
    //trans = new();
  endfunction
  
  function void display_in();
    $display("[%0t]:[SCO] -> InA: %0h, InB: %0h, Sel: %0h, Addr: %0h, Datain: %0h, InputKey: %0b, ValidCmd: %0b, RWMem->: %0b, ConfigDiv: %0b, Reset: %0b ", $time(), trans.InA, trans.InB, trans.Sel, trans.Addr, trans.Datain, trans.InputKey, trans.ValidCmd, trans.RWMem, trans.ConfigDiv, trans.Reset);
  endfunction
    
  task main();
    forever begin
      
      mbx_ds.get(ConcatData);
      mbx_ms.get(Data_ms);
      
      $display("[SCO] -> DRV : %0h, MON : %0h.", ConcatData, Data_ms);
        
      if(ConcatData == Data_ms)
        $display("[SCO] -> DATA MATCHED!");
      else
        $display("[SCO] -> DATA MISMATCHED!");
      
      $display("---------------------------------");
      
      ->next;
    end
    
  endtask
  
endclass


class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  mailbox #(transaction) gdmbx;  // Generator + Driver mailbox
  //mailbox #(transaction) msmbx;  // Monitor + Scoreboard mailbox
  mailbox #(logic [31:0]) mbx_ms; //monitor - scoreboard mailbox
  mailbox #(logic [31:0]) mbx_ds;
  event nextgs;
  event nextgd;
  virtual Binary_Calculator_itf BC_itf;
  
  function new(virtual Binary_Calculator_itf BC_itf);
    gdmbx = new();
    //msmbx = new();
    mbx_ms = new();
    mbx_ds = new();
    
    gen = new(gdmbx);
    drv = new(gdmbx, mbx_ds);
    mon = new(mbx_ms);
    sco = new(mbx_ms, mbx_ds);
    
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
    env.gen.counter = 1;
    env.main();
  end
    
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
