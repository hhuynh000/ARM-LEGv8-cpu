`timescale 1ps/1ps
// 64 bit nor build from 4 16 bit nor and one AND
// input:
//			in: 64 bit input value
//	output:
// 		out: nor output value
// critical path of 150ps
module nor64(in, out);
	input logic [63:0] in;
	output logic out;
	
	wire wire1, wire2, wire3, wire4;
	
	nor16 NOR1 (.in(in[15:0]), .out(wire1));
	nor16 NOR2 (.in(in[31:16]), .out(wire2));
	nor16 NOR3 (.in(in[47:32]), .out(wire3));
	nor16 NOR4 (.in(in[63:48]), .out(wire4));
	and #50 AND (out, wire1, wire2, wire3, wire4);
	
endmodule

module nor64_testbench();
	logic [63:0] in;
	logic out;
	
	nor64 dut (.in, .out);
	
	// test when in 0, 2^16 and some in between value
	initial begin
		in = 64'b0;													#200;
		in = 64'b1;													#200;
		in = 64'b01010101010101010101010101010101;		#200;
		in = 64'b01110111000100110111011100010011;		#200;
	end
endmodule

