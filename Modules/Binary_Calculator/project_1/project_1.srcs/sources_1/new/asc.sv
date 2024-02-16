// Eda PlayGround Link: https://www.edaplayground.com/x/LnYN

// Modulul este complet, testbenchu-ul este bogat si diversificat

module Mux #(parameter LENGTH = 8)( // combinational circuit
  input 		[LENGTH-1:0] In, 	//  	first input
  input 		[LENGTH-1:0] Zero, 	// 	second input
  input      	  	  		 Sel, 	// 	selection bit
  output 	reg [LENGTH-1:0] Out 	// 	value sent
);
  always@(*) begin 	// while something was changed
    if (Sel) begin
      Out <= Zero; 	// if Sel active then send the second input
    end else begin
      Out <= In;	// if Sel inactive then send the first input
    end
  end
endmodule


module concatenator( // combinational circuit
  // those are the values that will be concatenated
  input   	[7:0] InA,
  input   	[7:0] InB,
  input   	[7:0] InC,
  input   	[3:0] InD,
  input   	[3:0] InE,
  // this is the result of concatenation
  output   [31:0] Out 
);
  // we make use of concatenation operator
  assign Out ={InE,InD,InC,InB,InA};
  
endmodule


// we'll use this module in order to implement EightBitsFullAdder

module fullAdder( 	// combinational circuit
   input a, 		// first bit to add
   input b, 		// second bit to add
   input cin, 		// carryIn bit
   output reg sum, 	// sum bit
   output reg cout 	// carryOut bit
 );
 
   always @(*) // while something is changed
    begin
      case ({a,b,cin}) // checking all cases
        3'b000: 	begin sum = 1'b0; cout = 1'b0; end
        3'b001: 	begin sum = 1'b1; cout = 1'b0; end
        3'b010: 	begin sum = 1'b1; cout = 1'b0; end
        3'b011: 	begin sum = 1'b0; cout = 1'b1; end
        3'b100: 	begin sum = 1'b1; cout = 1'b0; end
        3'b101: 	begin sum = 1'b0; cout = 1'b1; end
        3'b110: 	begin sum = 1'b0; cout = 1'b1; end
        3'b111: 	begin sum = 1'b1; cout = 1'b1; end
        default: 	begin sum = 1'bx; cout = 1'bx; end
      endcase
    end
      
endmodule

// we'll use this module in order to implement Add operation in ALU 
module EightBitsFullAdder( // combinational circuit
  input [7:0] a, 	// first number to add
  input [7:0] b, 	// second number to add
  input cin,	 	// carryIn bit
  output [7:0] sum,	// result number
  output cout		// carryOut bit
);
  
  // we'll build up the EightBitsFullAdder by connecting 8 individual one-bit FullAdder s.
    wire [6:0] carry; // to carry the "cout" of each fullAdder to the next one.
  
  fullAdder fa0(.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(carry[0]));
  fullAdder fa1(.a(a[1]), .b(b[1]), .cin(carry[0]), .sum(sum[1]), .cout(carry[1]));
  fullAdder fa2(.a(a[2]), .b(b[2]), .cin(carry[1]), .sum(sum[2]), .cout(carry[2]));
  fullAdder fa3(.a(a[3]), .b(b[3]), .cin(carry[2]), .sum(sum[3]), .cout(carry[3]));
  fullAdder fa4(.a(a[4]), .b(b[4]), .cin(carry[3]),
.sum(sum[4]), .cout(carry[4]));
  fullAdder fa5(.a(a[5]), .b(b[5]), .cin(carry[4]), .sum(sum[5]), .cout(carry[5]));
  fullAdder fa6(.a(a[6]), .b(b[6]), .cin(carry[5]), .sum(sum[6]), .cout(carry[6]));
  fullAdder fa7(.a(a[7]), .b(b[7]), .cin(carry[6]), .sum(sum[7]), .cout(cout));
     
endmodule      
    
