`timescale 1ps/1ps
// a basic 2x4 decoder with a gate delay of 50ps
// params:
// inputs:
//			in: 2 bit input to select which output
//       enable: enable input
// output:
//       out: 4 bit output
module deco2x4(in,out,enable);

	input logic [1:0] in;
	input logic enable;
	output logic [3:0] out;

	logic not_a,not_b;

	not #(50) (not_a, in[0] );
	not #(50) (not_b, in[1] );

	and #(50) (out[0], not_a ,not_b, enable);
	and #(50) (out[1], in[0],not_b, enable);
	and #(50) (out[2], in[1],not_a, enable);
	and #(50) (out[3], in[0],in[1], enable);

endmodule 


module deco2x4_testbench();
	logic enable;
	logic [1:0] in;
	logic [3:0] out;
	
	deco2x4 dut (.in, .out, .enable);
	
	// test all in value when enable is on and off
	initial begin
		enable = 0; in = 2'b00;		#200;
		in = 2'b01;						#200;
		in = 2'b10;						#200;
		in = 2'b11;						#200;
		
		enable = 1; in = 2'b00;		#200;
		in = 2'b01;						#200;
		in = 2'b10;						#200;
		in = 2'b11;						#200;
											#200;
	end
endmodule

