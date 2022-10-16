// Pipelined Cpu controls
// inputs:
//			instr: 32bit instruction
//			flag_negative/zero/overflow: flags from alu
//			CBZero: zero test for accelerated branch
// outputs:
//			Rd, Rn, Rm: dest reg, operand 1 reg, operand 2 reg 5 bit address
//			Imm9/12/19/26: immediate value with 9/12/19/26 bit respectively
//			Shamt: 6 bit shift amount
//			Reg2Loc: choosing Rd or Rm for Ab (regfile)
//			AluSrc: chosing Db or Imm value into ALU
//			MemToReg: Choose to have mem data to reg write data
//			readMem: Mem read enable
//			RegWrite: regfile write enable
//			MemWrite: Mem write enable
//			BrTaken: adjust PC for branch
//			UncondBr: choose if unconditional Branch
//			ImmSize: choose the ImmSize to go into ALU
// 		flags: enable new value for flag regisiter
// 		AluOp: 3bit signal determine ALU operation
//			shift: choose to shift instead of Alu (ALu and LSR are in parallel)
module cpu_controls (instr, Rd, Rn, Rm, flag_negative, flag_zero, flag_overflow, 
							Imm9, Imm12, Imm19, Imm26, Shamt, Reg2Loc, AluSrc, MemToReg, readMem,
							RegWrite, MemWrite, BrTaken, UncondBr, ImmSize, flags, AluOp, shift, CBZero);
	input logic [31:0] instr;
	input logic flag_negative, flag_zero, flag_overflow, CBZero;
	output logic [25:0] Imm26;
	output logic [11:0] Imm12;
	output logic [18:0] Imm19;
	output logic [8:0] Imm9;
	output logic [5:0] Shamt; 
	output logic [4:0] Rd, Rn, Rm;
	output logic Reg2Loc, AluSrc, MemToReg, RegWrite, MemWrite, BrTaken,
					 UncondBr, ImmSize, flags, shift, readMem;
	output logic [2:0] AluOp;
	always_comb begin
		case (instr[31:21])
			// ADDI IMM12 Rn Rd
			{10'b1001000100,instr[21]}: begin
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = instr[21:10];
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = 'X;
					Shamt = 'X;
					Reg2Loc = 'X;
					AluSrc = 1'b1;
					MemToReg = 1'b0;
					RegWrite = 1'b1;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b010;	// ADD
					ImmSize = 1'b1;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b0;
			end
		
			// ADDS Rd Rn Rm flags
			11'b10101011000: begin 
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = instr[20:16];
					Shamt = 'X;
					Reg2Loc = 1'b1;
					AluSrc = 1'b0;
					MemToReg = 1'b0;
					RegWrite = 1'b1;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b010;	// ADD
					ImmSize = 'X;
					flags = 1'b1;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
				// AND Rd Rn Rm
			11'b10001010000: begin
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = instr[20:16];
					Shamt = 'X;
					Reg2Loc = 1'b1;
					AluSrc = 1'b0;
					MemToReg = 1'b0;
					RegWrite = 1'b1;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b100;	// AND
					ImmSize = 'X;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
				// B Imm26
			{6'b000101, instr[25:21]}: begin
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = instr[25:0];
					Imm12 = 'X;
					Rn = 'X;
					Rd = 'X;
					Rm = 'X;
					Shamt = 'X;
					Reg2Loc = 'X;
					AluSrc = 'X;
					MemToReg = 'X;
					RegWrite = 1'b0;
					MemWrite = 1'b0;
					BrTaken = 1'b1;
					UncondBr = 1'b1;
					AluOp = 'X;	
					ImmSize = 'X;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
				// B.LT Imm19
			{8'b01010100, instr[23:21]}: begin
					Imm9 = 'X;
					Imm19 = instr[23:5];
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = 'X;
					Rd = 'X;
					Rm = 'X;
					Shamt = 'X;
					Reg2Loc = 'X;
					AluSrc = 'X;
					MemToReg = 'X;
					RegWrite = 1'b0;
					MemWrite = 1'b0;
					if(flag_negative != flag_overflow) begin
						BrTaken = 1'b1;
					end else begin
						BrTaken = 1'b0;
					end
					UncondBr = 1'b0;
					AluOp = 'X;	
					ImmSize = 'X;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
				// CBZ Rd Imm19
			{8'b10110100, instr[23:21]}: begin 
					Imm9 = 'X;
					Imm19 = instr[23:5];
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = 'X;
					Rd = instr[4:0];
					Rm = 'X;
					Shamt = 'X;
					Reg2Loc = 1'b0;
					AluSrc = 1'b0;
					MemToReg = 'X;
					RegWrite = 1'b0;
					MemWrite = 1'b0;
					BrTaken = CBZero;
					UncondBr = 1'b0;
					AluOp = 3'b000;	// By-pass B
					ImmSize = 'X;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
				// EOR Rd Rn Rm
			11'b11001010000: begin
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = instr[20:16];
					Shamt = 'X;
					Reg2Loc = 1'b1;
					AluSrc = 1'b0;
					MemToReg = 1'b0;
					RegWrite = 1'b1;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b110;	// XOR
					ImmSize = 'X;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
				// LDUR Rd, [Rn, #Imm9]
			11'b11111000010: begin
					Imm9 = instr[20:12];
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = 'X;
					Shamt = 'X;
					Reg2Loc = 'X;
					AluSrc = 1'b1;
					MemToReg = 1'b1;
					RegWrite = 1'b1;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b010;	// ADD
					ImmSize = 1'b0;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b1;
			end
			
				// LSR Rd, Rn, Shamt
			11'b11010011010: begin
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = 5'b000000;
					Shamt = instr[15:10];
					Reg2Loc = 1'bX;
					AluSrc = 1'bX;
					MemToReg = 1'b0;
					RegWrite = 1'b1;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b010;	// ADD
					ImmSize = 'X;
					flags = 1'b0;
					shift = 1'b1;
					readMem = 1'b0;
			end
			
				// STUR Rd, [Rn, #Imm9]
			11'b11111000000: begin
					Imm9 = instr[20:12];
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = 'X;
					Shamt = 'X;
					Reg2Loc = 1'b0;
					AluSrc = 1'b1;
					MemToReg = 'X;
					RegWrite = 1'b0;
					MemWrite = 1'b1;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b010;	// ADD
					ImmSize = 1'b0;
					flags = 1'b0;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
			// SUBS Rd Rn Rm flags
			11'b11101011000: begin
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = instr[9:5];
					Rd = instr[4:0];
					Rm = instr[20:16];
					Shamt = 'X;
					Reg2Loc = 1'b1;
					AluSrc = 1'b0;
					MemToReg = 1'b0;
					RegWrite = 1'b1;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 3'b011;	// SUB
					ImmSize = 'X;
					flags = 1'b1;
					shift = 1'b0;
					readMem = 1'b0;
			end
			
			// Invalid instruction
			// will not write to Mem or Reg
			// or set flags, still increment PC
			default: begin
					Imm9 = 'X;
					Imm19 = 'X;
					Imm26 = 'X;
					Imm12 = 'X;
					Rn = 'X;
					Rd = 'X;
					Rm = 'X;
					Shamt = 'X;
					Reg2Loc = 'X;
					AluSrc = 'X;
					MemToReg = 'X;
					RegWrite = 1'b0;
					MemWrite = 1'b0;
					BrTaken = 1'b0;
					UncondBr = 'X;
					AluOp = 'X;	
					ImmSize = 'X;
					flags = 1'b0;
					shift = 'X;
					readMem = 1'b0;
			end
		endcase
	end
endmodule

module cpu_controls_testbench();
	logic [31:0] instr;
	logic flag_negative, flag_zero, flag_overflow;
	logic [25:0] Imm26;
	logic [11:0] Imm12;
	logic [18:0] Imm19;
	logic [8:0] Imm9;
	logic [5:0] Shamt; 
	logic [4:0] Rd, Rn, Rm;
	logic Reg2Loc, AluSrc, MemToReg, RegWrite, MemWrite, BrTaken,
					 UncondBr, ImmSize, flags, shift, readMem;
	logic [2:0] AluOp;
	
	cpu_controls dut (.instr, .Rd, .Rn, .Rm, .flag_negative, .flag_zero, .flag_overflow, 
							.Imm9, .Imm12, .Imm19, .Imm26, .Shamt, .Reg2Loc, .AluSrc, .MemToReg, .readMem,
							.RegWrite, .MemWrite, .BrTaken, .UncondBr, .ImmSize, .flags, .AluOp, .shift);
	initial begin
		flag_negative = 1'b0; flag_zero = 1'b0;
		flag_overflow = 1'b0;										#100;
		// ADDI X4 X1 #24 
		instr = 32'b10010001000000000110000000100100;		#100;
		
		// ADDS X0 X2 X5
		instr = 32'b10101011000001010000000001000000;		#100;
		
		// AND X8 X2 X1
		instr = 32'b10001010000000010000000001001000;		#100;
		
		// B #32
		instr = 32'b00010100000000000000000000100000;      #100;
		
		// B.LT #16 When LT is not true
		instr = 32'b01010100000000000000001000001011;		#100;
		
		flag_negative = 1'b1; flag_overflow = 1'b0;			#100;
		// B.LT #16 When LT is true
		instr = 32'b01010100000000000000001000001011;		#100;
		
		// CBZ X1 #2 When not true
		instr = 32'b10110100000000000000000001000001;		#100;
		
		flag_negative = 1'b0; flag_zero = 1'b1;
		flag_overflow = 1'b0;										#100;
		// CBZ X1 #2 When true
		instr = 32'b10110100000000000000000001000001;		#100;
		
		// EOR x3 x1 x0
		instr = 32'b11001010000000000000000000100011;		#100;
		
		// LDUR X31 [X1,#0]
		instr = 32'b11111000010000000000000000011111;		#100;
		
		// LSR X2 X4 #2
		instr = 32'b11010011010000000000100010000010;		#100;
		
		// STUR x4 [X2, #4]
		instr = 32'b11111000000000000100000001000100;		#100;
		
		// SUBS X5 X1 X31
		instr = 32'b10101011000111110000000000100101;		#100;
		
		// Invalid
		instr = 32'b11111111111111111111111111111111;		#100;
	end
endmodule

