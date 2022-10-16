`timescale 1ps/1ps
// single cycle cpu *note does not synthesis
// 32 bit instruction based on ARM architecture
// operations
// ADDI Rd, Rn, Imm12: Reg[Rd] = Reg[Rn] + ZeroExtend(Imm12).
// ADDS Rd, Rn, Rm: Reg[Rd] = Reg[Rn] + Reg[Rm]. Set flags.
// AND Rd, Rn, Rm: Reg[Rd] = Reg[Rn] & Reg[Rm].
// B Imm26: PC = PC + SignExtend(Imm26 << 2).
// B.LT Imm19: If (flags.negative != flags.overflow) PC = PC + SignExtend(Imm19<<2).
// CBZ Rd, Imm19: If (Reg[Rd] == 0) PC = PC + SignExtend(Imm19<<2).
// EOR Rd, Rn, Rm: Reg[Rd] = Reg[Rn] ^ Reg[Rm].
// LDUR Rd, [Rn, #Imm9]: Reg[Rd] = Mem[Reg[Rn] + SignExtend(Imm9)].
// LSR Rd, Rn, Shamt: Reg[Rd] = Reg[Rn] >> Shamt
// STUR Rd, [Rn, #Imm9]: Mem[Reg[Rn] + SignExtend(Imm9)] = Reg[Rd].
// SUBS Rd, Rn, Rm: Reg[Rd] = Reg[Rn] - Reg[Rm]. Set flags.
// inputs:
//			clk: clock
//			reset: reset cpu
module cpu (clk, reset);
	input logic clk, reset;
	
	wire [4:0] Rd, Rn, Rm;
	wire [31:0] instr;
	wire flag_negative, flag_zero, flag_overflow, flag_carry_out,
			negative, zero, overflow, carry_out, overflowOut;
	wire Reg2Loc, AluSrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr,
			ImmSize, flags, shift, readMem, CBZero, flagsReg, negativeOut;
	wire [2:0] AluOp;
	wire [5:0] Shamt;
	wire [8:0] Imm9;
	wire [11:0] Imm12;
	wire [18:0] Imm19;
	wire [25:0] Imm26;
	
	// controls
	// zero input is connected directly from ALU instead of Flags reg for cbz
	cpu_controls CONTROLS (.instr, .Rd, .Rn, .Rm, .flag_negative(negativeOut), .flag_zero(zero), .flag_overflow(overflowOut), 
							.Imm9, .Imm12, .Imm19, .Imm26, .Shamt, .Reg2Loc, .AluSrc, .MemToReg, .readMem,
							.RegWrite, .MemWrite, .BrTaken, .UncondBr, .ImmSize, .flags, .AluOp, .shift, .CBZero);
							
	// Mux to determine to slowly branch(value from flags Reg) or quickly branch(value from ALU) based on flags control signal						
	mux2_1 negativeMUX (.out(negativeOut), .i0(flag_negative), .i1(negative), .sel(flagsReg));
	mux2_1 overflowMUX (.out(overflowOut), .i0(flag_overflow), .i1(overflow), .sel(flagsReg));
	
	// datapath
	datapath DATAPATH (.Rd, .Rn, .Rm, .Imm9, .Imm12, .Reg2Loc, .AluSrc, .MemToReg, .RegWrite,
						.MemWrite, .AluOp, .ImmSize, .Shamt, .shift, .negative, .zero, 
						.overflow, .carry_out, .readMem, .CBZero, .clk);
	// PC
	PC pc (.UncondBr, .BrTaken, .Imm19, .Imm26, .clk, .reset, .instr);
	
	
	// Register Fetch -> Execution Registers
	//	flag control signal
	D_FF reg_Flags (.q(flagsReg), .d(flags), .reset(1'b0), .clk);
	
	// Excution
	// 4bit flags regisiter with order
	// reset to 0
	// {negative, zero, overflow, carry_out}
	reg_X #(.WIDTH(4)) FLAGS (.clk, .wren(flagsReg), .D({negative, zero, overflow, carry_out}), 
									.Q({flag_negative, flag_zero, flag_overflow, flag_carry_out}), .reset);
									
endmodule