module ALU(  // combinational circuit
  input 		[7:0] A, 	// first operant
  input 		[7:0] B, 	// second operant
  input 		[3:0] Sel, 	// operator selection
  output 	reg	[3:0] Flag,	// flags activated after operation
  output 	reg	[7:0] Out	// operation's result
);      
  
  reg zeroFlag, carryFlag, underflowFlag, overflowFlag; // intern registers to monitorize each flag
  reg [15:0]  temp_multiply_result; // to keep multiplication's result
  reg [263:0] temp_left_shift;		// to keep left-shifting's  result
  reg [7:0]   temp_right_shift;		// to keep right-shifting's result
  reg [63:0]  temp_pow;				// to keep pow's result
  
  wire [7:0] addOut; // the result of sum, obtained by EightBitsFullAdder
  wire addCarry;	 // the carryFlag of sum, obtained by EightBitsFullAdder
  
  // instantiate a EightBitsFullAdder in order to succeed add operation
  EightBitsFullAdder myAdd(.a(A), .b(B), .cin(0), .sum(addOut), .cout(addCarry));
  
  always @(*) begin // whenever something changes
    case (Sel)
      4'h0 : begin // adunare
		Out             <= addOut; // from myAdd
		carryFlag       <= addCarry; // from myAdd
        underflowFlag 	<= 0;
        overflowFlag  	<= 0; 
      end
      4'h1 : begin // scadere
        if (A < B) begin // if result is negative, represent it in C2 and set underflow
          underflowFlag <= 1;
          Out 			<= ~(A-B)+1; // C2 representation
        end else begin // if result is positive
          underflowFlag <= 0;
          Out 			<= A-B;
        end
          carryFlag		<= 0; 
          overflowFlag  <= 0;
      end 
      4'h2 : begin // inmultire 
        temp_multiply_result <= A*B; 
        if (temp_multiply_result > 8'hFF) begin // if entire result can't be represented on 8 bits, then truncate it and set overflow
          overflowFlag 	<= 1;
          Out 			<= temp_multiply_result[7:0];
        end else begin // else there is no overflow
          overflowFlag  <= 0;
          Out			<= temp_multiply_result[7:0];
        end
       	  carryFlag 	<= 0; 
      	  underflowFlag	<= 0; 
      end
      4'h3 : begin // impartire
        if (A<B) begin 	// if result < 1 then underflow
          underflowFlag <= 1;
        end else begin // else there is no underflow
          underflowFlag <= 0; 
        end
        Out				<= A/B;
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
      end
      4'h4	: begin // shift stanga
        temp_left_shift <= A<<B; 
        if (temp_left_shift > 8'hFF) begin // if entire result can't be represented on 8 bits, then truncate it and set overflow
          overflowFlag 	<= 1;
          Out 		 	<= temp_left_shift[7:0];
        end else begin // else there is no overflow
      	  overflowFlag 	<= 0;
          Out 			<= temp_left_shift[7:0];
        end
        carryFlag 		<= 0;
        underflowFlag   <= 0;
      end
      4'h5	: begin // shift dreapta
        if (A<2**B) begin // by right shifting, the number will be divided by 2^B, so we check existence of underflow
          underflowFlag <= 1;
        end else begin
          underflowFlag <= 0;
        end
          Out 			<= A>>B;
          overflowFlag  <= 0;
          carryFlag 	<= 0;
      end
      4'h6 : begin // AND
        Out 			<= A&B;
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
        underflowFlag 	<= 0;
      end
      4'h7 : begin // OR
        Out 			<= A|B;
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
        underflowFlag 	<= 0;
      end
      4'h8: begin // XOR
        Out 			<= A^B;
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
        underflowFlag   <= 0;
      end
      4'h9: begin // NXOR
        Out 			<= ~(A^B);
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
        underflowFlag   <= 0;
      end
      4'hA: begin // NAND
        Out 			<= ~(A&B);
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
        underflowFlag 	<= 0;
      end
      4'hB: begin // NOR
        Out 			<= ~(A|B);
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
        underflowFlag   <= 0;
      end
      4'hC : begin // POW
        if (B > 8'h8) begin // we chose that maximum size for result will be 64 bits for each A, result that B should be maximum 8, otherwise set out = 0 and overflow
        	Out				<= 0;
            carryFlag		<= 0;
            overflowFlag	<= 1;
            underflowFlag	<= 0;
        end else begin
        	temp_pow <= A**B;
          if (temp_pow > 8'hFF) begin // if entire result can't be represented on 8 bits, then truncate it and set overflow
            	overflowFlag 	<= 1;
          		Out 			<= temp_pow[7:0];
            end else begin // else there is no overflow
            	overflowFlag 	<= 0;
          		Out 			<= temp_pow[7:0];
            end
          // at this operation there is no carry or underflow
            carryFlag			<= 0;
            underflowFlag		<= 0;
        end
      end
      //4'hC,
      
      4'hD: begin // MOD
        if(B == 0) begin // Mod 0 is strange operation so set out to 0 and activate underflowFlag
          Out			<= 0;
          underflowFlag	<= 1;
          carryFlag		<= 0;
          overflowFlag	<= 0;
        end else begin // Otherwise, the results are the one expected
      	  Out			<= A%B;
          carryFlag		<= 0;
          overflowFlag	<= 0;
          underflowFlag	<= 0;
        end
      end
     
      //4'hD,
      4'hE,4'hF : begin // Default cases, nothing happens
        Out 			<= 8'h00;
        carryFlag 		<= 0;
        overflowFlag 	<= 0;
        underflowFlag	<= 0;
      end 
    endcase
    
     // Set the ZeroFlag
    if ((Out == 8'h0) && (Sel <= 4'hD)) begin
            zeroFlag = 1;
      end else begin
            zeroFlag = 0;
      end
        // Assign the flags
        Flag[0] = zeroFlag;
        Flag[1] = carryFlag;
        Flag[2] = overflowFlag;
        Flag[3] = underflowFlag;
    
  end
  
endmodule 


module memory #(
  parameter WIDTH = 8, // each location of memory will be represented on WIDTH bits, so there will be 2^WIDTH locations of memory
  parameter DinLENGTH =32// the size of a data storaged in a location 
) (
  input 	[DinLENGTH-1:0] Din, 	// Input data that will be storaged
  input 	[WIDTH-1:0] 	Addr, 	// Address to write at/ read from
  input 					Valid,  // Indicate the access to memory 
  input 					R_W, // type of operation Read(0) / Write(1)
  input 					Reset, 
  input 					Clock, 
  output	reg [DinLENGTH-1:0] Dout // output data 
);
  
  reg [DinLENGTH-1:0] myMemory [2**WIDTH-1:0]; // intern register with 2^WIDTH location, where each location contains a data represented on DinLENGTH bits
  integer index; // intern integer to go ahead a for loop 
  
  always @(posedge Clock, posedge Reset) begin // whenever Clock of Reset are on positive front
    if (Reset) begin  // Reset the memory register and set Dout on 0
      for (index = 0; index<=2**WIDTH-1; index = index+1) begin
        myMemory[index] <= 0;
      end
      Dout <= 0;
    end else begin // if No reset
      if(!Valid) begin // memory can't be accessed
        Dout <= 0; // set Dout on 0
      end else begin // memory can be accessed
        if(!R_W) begin // Read
          Dout <= myMemory[Addr]; // set Dout on value read from specified address in memory 
        end else begin // Write
          myMemory[Addr] <= Din; // write Din in memory at specified address  
          Dout <= 0; // set Dout on 0, we don't want to Ouput some data when writing in memory
        end
      end
    end
  end
  
  
endmodule

module DecInputKey( // sequential circuit 
  input  InputKey, // input that will be taken into consideration in order to establish the start on of BinaryCalculator, the "cirucit" becomes active when whe enter 1-0-1-0 in this order. And later, the value of Mode
  input Clock,
  input Reset,
  input ValidCmd,// it says if we colud introduce InputKey
  output reg Active, // notify us that the circuit became active
  output reg Mode // tell us if circuit has or no access to Memory
);
  
  
  
  // defining states : sequential
  localparam IDLE 	= 3'b000; // start/reset state
  localparam S1		= 3'b001; // when we got 1
  localparam S2 	= 3'b010; // when we got 1-0
  localparam S3 	= 3'b011; // when we got 1-0-1
  localparam S4 	= 3'b100; // when we got 1-0-1-0 
  localparam S5 	= 3'b101; // when we unlocked the circuit and received a Mode . Then make the circuit Active.
  localparam Fail 	= 3'bxxx; // fail state, could'n unlock the circuit because we didn't receive 1-0-1-0 as Key
  
  // intern registers for current/next state
  reg [4:0] current_state;
  reg [4:0] next_state; // the next state we will arrive, starting by current_state
  
  // decodificator modelling
  
  always@(InputKey, current_state) begin // whenever InputKey or current_state changes
    case (current_state) // treats all cases
      IDLE : begin
        if (InputKey == 1'b1) begin // receive 1 so we could go ahead to S1
          next_state = S1;
        end else begin // goes to Fail and wait for Reset
          next_state = Fail;
        end
      end
      S1 : begin
        if (InputKey == 1'b0) begin // receive 0 so we could go ahead to S2
          next_state = S2;
        end else begin // goes to Fail and wait for Reset 
          next_state = Fail;
        end
      end
      S2 : begin
        if (InputKey == 1'b1) begin // reveive 1 so we could go ahead to S3
          next_state = S3;
        end else begin // goes to Fail and wait for Reset
          next_state = Fail;
        end
      end
      S3 : begin
        if (InputKey == 1'b0) begin // reveive 0 so we could go ahead to S4, when the cirucuit will be unlocked
          next_state = S4;
        end else begin // goes to Fail and wait for Reset
          next_state = Fail;
        end
      end
      S4 : begin
        next_state = S5; // receive a Mode and go ahead to S5
      end
      S5 : begin
        next_state = S5; // continue to receive a Mode and still in S5
      end
      Fail : begin
        next_state = Fail; // can't exit Fail state without Reset
      end
      default: begin 
        next_state = Fail; // if something unexpected happens, go to Fail and wait Reset
      end
    endcase
  end
  
  // state register modelling
        
  always @(posedge Clock, posedge Reset) begin // whenever Clock or Reset are on positive front 
    if(Reset) begin // make the current_state equals with initial state 
      current_state <= IDLE;
    end else begin // else we could go ahead 
      if(ValidCmd) begin // state changing only happend when ValidCmd is 1
      current_state <= next_state;
        if(/*current_state == S4 ||*/ current_state == S5) begin // if we unlocked the circuit and then we start to receive Mode
          Mode 		<= InputKey;
        end
      end
    end
  end
      
      
  // output decodificator modelling 
  
  always @ (current_state) // whenever current_state changes
    case (current_state) 
    IDLE:    begin Active <= 1'b0; Mode <= 1'b0;  end 
    S1:      begin Active <= 1'b0; Mode <= 1'b0;  end
    S2:      begin Active <= 1'b0; Mode <= 1'b0;  end
    S3:		 begin Active <= 1'b0; Mode <= 1'b0;  end
    S4: 	 begin Active <= 1'b0; Mode <= 1'b0;  end // we unlocked the circuit 
    S5:      begin Active <= 1'b1; Mode	<= Mode;  end // here the circuit becomes active and receive the Mode
    Fail:    begin Active <= 1'b0; Mode <= 1'b0;  end
      default: begin Active <= 1'bx; Mode <= 1'bx;  end // if something unexpected happens
  endcase

  
endmodule


module Control_RW_Flow( 	// sequential circuit 
	input 		ValidCmd, 	// indicates if we start or no an command
  	input 		RW, 		// indicates if it will be a read or write command
  	input 		Reset,
  	input 		Clock,
  	input 		TxDone, 	// indicates if the previous transfer is completed
  	input 		Active,		// indicates if the circuit is active
  	input 		Mode, 		// indicates if we are dealing or not with memory
  	output 	reg	AccessMem, 	// indicates the access at memory
  	output  reg RWMem, 		// indicates action done with memory (read or write)
  	output 	reg	SampleData, // indicates the loading of read data from memory in SerialTransceiver 
  	output 	reg TxData, 	// indicates starting of a new data Transfer
  	output 	reg	Busy 		// indicates if we're solving a command 
);
  // defining local states by one-hot encoding
  localparam state_IDLE 			= 6'b000000; // initial/reset state
  
  // if we are reading from memory, we start a state-cycle that wouldn't be interrupted until it reaches the end:
  // IDLE -> ReadMemory -> SampleSerialTransceiver -> SampleStartTransferSerialTransceiver -> WaitTransferDone -> IDLE
  localparam state_ReadMemory 		= 6'b000010; // ReadMemory state
  localparam state_SampleST 		= 6'b000100; // SampleSerialTransceiver state (loading data)
  localparam state_StartTransferST 	= 6'b001000; // StartTransferSerialTransceiver (starting a new transfer)
  localparam state_WaitTxDone 		= 6'b010000; // WaitTransferDone state -> wait until the transfer is done
  
  
  // if we're writin to memory, then we start a shorter state-cycle that would'nt be interrupted until it's end:
  // IDLE -> WriteMemory -> IDLE
  localparam state_WriteMemory		= 6'b100000; // WriteMemory State
  
  
  localparam state_Fail  			= 6'bxxxxxx; // Fail State, if something goes wrong. Can't exit from it without Reset
 
  
  // intern registers for current/next state
  reg [5:0] current_state;
  reg [5:0] next_state;
  
  // state decodificator modelling
  
  always@(*) begin // whnever something changes
    case (current_state)
      
      state_IDLE : 				begin // if initial state
        if (ValidCmd && Active && Mode && !RW) begin // if we have a valid command, the circuit is active, the mode shows access to memory and RW = 0 (read command) ,then go to ReadMemory state.
      		next_state 		<= state_ReadMemory;
        end
        else if (ValidCmd && Active && Mode && RW) begin // if we have a valid command, the circuit is active, the mode shows access to memory and RW = 1(write command), then go to WriteMemory state. 
          	next_state 		<= state_WriteMemory;
        end
        else if (ValidCmd && Active && !Mode) begin // if we have a valid command, the circuit is active but the mode shows no access to memory, then go to SampleST state in order to load the data to SerialTransceiver
          	next_state 		<= state_SampleST;
        end else begin // if no one of this cases, remain in initial state untill a state-cycle is started
        	next_state		<= state_IDLE;
        end
      end
      
      // in the following, we would'nt take consideration of ValidCmd because we know the state-cycle has already been started.
       
      state_ReadMemory : 		begin // continue the state-cycle
        	next_state 		<= state_SampleST;
      end
      
      state_SampleST : 			begin // continue the state-cycle
       		next_state 		<= state_StartTransferST;
      end
      
      state_StartTransferST : 	begin // continue the state-cycle
        	next_state		<= state_WaitTxDone;
      end
      
      state_WaitTxDone :		begin // continue the state-cycle only when the transfer is done
        if (TxDone) begin
      		next_state		<= state_IDLE;
        end else begin
          //do nothing...Wait for transfer to finish
        end
      end
      
      state_WriteMemory : 		begin // continue the state-cycle. We notice that writing is done during one Clock period
          	next_state		<= state_IDLE;
      end
      
      default: begin 		// in case of something goes wrong, wait for Reset
       	 	next_state		<= state_Fail;
      end
    endcase
  end
  
  // state register modelling 
         
  always @(posedge Clock, posedge Reset) begin // whenever Clock or Reset are on positive front 
    if(Reset) begin // if Reset, then reset the state end set outputs to 0.
      current_state			 	<= state_IDLE;
      AccessMem 				<= 0;
      RWMem						<= 0;
  	  SampleData				<= 0;
  	  TxData					<= 0;
  	  Busy						<= 0;
    end else begin // else, continue the state-cycle
      current_state				<= next_state;
    end
  end
 
  // output decodificator modelling 
  
  always @ (current_state) begin
    case (current_state) 
    	state_IDLE :   begin // all output set to 0
      	 	AccessMem 				<= 1'b0;
      		RWMem					<= 1'b0;
  	  		SampleData				<= 1'b0;
  	  		TxData					<= 1'b0;
  	  		Busy					<= 1'b0;	
    	end
      state_ReadMemory :      begin // we have access to Memory and the circuit is Busy(untill the end of state-cycle)
           	AccessMem 				<= 1'b1;
      		RWMem					<= 1'b0;
  	  		SampleData				<= 1'b0;
  	  		TxData					<= 1'b0;
  	  		Busy					<= 1'b1;  
        end
    	state_SampleST :   begin  // we loaded data to SerialTransceiver
      	 	AccessMem 				<= 1'b0;
      		RWMem					<= 1'b0;
  	  		SampleData				<= 1'b1;
  	  		TxData					<= 1'b0;
  	  		Busy					<= 1'b1;	
    	end
    	state_StartTransferST :   begin // we start Transfer in SerialTransceiver
           	AccessMem 				<= 1'b0;
      		RWMem					<= 1'b0;
  	  		SampleData				<= 1'b0;
  	  		TxData					<= 1'b1;
  	  		Busy					<= 1'b1;  
        end
  		state_WaitTxDone :   begin // we are transfering Data 
      	 	AccessMem 				<= 1'b0;
      		RWMem					<= 1'b0;
  	  		SampleData				<= 1'b0;
  	  		TxData					<= 1'b1;
  	  		Busy					<= 1'b1;	
    	end
      	state_WriteMemory :      begin // Write in memory
           	AccessMem 				<= 1'b1;
      		RWMem					<= 1'b1;
  	  		SampleData				<= 1'b0;
  	  		TxData					<= 1'b0;
  	  		Busy					<= 1'b1;  
        end
    	default: begin 
   			AccessMem 				<= 1'b0;
      		RWMem					<= 1'b0;
  	  		SampleData				<= 1'b0;
  	  		TxData					<= 1'b0;
  	  		Busy					<= 1'b0;
    	end
  endcase
  end
  
  
endmodule


module SerialTransceiver #( // sequential circuit 
  parameter LENGTH = 32 // parametrized length of input Data
)(
  input [LENGTH-1:0]     DataIn, 	// input data that will be sent to output, bit by bit
  input                  Sample, 	// indicates the data was loaded  
  input                  StartTx,	// indicates the transfer was started 
  input                  Reset,	
  input                  Clock,
  input                  ClockTx,	// the new ClockTx that the Data transfer is done at
  output reg             TxDone,    // indicates the transfer is completely done
  output reg             TxBusy,	// indicates the serial transceiver is busy
  output reg             Dout		// output data - 1 bit
);
  reg TxxBusy; // intern register used to avoid starting another transfer since one is in proccess
  			   // DataIn can be modified after it was loaded, but doesn't change inside the transfer until TxDone
  integer regPos;
  reg [31:0]	   sizeTransceived; // indicates us how many bits were transceived
  reg [LENGTH-1:0] shift_register;  // intern register that storage Input Data 
  
  always @(posedge Clock or posedge Reset) begin // whenever Reset or Clock are on positive front
    if (Reset) begin // if reset, then reset the interg register and set outputs and TxxBusy to 0
      for (regPos = 0; regPos < LENGTH; regPos = regPos + 1) begin
        shift_register[regPos] <= 1'b0;
      end
      TxDone          <= 0;
      TxBusy          <= 0;
      Dout            <= 0;
      sizeTransceived <= 0;
      TxxBusy 		  <= 0;
    end
    else begin
      if (Sample && !StartTx) begin 
        if(!TxxBusy) begin// if data loaded, transfer not started and no other transfer in proccess
        	shift_register <= DataIn; // load DataIn to intern register
        end
      end else if (!Sample && StartTx) begin // if no longer load Data and Start transfer 
        if(!TxDone) begin // if Transfer is not completed, still work to do 
        	TxxBusy 	 	<= 1;
        end else begin
        	TxxBusy		<= 0;
        end
      end else if (Sample && StartTx) begin
        // do nothing in this case
      end
      
      if (sizeTransceived == LENGTH+1) begin // if all bits were transcived, set TxDone.
        TxDone 				<= 1;
        sizeTransceived		<= 0;
        TxBusy				<= 0;
      	TxxBusy 			<= 0;
        Dout				<= 0;
      end else begin
      	TxDone				<= 0;
      end
      
    end
  end
  
  always @(posedge ClockTx, posedge Reset) begin // whenever ClockTx or Reset are on positive front
    if(Reset) begin	// if Reset, set intern registers and part of output to 0
      sizeTransceived 	<= 0;
      TxBusy 			<= 0;
      TxxBusy			<= 0;
      Dout				<= 0;
    end
    if (sizeTransceived <= LENGTH) begin // if still work to do
      if (TxxBusy) begin // check if circuit still busy  
        TxBusy			<= 1;
        Dout            <= shift_register[LENGTH-1];
        shift_register 	<= {shift_register[LENGTH-2:0], 1'b0}; // left shifting in order to eliminate the bits that have already been transceived
      	sizeTransceived <= sizeTransceived + 1; // increase number of transceived bits

      end
    end
    
    if (sizeTransceived == LENGTH) begin // if completed
      TxxBusy 			<= 0;
      TxBusy			<= 0;
    end
    
  end
  
endmodule

module FrequencyDivider (	 // sequential circuit  
  input        Clock,
  input        Reset,
  input        Enable,		// indicates if circuit is Active
  input 	   ConfigDiv,	// indicates if we want to change the freqeunce
  input [31:0] Din,			// the frequence we want to implement
  output reg   ClockOut		// the output, the new Clock
);

  reg [31:0] internReg; // intern register that will store the frequence we want to implement
  reg [31:0] counter;	// intern register that will continously count positive initial clock

  
  always @(posedge Clock) begin
    counter 		<= counter +1; // increase counter
    
    if (Reset) begin // reset counter, and set ClockOut to 1, internReg is by default 1
      	ClockOut  		<= 0;
      	counter 		<= 0;
      	internReg		<= 1;
    end else begin
      if(!Enable) begin // if circuit not Enable, ClockOut is 0
      	ClockOut		<= 0;
        if(ConfigDiv) begin	// check for changing frequency we want to implement
        	internReg	<= Din;
      	end else begin
        	internReg	<= internReg;	
      	end
      end else begin
        if(internReg >=2) begin // if frequence we want to implement is >= 2 then set ClockOut 1 to first internReg/2 clocks and 0 to the rest till internReg
      		if(counter % internReg < internReg/2)
        		ClockOut <= 1;
      		else 
        		ClockOut <= 0;
    		end
    	end
      end
 end
  
  always @(posedge Clock or negedge Clock) begin // use this for internReg = 1, when we want ClockOut to be exactly like Clock 
    if (Reset) begin // reset
      	ClockOut  		<= 0;
      	counter 		<= 0;
      	internReg		<= 1;
    end else begin
      if(Enable) begin // if circuit is Enable
        if(internReg == 1) begin	
        ClockOut 	<= Clock;
      end
    end
    else begin // if circuti not Enable, ClockOut will be 0
      	ClockOut	<= 0;
    end
    end
  end

endmodule


module	Controller( // sequential circuit to incorporrate DecInputKey and Control_RW_Flow in one entity, in order to propagate one clock delay between DecInputKey and Control_RW_Flow
  input 		Clock,
  input 		Reset,
  input 		ValidCmd, 	// indicates if we have a Valid Command to proccess
  input 		InputKey, 	// input that will be taken into consideration in order to establish the start on of BinaryCalculator, the "cirucit" becomes active when whe enter 1-0-1-0 in this order. And later, the value of Mode
  input 		RW, 		// indicates if we're doing a read or write operation
  input 		TxDone,		// indicates if transfer of SerialTransceiver has been completed
  output		Active,		// indicates if circuit is Active
  output 		Mode,		// indicates the Mode
  output 		Busy,		// indicates if cirucit is Busy with one command
  output 		RWMem,		// indicates if we read from memory or write on it
  output		AccessMem,	// indicates if we have access to Memory
  output 		SampleData,	// indicates if we load the data to SerialTransceiver
  output 		TxData		// indicates if we make Data Transfer on SerialTransceiver
);
  
  wire ActiveWire; 	// intern register to send the Active output from DecInputKey to Control_RW_Flow
  wire ModeWire;	// intern register to send the Mode output from DecInputKey to Control_RW_Flow
  
  
  
  DecInputKey decInputKey( // instantiate DecInputKey module
    .InputKey(InputKey),
    .Clock(Clock),
    .Reset(Reset),
    .ValidCmd(ValidCmd),
    .Active(ActiveWire), // here ActiveWire take the desired value
    .Mode(ModeWire)		 // here ModeWire 	take the desired value
  );
  
  // assign them to output
  assign Active = ActiveWire;
  assign Mode 	= ModeWire;
  
  Control_RW_Flow control_RW_Flow( 	// instantiate Control_RW_Flow module
    .Clock(Clock),					
    .Reset(Reset),					
    .ValidCmd(ValidCmd),			
    .TxDone(TxDone),				
    .RW(RW),						
    .Active(ActiveWire),
    .Mode(ModeWire),
    .AccessMem(AccessMem),
    .RWMem(RWMem),
    .SampleData(SampleData),
    .TxData(TxData),
    .Busy(Busy)
  );
  
  
endmodule


module BinaryCalculator( 			// the integration module - Binary Calculator
  input 		Clock,				// Clock signal
  input 		Reset,				// Reset signal
  input 		InputKey,			// InputKey signal
  input 		ValidCmd,			// Valid Command signal 
  input 		RWMem,				// indicates which type of operation will be proccessed
  input [7:0]	Address,			// a memory location to deal with during operation
  input [7:0] 	InA,				// first operand
  input [7:0] 	InB,				// second operand
  input [3:0] 	Sel,				// type of operation
  input 		ConfigDiv,			// indicates whether we want to change the frequency or not
  input [31:0] 	Din,				// the new frequency we want to change
  output 		DOutValid,			// tells us if the SerialTransceiver is proccessing a transfer
  output 		DataOut,			// a bit of Output that will be sent by SerialTransceiver
  output 		ClkTx,				// the Clock Serial Trasnceiver will use in order to send the output
  output		CalcActive,			// tells us if circuit is Active
  output 		CalcMode,			// tells us if circuit is dealing with Memory or not
  output 		Busy				// tells us if circuit is busy with one command
);
  
  //local parameters that will be used to initialize modules
  localparam DEFAULT_LENGTH = 8;
  localparam LARGE_LENGTH 	= 32;
  localparam SMALL_LENGTH	= 4;
  
  localparam DEFAULT_ZERO   = 8'b00000000;
  localparam SHORT_ZERO		= 4'b0000;
  
  // local wires that will be used to transfer outputs from one module to input for another modules and vice-vers
  wire ActiveWire;
  wire CtrlModeTmp;
  wire ResetTmp;
  
  
  assign ResetTmp 	= ~ActiveWire || Reset;
  assign CalcActive	= ActiveWire;
  assign CalcMode	= CtrlModeTmp;
  
  // to tranport the results of Muxs
  wire 	[7:0] 	MuxInATmp;
  wire 	[7:0]	MuxInBTmp;
  wire 	[3:0] 	MuxSelTmp;
  
  // initialize the Muxs
  Mux #(.LENGTH(DEFAULT_LENGTH)) M1(
    .In(InA),
    .Zero(DEFAULT_ZERO),
    .Sel(ResetTmp),
    .Out(MuxInATmp)
  );
  
  Mux #(.LENGTH(DEFAULT_LENGTH)) M2(
    .In(InB),
    .Zero(DEFAULT_ZERO),
    .Sel(ResetTmp),
    .Out(MuxInBTmp)
  );
  
  Mux #(.LENGTH(SMALL_LENGTH)) M3(
    .In(Sel),
    .Zero(SHORT_ZERO),
    .Sel(ResetTmp),
    .Out(MuxSelTmp)
  );
  
  // intern wires to transfer outputs from ALU
  wire 	[3:0] 	AluFlagTmp;
  wire 	[7:0]	AluOutTmp;
  
  ALU alu ( // initialize ALU module
    .A(MuxInATmp),
    .B(MuxInBTmp),
    .Sel(MuxSelTmp),
    .Flag(AluFlagTmp),
    .Out(AluOutTmp)
  );
  
  // intern wire to transfer Concatenator output 
  wire 	[31:0] ConcatOutTmp;
  
  concatenator concat( // initialize concatenator module
    .InA(MuxInATmp),
    .InB(MuxInBTmp),
    .InC(AluOutTmp),
    .InD(MuxSelTmp),
    .InE(AluFlagTmp),
    .Out(ConcatOutTmp)
  );
  
  // intern wires to deal with Controller
  wire CtrlTxDataTmp;
  wire CalcBusy;
  wire CtrlRWMemTmp;
  wire CtrlAccessMemTmp; 
  wire SampleDataWire;
  wire TxDataWire;
  
  assign Busy = CalcBusy;
  wire newRW;
  assign newRW = RWMem && CalcActive;
  
  Controller controller( // initialize Controller module
    .Clock(Clock),
    .Reset(Reset),
    .ValidCmd(ValidCmd),
    .InputKey(InputKey),
    .RW(newRW),
    .TxDone(CtrlTxDataTmp),
    .Active(ActiveWire),
    .Mode(CtrlModeTmp),
    .Busy(CalcBusy),
    .RWMem(CtrlRWMemTmp),
    .AccessMem(CtrlAccessMemTmp),
    .SampleData(SampleDataWire),
    .TxData(TxDataWire)
  );
  
 
  // intern wire to transfer Memory data output 
  wire	[31:0] OutMemory;
  
  memory #(.WIDTH(DEFAULT_LENGTH), .DinLENGTH(LARGE_LENGTH)) memory( // initialize memory module
    .Clock(Clock),
    .Reset(Reset),
    .Din(ConcatOutTmp),
    .Addr(Address),
    .Valid(CtrlAccessMemTmp),
    .R_W(CtrlRWMemTmp),
    .Dout(OutMemory)
  );
  
  // intern wire to transfer M4 Mux output 
  wire	[31:0] TxDinTmp;
  
  Mux #(.LENGTH(LARGE_LENGTH)) M4(	// initialize M4 Mux module
    .In(ConcatOutTmp),
    .Zero(OutMemory),
    .Sel(CtrlModeTmp),
    .Out(TxDinTmp)
  );
  
  
  SerialTransceiver #(.LENGTH(LARGE_LENGTH))
  serialTransceiver( // initialize SerialTransceiver module
  .Clock(Clock),
  .Reset(ResetTmp),
  .DataIn(TxDinTmp),
  .Sample(SampleDataWire),
  .StartTx(TxDataWire),
  .ClockTx(ClkTx),
  .TxDone(CtrlTxDataTmp),
  .TxBusy(DOutValid),
  .Dout(DataOut)
  );
  
  // intern wire to sent Correct Enable to Frequency divider, otherwise Frequency could never be changed
  wire CustomizedReset = ~(CalcActive || ConfigDiv) || Reset;
  
  FrequencyDivider frequencyDivider( // initialize Frequency Divider
    .Clock(Clock),
    .Reset(CustomizedReset),
    .Enable(ActiveWire),
    .ConfigDiv(ConfigDiv),
    .Din(Din),
    .ClockOut(ClkTx)
  );
  
endmodule




module BinaryCalculator_TB();
  
  reg 			Clock;
  reg			Reset;
  reg 			InputKey;
  reg			ValidCmd;
  reg 			RWMem;
  reg 	[7:0]	Address;
  reg 	[7:0] 	InA;
  reg 	[7:0] 	InB;
  reg 	[3:0] 	Sel;
  reg 			ConfigDiv;
  reg 	[31:0] 	Din;
  
  wire 			DOutValid;
  wire 			DataOut;
  wire 			ClkTx;
  wire			CalcActive;
  wire 			CalcMode;
  wire 			Busy;
  
  
  BinaryCalculator binaryCalculator(
    .Clock(Clock),
    .Reset(Reset),
    .InputKey(InputKey),
    .ValidCmd(ValidCmd),
    .RWMem(RWMem),
    .Address(Address),
    .InA(InA),
    .InB(InB),
    .Sel(Sel),
    .ConfigDiv(ConfigDiv),
    .Din(Din),
    .DOutValid(DOutValid),
    .DataOut(DataOut),
    .ClkTx(ClkTx),
    .CalcActive(CalcActive),
    .CalcMode(CalcMode),
    .Busy(Busy)
);
  
  
  
  initial begin
    #0 			Clock = 0;
    forever #5 	Clock = ~Clock;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #0		Reset 		= 1;
    #9 		Reset		= 0;
    		InA 		= 8'hf0;
    		InB 		= 8'hf1;
    		Sel 		= 8'h0;
    		ValidCmd 	= 1;
    		RWMem		= 0;
    		Address 	= 8'h0;
    		InputKey 	= 1;
    		Din			= 5;
    		ConfigDiv	= 1;
    		//Din		= 5;
    #10		InputKey 	= 0;
    		
    #10 	InputKey 	= 1;
    #10 	InputKey 	= 0;
    //#10		InputKey 	= 1;
    #100	InputKey	= 1;
    		ValidCmd 	= 0;
    		ConfigDiv	= 0;
    		//RWMem		= 1;
    #1500	InputKey	= 0;
    #1500
    #50 	ValidCmd	= 1;
   			Sel			= 8'h1;
    		//InputKey	= 0;
    #100 	InputKey	= 1;
    		//ValidCmd	= 0;
    #50 	ValidCmd	= 0;
    #3000
    
    #20 	InputKey	= 1;
    		ValidCmd	= 1;
    
    		RWMem		= 1;
    
    
    //		InputKey	= 1;
   //#500		ValidCmd	= 0;
    #100 	ValidCmd 	= 0;
    //		RWMem		= 0;
    	
    #500
    		ValidCmd	= 1;
    		RWMem		= 1;
    #100	ValidCmd	= 0;
    #3000
    
    
    #20		ValidCmd 	= 1;
    		RWMem		= 0;
    		InputKey	= 1;
    #100	ValidCmd	= 0;
    		RWMem		= 0;
    
    #3000
    
    #20		InputKey	= 0;
    		ValidCmd 	= 1;
    		InA			= 8'ha2;
    		InB			= 8'h1;
    		Sel			= 8'h2;
    		Address		= 8'h4;
    
    #100	//ValidCmd	= 0;
    		InputKey	= 1;
    #50		ValidCmd	= 0;
    #3000
    #20 	//InputKey	= 1;
    		ValidCmd	= 1;
    		RWMem		= 1;
    
    #100	ValidCmd	= 0;
    
    #3000
    #20		ValidCmd	= 1;
    		RWMem		= 0;
    #100	ValidCmd	= 0;
    
    #3000
    #20		ValidCmd	= 1;
    		Address		= 8'h0;
    #100	ValidCmd	= 0;
    
    #3000
    // scrieri succesive in memorie
    #20		InputKey	= 0;
    		ValidCmd 	= 1;
    		InA			= 8'h7;
    		InB			= 8'h2;
    		Sel			= 8'hC;
    		Address		= 8'h7;
    
    #100	//ValidCmd	= 0;
    		InputKey	= 1;
    #50		ValidCmd	= 0;
    #3000
    #20 	//InputKey	= 1;
    		ValidCmd	= 1;
    		RWMem		= 1;
    
    #100	ValidCmd	= 0;
    
    
    #3000
    
    #20 	
    		InA 		= 8'h19;
    		InB 		= 8'h5;
    		Sel			= 8'h3;
    		Address     = 8'h8;
    		ValidCmd	= 1;
    		RWMem		= 1;
    
    #100	ValidCmd	= 0;
    
    #3000
    
    #20 	
    		InA 		= 8'hA1;
    		InB 		= 8'h2;
    		Sel			= 8'h4;
    		Address     = 8'hA;
    		ValidCmd	= 1;
    		RWMem		= 1;
    
    #100	ValidCmd	= 0;
    
    #3000
    
    #20 	
    		InA 		= 8'hA1;
    		InB 		= 8'h3;
    		Sel			= 8'h6;
    		Address     = 8'hF;
    		ValidCmd	= 1;
    		RWMem		= 1;
    
    #100	ValidCmd	= 0;
    
    #3000
    
    #20 	
    		InA 		= 8'hA7;
    		InB 		= 8'h6;
    		Sel			= 8'hD;
    		Address     = 8'h10;
    		ValidCmd	= 1;
    		RWMem		= 1;
    
    #100	ValidCmd	= 0;
    
    // citiri succesive din memorie
    #3000
    #20		ValidCmd	= 1;
    		Address		= 8'h7;
    		RWMem		= 0;
    #100	ValidCmd	= 0;
    
    #3000
    #20		ValidCmd	= 1;
    		Address		= 8'h8;
    		RWMem		= 0;
    #100	ValidCmd	= 0;
    
    #3000
    #20		ValidCmd	= 1;
    		Address		= 8'hA;
    		RWMem		= 0;
    #100	ValidCmd	= 0;
    
    #3000
    #20		ValidCmd	= 1;
    		Address		= 8'hF;
    		RWMem		= 0;
    #100	ValidCmd	= 0;
    
    #3000
    #20		ValidCmd	= 1;
    		Address		= 8'h10;
    		RWMem		= 0;
    #100	ValidCmd	= 0;
    
    #5000 	$finish();
    
  end
  
endmodule