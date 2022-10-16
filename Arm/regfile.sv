`timescale 1ps/1ps
// Register file with 32 64 bits registers
// 1 write port and 2 read ports
// params:
// inputs:
//			clk: clock
//       RegWrite: a write enable input for registers
// 		WriteRegister: 5 bit input specifying which register to write to
//       WriteData: 64 bit input value to be written into the register
//      	ReadRegister1: 5 bit input specifying which register to read from for the first read port
//       ReadRegister2: 5 bit input specifying which register to read from for the second read port
// output:
//       ReadData1: 64 bit output from the first read port
//			ReadData2: 64 bit output from the second read port
module regfile (ReadData1, ReadData2, WriteData, 
					 ReadRegister1, ReadRegister2, WriteRegister,
					 RegWrite, clk);
					 
	input logic	[4:0]	ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite, clk;
	output logic [63:0] ReadData1, ReadData2;
	
	logic [31:0] decode_out;
	logic [31:0][63:0] out;
	
	// initialize decoder
	deco5x32 decoder (.in(WriteRegister), .enable(RegWrite), .out(decode_out));
	
	// initialize 32x64bits registers
	reg_64x32 REG (.clk, .wren(decode_out), .D(WriteData), .Q(out));
	
	// initialize 2 64xmux32:1
	mux64x32_1 MUX1 (.out(ReadData1), .i(out), .sel(ReadRegister1));
	mux64x32_1 MUX2 (.out(ReadData2), .i(out), .sel(ReadRegister2));
	
endmodule

// simulation testbench in regstim.sv