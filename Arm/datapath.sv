`timescale 1ps/1ps
// pipelined cpu datapath
// inputs:
//			clk: clock for data memory 
//			flag_negative, flag_zero, flag_overflow: Alu output flag
//			Rd, Rn, Rm: dest reg, operand 1 reg, operand 2 reg 5 bit address
//			Imm9/12: immediate value with 9/12 bit respectively
//			Shamt: 6 bit shift amount
//			Reg2Loc: choosing Rd or Rm for Ab (regfile)
//			AluSrc: chosing Db or Imm value into ALU
//			MemToReg: Choose to have mem data to reg write data
//			readMem: Mem read enable (not necessary but typical memory requires a read enable)
//			RegWrite: regfile write enable
//			MemWrite: Mem write enable
//			ImmSize: choose the ImmSize to go into ALU
// 		flags: enable new value for flag regisiter
// 		AluOp: 3bit signal determine ALU operation
//			shift: choose to shift instead of Alu (ALu and LSR are in parallel)
// outputs:
//			negative, zero, overflow, carry_out: flags output from the ALU
//			CBZero: accelarated branch zero test		
module datapath (Rd, Rn, Rm, Imm9, Imm12, Reg2Loc, AluSrc, MemToReg, RegWrite,
						MemWrite, AluOp, ImmSize, Shamt, shift, negative, 
						zero, overflow, carry_out, readMem, CBZero, clk);

	input logic [11:0] Imm12;
	input logic [8:0] Imm9;
	input logic [5:0] Shamt; 
	input logic [4:0] Rd, Rn, Rm;
	input logic Reg2Loc, AluSrc, MemToReg, RegWrite, MemWrite, 
					ImmSize, shift, clk, readMem;
	input logic [2:0] AluOp;
	output logic negative, zero, overflow, carry_out, CBZero;
	
	wire[5:0] ShamtReg;
	wire [4:0] Reg2LocOut, Aw, RdReg, RdReg1;
	wire [63:0] Da, Db, Imm9SE, Imm12ZE, ImmSizeOut, AluSrcOut, AluOut, read_data, 
					MemToRegOut, LSROut, ExcOut, DaReg, DbReg, ExcOutReg, ImmSizeOutReg,
					DbReg1, Dw, sourceOut1, sourceOut2;
	wire [2:0] AluOpReg;
	wire AluNegative, AluZero, AluOverflow, AluCarry_out;
	wire clkNot, RegWriteReg, AluSrcReg, shiftReg, MemWriteReg, MemToRegReg, readMemReg,
			MemWriteReg1, MemToRegReg1, readMemReg1, RegWriteReg1, RegWriteReg2;
	wire [1:0] ALU1_sel, ALU2_sel; // fowarding unit controls signal for output to ALU/Excution stage
	
	// Register Fetch
	// 	Reg2Loc Mux
	mux2_1X #(.WIDTH(5)) Reg2LocMUX (.out(Reg2LocOut), .i0(Rd), .i1(Rm), .sel(Reg2Loc));
	// 	regfile
	// 	invert clock on register file 
	not #50 NOT (clkNot, clk);
	regfile REGFILE (.ReadData1(Da), .ReadData2(Db), .WriteData(Dw), 
					 .ReadRegister1(Rn), .ReadRegister2(Reg2LocOut), .WriteRegister(Aw),
					 .RegWrite(RegWriteReg2), .clk(clkNot));
					 
	// ForwardingUnit datapath
	
	ForwardingUnit FU (.MEM_Write(MemWriteReg), .WB_Write(RegWriteReg1), .Exc_Write(RegWriteReg), 
							.MEM_WriteReg(RdReg), .WB_WriteReg(RdReg1), .source_reg_1(Rn), .source_reg_2(Reg2LocOut), 
							.ALU1_sel, .ALU2_sel);
	
	// source 1 mux
	// i = {Mem Data value [3], WB value [2], Reg value at Mem [1], original value [0]}
	mux4_1_64 source1MUX (.out(sourceOut1), .i({DbReg, MemToRegOut, ExcOut, Da}), .sel(ALU1_sel));
	
	// source 2 mux
	// i = {Mem Data value [3], WB value [2], Reg value at Mem [1], original value [0]}
	mux4_1_64 source2MUX (.out(sourceOut2), .i({DbReg, MemToRegOut, ExcOut, Db}), .sel(ALU2_sel));
	
	// zero test for CBZ accerlated branch with new zero value (CBZero) from forwarding
	// Rd will always be from Db(source2)
	nor64 NOR64 (.in(sourceOut2), .out(CBZero));
	
	// Sign extend Imm9 and zero extend Im12
	SE #(.WIDTH(9)) IMM9_SE (.Imm(Imm9), .out(Imm9SE));
	ZE #(.WIDTH(12)) IMM12_ZE (.Imm(Imm12), .out(Imm12ZE));
	
	// ImmSize Mux
	mux2_1X #(.WIDTH(64)) ImmSizeMUX (.out(ImmSizeOut), .i0(Imm9SE), .i1(Imm12ZE), .sel(ImmSize));
	
	// ******************************************************************************
	// Register Fetch -> Execution Registers
	// 	Da
	reg_X #(.WIDTH(64)) reg_Da (.clk, .wren(1'b1), .D(sourceOut1), .Q(DaReg), .reset(1'b0));
	// 	Db
	reg_X #(.WIDTH(64)) reg_Db (.clk, .wren(1'b1), .D(sourceOut2), .Q(DbReg), .reset(1'b0));
	//		Controls signal Reg 
	D_FF reg_AluSrc (.q(AluSrcReg), .d(AluSrc), .reset(1'b0), .clk);
	//		AluOp
	reg_X #(.WIDTH(3)) reg_AluOp (.clk, .wren(1'b1), .D(AluOp), .Q(AluOpReg), .reset(1'b0));
	//		shift
	D_FF reg_shift (.q(shiftReg), .d(shift), .reset(1'b0), .clk);
	//		MemWrite
	D_FF reg_MemWrite (.q(MemWriteReg), .d(MemWrite), .reset(1'b0), .clk);
	//		MemToReg
	D_FF reg_MemToReg (.q(MemToRegReg), .d(MemToReg), .reset(1'b0), .clk);
	// 	readMem
	D_FF reg_readMem (.q(readMemReg), .d(readMem), .reset(1'b0), .clk);
	// 	RegWrite
	D_FF reg_RegWrite (.q(RegWriteReg), .d(RegWrite), .reset(1'b0), .clk);
	// 	Shamt
	reg_X #(.WIDTH(6)) reg_Shamt (.clk, .wren(1'b1), .D(Shamt), .Q(ShamtReg), .reset(1'b0));
	// ImmSizeOut: immediate value computed in Reg Fetch  (Imm9 or Imm12)
	reg_X #(.WIDTH(64)) reg_ImmSizeOut (.clk, .wren(1'b1), .D(ImmSizeOut), .Q(ImmSizeOutReg), .reset(1'b0));
	// 	Rd
	reg_X #(.WIDTH(5)) reg_Rd (.clk, .wren(1'b1), .D(Rd), .Q(RdReg), .reset(1'b0));
	
	// Execute
	// 	AluSrc Mux
	mux2_1X #(.WIDTH(64)) AluSrcMUX (.out(AluSrcOut), .i0(DbReg), .i1(ImmSizeOutReg), .sel(AluSrcReg));
	// 	ALU
	alu ALU (.A(DaReg), .B(AluSrcOut), .cntrl(AluOpReg), .result(AluOut), .negative,
				.zero, .overflow, .carry_out);						 
	// 	logical Right Shifter
	LSR_64 lsr64 (.in(DaReg), .Shamt(ShamtReg), .out(LSROut));
	// 	Shift Mux
	mux2_1X #(.WIDTH(64)) ShiftMUX (.out(ExcOut), .i0(AluOut), .i1(LSROut), .sel(shiftReg));
	
	// ******************************************************************************
	// Execution -> MEM Register
	//		output of ALU or Shifter
	reg_X #(.WIDTH(64)) reg_ExuOut (.clk, .wren(1'b1), .D(ExcOut), .Q(ExcOutReg), .reset(1'b0));
	// 	Db
	reg_X #(.WIDTH(64)) reg_Db1 (.clk, .wren(1'b1), .D(DbReg), .Q(DbReg1), .reset(1'b0));
	//		MemWrite
	D_FF reg_MemWrite1 (.q(MemWriteReg1), .d(MemWriteReg), .reset(1'b0), .clk);
	//    MemToReg
	D_FF reg_MemToReg1 (.q(MemToRegReg1), .d(MemToRegReg), .reset(1'b0), .clk);
	//		readMem
	D_FF reg_readMem1 (.q(readMemReg1), .d(readMemReg), .reset(1'b0), .clk);
	// 	RegWrite
	D_FF reg_RegWrite1 (.q(RegWriteReg1), .d(RegWriteReg), .reset(1'b0), .clk);
	//		Rd
	reg_X #(.WIDTH(5)) reg_Rd1 (.clk, .wren(1'b1), .D(RdReg), .Q(RdReg1), .reset(1'b0));
	
	// MEM 
	// 	data memory
	datamem DATA (.address(ExcOutReg), .write_enable(MemWriteReg1), .read_enable(readMemReg1), .write_data(DbReg1),
				.clk, .xfer_size(4'b1000), .read_data);		
	// 	MemToReg Mux
	mux2_1X #(.WIDTH(64)) MemToRegMUX (.out(MemToRegOut), .i0(ExcOutReg), .i1(read_data), .sel(MemToRegReg1));
	
	// ******************************************************************************
	// MEM -> WriteBack register
	//		MemToReg
	reg_X #(.WIDTH(64)) reg_Dw (.clk, .wren(1'b1), .D(MemToRegOut), .Q(Dw), .reset(1'b0));
	//		Rd
	reg_X #(.WIDTH(5)) reg_Aw (.clk, .wren(1'b1), .D(RdReg1), .Q(Aw), .reset(1'b0));
	//		RegWrite
	D_FF reg_RegWrite2 (.q(RegWriteReg2), .d(RegWriteReg1), .reset(1'b0), .clk);
	
endmodule

module datapath_testbench ();
	logic [11:0] Imm12;
	logic [8:0] Imm9;
	logic [5:0] Shamt; 
	logic [4:0] Rd, Rn, Rm;
	logic Reg2Loc, AluSrc, MemToReg, RegWrite, MemWrite, 
			ImmSize, shift, readMem, clk;
	logic [2:0] AluOp;
	logic negative, zero, overflow, carry_out, CBZero;
	
	// initialize cock
	parameter CLOCK_PERIOD = 5000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	datapath dut (.Rd, .Rn, .Rm, .Imm9, .Imm12, .Reg2Loc, .AluSrc, .MemToReg, .RegWrite,
						.MemWrite, .AluOp, .ImmSize, .Shamt, .readMem,
						.shift, .negative, .zero, .overflow, .carry_out, .CBZero, .clk);
	
	// testing if value are all displaying correctly
	// hard to test without any instructions
	initial begin
		Reg2Loc <= 1'b0;
		AluSrc <= 1'b0; MemToReg <= 1'b0;
		RegWrite <= 1'b0; MemWrite <= 1'b0;
		ImmSize <= 1'b0; readMem <= 1'b0;
		shift <= 1'b0; Imm9 <= 19'd2;
		Rd <= 5'd1; Rn = 5'd2;
		Rm <= 5'd31; Shamt <= 6'd2;
		Imm12 <= 26'd3; AluOp <= 3'b010;			@(posedge clk);

															@(posedge clk);

		$stop;
	end
endmodule
