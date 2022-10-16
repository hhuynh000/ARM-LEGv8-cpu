`timescale 1ps/1ps
// a basic 3x8 decoder with a gate delay of 50ps
// params:
// inputs:
//			in: 3 bit input to select which output
//       enable: enable input
// output:
//       out: 8 bit output
module deco3x8(in, enable, out);
	input logic enable;
	input logic [2:0] in;
	output logic [7:0] out;

	logic not_a,not_b,not_c;

	not #(50) (not_a, in[0]);
	not #(50) (not_b, in[1]);
	not #(50) (not_c, in[2]);

	and #(50) (out[0], not_a, not_b , not_c, enable);
	and #(50) (out[1], in[0], not_b , not_c, enable);
	and #(50) (out[2], not_a, in[1] , not_c, enable);
	and #(50) (out[3], in[0], in[1] , not_c, enable);
	and #(50) (out[4], not_a, not_b , in[2], enable);
	and #(50) (out[5], in[0], not_b , in[2], enable);
	and #(50) (out[6], not_a, in[1] , in[2], enable);
	and #(50) (out[7], in[0], in[1] , in[2], enable);

endmodule 


module deco3x8_testbench();
	logic enable;
	logic [2:0] in;
	logic [7:0] out;
	
	deco3x8 dut (.in, .enable, .out);
	
	integer i;
		// test all in value when enalbe is on and off
	initial begin
		enable = 0; in = 3'b000;	#300;
		
		for(i=1; i<8; i++) begin
			in = i;						#300;
		end
		enable = 1; in = 3'b000;	#300;
		
		for(i=1; i<8; i++) begin
			in = i;						#300;
		end	
	end
	
endmodule

