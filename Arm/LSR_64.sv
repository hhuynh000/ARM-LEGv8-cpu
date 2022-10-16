`timescale 1ps/1ps
// 64 bit right shifter
// inputs:
//			in: 64 bit input
//			shift: 6 bit signal to shift 
//	output:
//			out: 64 bit shifted output
module LSR_64 (in, Shamt, out);
	input logic  [63:0] in;
	input logic [5:0] Shamt;
	output logic [63:0] out;
	wire [63:0] shiftOut [4:0];
	
	// first shifter by 1
	LSR #(.SHIFT(1)) lsr1 (.in, .shift(Shamt[0]), .out(shiftOut[0]));
	LSR #(.SHIFT(2)) lsr2 (.in(shiftOut[0]), .shift(Shamt[1]), .out(shiftOut[1]));
	LSR #(.SHIFT(4)) lsr4 (.in(shiftOut[1]), .shift(Shamt[2]), .out(shiftOut[2]));
	LSR #(.SHIFT(8)) lsr8 (.in(shiftOut[2]), .shift(Shamt[3]), .out(shiftOut[3]));
	LSR #(.SHIFT(16)) lsr16 (.in(shiftOut[3]), .shift(Shamt[4]), .out(shiftOut[4]));
	LSR #(.SHIFT(32)) lsr32 (.in(shiftOut[4]), .shift(Shamt[5]), .out);
endmodule

module LSR_64_testbench ();
	logic [63:0] in, out;
	logic [5:0] Shamt;
	
	LSR_64 dut (.in, .Shamt, .out);
	
	// shift in=111.. by 1, 7, 63
	initial begin
		in = '1;
		Shamt = 6'b000001;		#5000;
		Shamt = 6'b000111;		#5000;
		Shamt = 6'b111111;		#5000;
	end
endmodule
