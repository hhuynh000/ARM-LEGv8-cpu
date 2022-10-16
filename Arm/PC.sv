`timescale 1ps/1ps
// program counter data path
// inputs:
//			clk: clock for instruction memory and PC 
//			reset: reset PC back to 0
// 		Imm19/26: immediate value with 19/26 bit respectively
//			BrTaken: adjust PC for branch
//			UncondBr: choose if unconditional Branch
// outputs:
//			instr: 32 bit instruction
module PC (UncondBr, BrTaken, Imm19, Imm26, clk, reset, instr);

	input logic [18:0] Imm19;
	input logic [25:0] Imm26;
	input logic UncondBr, BrTaken, reset, clk;
	output logic [31:0] instr;

	wire [63:0] PC_Addr, AddOut, AddBrOut, Imm19_SE, Imm26_SE, UncondBrOut,
					BrTakenOut, UncondBrOutx4;
	wire[63:0] PC_AddrReg, PC_AddrNext;
	wire[31:0] instrOut;
	// Instruction Fetch
	// 	always writing new value
	reg_X #(.WIDTH(64)) reg_PC (.clk, .wren(1'b1), .D(BrTakenOut), .Q(PC_Addr), .reset);
	// 	instruction memory
	instructmem INSTRMEM (.address(PC_Addr), .instruction(instrOut), .clk);
	// 	PC = PC + 4
	fullAdder_64 ADD (.A(PC_Addr), .B(64'd4), .result(AddOut));
	// 	BrTaken Mux
	mux2_1X #(.WIDTH(64)) BrTakenMUX (.out(BrTakenOut), .i0(AddOut), .i1(AddBrOut), .sel(BrTaken));
	
	// Instruction Fetch -> Register Fetch Register: 
	// 	instruction register 
	reg_X #(.WIDTH(32)) reg_Instr(.clk, .wren(1'b1), .D(instrOut), .Q(instr), .reset(1'b0));
	// 	PC reg to Register Fetch stage
	reg_X #(.WIDTH(64)) reg_Addr (.clk, .wren(1'b1), .D(PC_Addr), .Q(PC_AddrReg), .reset);
	
	// Register Fetch
	// 	CondAddr19 -> sign extention
	SE #(.WIDTH(19)) IMM19SE (.Imm(Imm19), .out(Imm19_SE));
	// 	CondAddr26 -> sign extention
	SE #(.WIDTH(26)) IMM26SE (.Imm(Imm26), .out(Imm26_SE));
	// 	UncodnBr Mux
	mux2_1X #(.WIDTH(64)) UncondBrMUX (.out(UncondBrOut), .i0(Imm19_SE), .i1(Imm26_SE), .sel(UncondBr));
	// 	<<2 multiply by 4
	LSL lsl (.in(UncondBrOut), .out(UncondBrOutx4));
	// 	PC = PC + SE(Imm) << 2
	fullAdder_64 ADDBR (.A(UncondBrOutx4), .B(PC_AddrReg), .result(AddBrOut));
	
	
endmodule

module PC_testbench ();
	logic [18:0] Imm19;
	logic [25:0] Imm26;
	logic UncondBr, BrTaken, reset, clk;
	logic [31:0] instr;
	
	// initialize cock
	parameter CLOCK_PERIOD = 2000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	PC dut (.UncondBr, .BrTaken, .Imm19, .Imm26, .clk, .reset, .instr);
	
	initial begin
		reset <= 1'b1; UncondBr <= 1'b0;
		BrTaken <= 1'b0; Imm19 <= 19'd2;			
		Imm26 <= 26'd3;								@(posedge clk);
		// PC = 0 (instruction 1)
		reset <= 1'b0;									@(posedge clk);
		// test PC = PC + 4
		// PC = 4 (instruction 2)
		
		// test PC = PC + SE(ConAddr19) <<2
		// PC = 4 + 2*4 = 12 	(instruction 4)
		BrTaken <= 1'b1; UncondBr <= 1'b0;		@(posedge clk);
															
		// test PC = PC + SE(ConAddr26) <<2
		// PC = 12 + 3*4 = 24 (instruction 7)
		BrTaken <= 1'b1; UncondBr <= 1'b1;		@(posedge clk);
															@(posedge clk);
		$stop;
	end
endmodule
