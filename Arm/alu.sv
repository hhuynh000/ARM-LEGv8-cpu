`timescale 1ps/1ps
// A 64 bit ALU that support operations:
//	cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
// otherwise:	result = 0						All values are unimportant
// Critical path is 650ps 
//	Inputs:
//			A: 64 bit first operand
//       B: 64 bit second operand
//			cntrl: 3 bit operations selection input
// Outputs:
//       carry_out: carry out value from the significant bit adder
//       negative: if the result is a negative value
//       zero: if the result is zero
// 		overflow: if the adder result overflow and the result is invalid
//       result: 64 bit output value 
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	output logic negative, zero, overflow, carry_out;
	output logic [63:0] result;
	
	// wire carry in/out between each ALU slice
	wire [63:0] Cio;
	
	// Cin for the first ALU is cntrl[0] which is on when subtract operation
	ALU_slice ALU0 (.A(A[0]), .B(B[0]), .Cin(cntrl[0]), .sel(cntrl), .Cout(Cio[0]), .R(result[0]));
	
	genvar i;
	generate
		for (i=1; i<64; i++) begin : eachALU
			ALU_slice ALU (.A(A[i]), .B(B[i]), .Cin(Cio[i-1]), .sel(cntrl), .Cout(Cio[i]), .R(result[i]));
		end
	endgenerate
	
	// wire flags
	assign negative = result[63];
	xor #50 XOR (overflow, Cio[63], Cio[62]);
	assign carry_out = Cio[63];
	nor64 NOR (.in(result), .out(zero));
	
endmodule
