`timescale 1ps/1ps
// A 1 bit ALU slice
//	sel			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
// otherwise:	result = 0						All values are unimportant
// Critical path is 650ps 
//	Inputs:
//			A: first operand
//       B: second operand
//       Cin: carry in
//			sel: 3 bit operations selection input
// Outputs:
//       Cout: carry out
//			R: result out
module ALU_slice(A, B, Cin, sel, Cout, R);
	input logic A, B, Cin;
	input logic [2:0] sel;
	output logic Cout, R;
	
	wire adderOut, andOut, xorOut, orOut, Bout, Bnot;
	
	// 2:1 mux to select subtract or add
	not #50 NOT (Bnot, B);
	mux2_1 MUX2_1 (.out(Bout), .i0(B), .i1(Bnot), .sel(sel[0])); // when s0 is true, subtract
	
	// Initilize fullAdder
	fullAdder fullAdd (.A, .B(Bout), .Cin, .Cout, .S(adderOut));
	
	and #50 AND (andOut, A, B);
	or #50 OR (orOut, A, B);
	xor #50 XOR (xorOut, A, B);
	
	// 8:1 mux to select add(010), subtract(011), and(100), or(101), xor(110)
	mux8_1 MUX8_1 (.out(R), .i({1'b0, xorOut, orOut, andOut, adderOut, adderOut, 1'b0, B}), .sel);
	
endmodule

module ALU_slice_testbench();
	logic A, B, Cin;
	logic [2:0] sel;
	logic Cout, R;
	
	ALU_slice dut (.A, .B, .Cin, .sel, .Cout, .R);
	// test all possible combination
	integer i;
	initial begin
		for (i=0; i<64; i++) begin
			{sel, A, B, Cin} = i;		#700;
		end
	end
endmodule

