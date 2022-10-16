// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val_A,test_val_B, result_val;
	initial begin
	
		$display("%t testing PASS_A operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		
		cntrl = ALU_ADD;
		// add 1+1
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		// add 0 + 0
		test_val_A = 64'd0; test_val_B = 64'd0;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A + test_val_B  ) && carry_out == 0 && overflow == 0 && negative == 0 && zero == 1 ); 
		
		// add -1 + -1
		test_val_A = (2 ** 64) - 1; test_val_B = (2 ** 64) - 1 ;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A + test_val_B  ) && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0 ); 
		
		// add 2^63 + 2^(63) overflow
		test_val_A = 64'h7fffffffffffffff; test_val_B = 64'h7fffffffffffffff;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A + test_val_B  ) && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0 ); 
		
		// test random
		for (i=0; i<100; i++) begin
			test_val_A = $random(); test_val_B = $random();
			A = test_val_A; B = test_val_B;
			#(delay);
			result_val = A + B;
			assert(result == result_val && zero == (result_val == 0 && negative == result_val[63]) && overflow == ((~result_val[63]&test_val_A[63]&test_val_B[63])|
																((result_val[63]&(~test_val_A[63])&(~test_val_B[63])))) && carry_out == (test_val_A[63]&test_val_B[63]) |
																( (test_val_A[63]^test_val_B[63])&(~result_val[63]) ));  
		end
		
		
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		A = 64'd87329379; B = 64'd6216312;
		#(delay);
		assert(result == 64'd81113067 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);
		
		// test 256 - 16
		test_val_A = 64'h00000000000000ff; test_val_B = 64'h000000000000000f;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A - test_val_B  ) && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0 );
		
		// test 0 - 0
		test_val_A = 64'h0000000000000000; test_val_B = 64'h0000000000000000;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A - test_val_B  ) && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1 );
		
		// test -1 - -1
		test_val_A = (2 ** 64) - 1; test_val_B = (2 ** 64) - 1 ;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A - test_val_B  ) && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1 );
		
		// test -2 - 2^63 overflow
		test_val_A = 64'hffffffffffffffffe; test_val_B = 64'h7fffffffffffffff;
		A = test_val_A; B = test_val_B;
		#(delay);
		assert(result == ( test_val_A - test_val_B  ) && carry_out == 1 && overflow == 1 && negative == 0 && zero == 0 ); 
		
		// test random
		for (i=0; i<100; i++) begin
			test_val_A = $random(); test_val_B = $random();
			A = test_val_A; B = test_val_B;
			#(delay);
			result_val = A - B;
			assert(result == result_val && zero == (result_val == 0 && negative == result_val[63]) && overflow == ((~result_val[63]&test_val_A[63]&(~test_val_B[63]))|
																((result_val[63]&(~test_val_A[63])&(test_val_B[63])))) && carry_out == (test_val_A[63]&(~test_val_B[63])) |
																( (test_val_A[63]^(~test_val_B[63]))&(~result_val[63]) ));  
		end
		
	
		$display("%t testing bitwise A & B operations", $time); 
		cntrl = ALU_AND;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			result_val = A & B;
			assert(result == result_val );  //negative and zero not important
		end

		
		$display("%t testing bitwise A | B operations", $time);
		cntrl = ALU_OR;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == A | B );  //negative and zero not important
		end
		
		$display("%t testing bitwise A XOR B operations", $time);
		cntrl = ALU_XOR;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == A ^ B );  //negative and zero not important
		end
		
		
	end
endmodule
