`timescale 1ps/1ps
// 16 bit nor
// input:
//			in: 16 bit input value
//	output:
// 		out: nor output value
// critical path of 100ps
module nor16(in, out);
	input logic [15:0] in;
	output logic out;
	
	wire wire1, wire2, wire3, wire4;
	
	nor #50 NOR1 (wire1, in[3], in[2], in[1], in[0]);
	nor #50 NOR2 (wire2, in[7], in[6], in[5], in[4]);
	nor #50 NOR3 (wire3, in[11], in[10], in[9], in[8]);
	nor #50 NOR4 (wire4, in[15], in[14], in[13], in[12]);
	and #50 AND (out, wire1, wire2, wire3, wire4);
	
endmodule

module nor16_testbench();
	logic [15:0] in;
	logic out;
	
	nor16 dut (.in, .out);
	
	// test when in 0, 2^16 and some in between value
	initial begin
		in = 16'b0;							#150;
		in = 16'b1;							#150;
		in = 16'b0101010101010101;		#150;
		in = 16'b0111011100010011;		#150;
	end
endmodule
