`timescale 1ps/1ps
// Full Adder with gate delay of 50ps
// Critical path is 100ps 
//	Inputs:
//			A: first operand
//       B: second operand
//       Cin: carry in
// Outputs:
//       Cout: carry out
//			S: sum
module fullAdder(A, B, Cin, Cout, S);
	input logic A, B, Cin;
	output logic Cout, S;
	
	wire and1, and2, and3;
	
	xor #50 XOR (S, A, B, Cin);
	and #50 AND1 (and1, A, Cin);
	and #50 AND2 (and2, A, B);
	and #50 AND3 (and3, B, Cin);
	or #50 OR (Cout, and1, and2, and3);
	
endmodule

module fullAdder_testbench();
	logic A, B, Cin, Cout, S;
	
	fullAdder dut (.A, .B, .Cin, .Cout, .S);
	
	integer i;
	// test all input values {A,B,Cin}
	initial begin
		for (i=0; i<8; i++) begin
			{A, B, Cin} = i;		#150;
		end
	end
endmodule
