`timescale 1ps/1ps
// simple 64 bit adder
// inputs:
//			A: 64 bit first operand
//			B: 64 bit second operand
// outputs:
//			result: 64 bit sum output
module fullAdder_64 (A, B, result);
	input logic [63:0] A, B;
	output logic [63:0] result;
	
	// wire carry in/out between each 1 bit fullAdder
	wire [63:0] Cio;
	
	// Cin 0, only support addition
	fullAdder ADDER1 (.A(A[0]), .B(B[0]), .Cin(1'b0), .Cout(Cio[0]), .S(result[0]));
	
	genvar i;
	generate
		for (i=1; i<64; i++) begin : eachADDER
			fullAdder ADDER (.A(A[i]), .B(B[i]), .Cin(Cio[i-1]), .Cout(Cio[i]), .S(result[i]));
		end
	endgenerate
	
endmodule

module fullAdder_64_testbench ();
	logic [63:0] A, B, result;
	parameter delay = 100000;
	logic [63:0] test_val_A,test_val_B, result_val;
	
	fullAdder_64 dut (.A, .B, .result);
	
	integer i;
	initial begin
	
		$display("testing addition");
		
		// add 1+1
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002);
		
		// add 0 + 0
		test_val_A = 64'd0; test_val_B = 64'd0;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A + test_val_B));
		// add -1 + -1
		test_val_A = (2 ** 64) - 1; test_val_B = (2 ** 64) - 1 ;
		A = test_val_A; B = test_val_B;
		#(delay); 
		
		// add 2^63 + 2^(63) overflow
		test_val_A = 64'h7fffffffffffffff; test_val_B = 64'h7fffffffffffffff;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A + test_val_B  )); 
		
		// test random
		for (i=0; i<100; i++) begin
			test_val_A = $random(); test_val_B = $random();
			A = test_val_A; B = test_val_B;
			#(delay);
			result_val = A + B;
			assert(result == result_val);  
		end
	end
	
endmodule
