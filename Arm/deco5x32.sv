`timescale 1ps/1ps
//5x32 decoder is implemented by cascading a 2x4 decoder and 4 3x8 decoders 
// params:
// inputs:
//			in: 5 bit input to select which output
//       enable: enable input
// output:
//       out: 32 bit output
module deco5x32(in, enable, out); 

	input logic [4:0] in;
	input logic enable;
	output logic [31:0] out;

	logic [3:0] temp;

	deco2x4 d0(.in({in[4],in[3]}), .enable, .out(temp[3:0]));
	deco3x8 d1(.in({in[2],in[1],in[0]}), .enable(temp[0]), .out(out[7:0]));
	deco3x8 d2(.in({in[2],in[1],in[0]}), .enable(temp[1]), .out(out[15:8]));
	deco3x8 d3(.in({in[2],in[1],in[0]}), .enable(temp[2]), .out(out[23:16]));
	deco3x8 d4(.in({in[2],in[1],in[0]}), .enable(temp[3]), .out(out[31:24]));

endmodule

module deco5x32_testbench();
	logic enable;
	logic [4:0] in;
	logic [31:0] out;
	
	deco5x32 dut (.in, .enable, .out);
	
	integer i;
	// test all in value when enalbe is on and off
	initial begin
		enable = 0; in = 5'b000;	#300;
		
		for(i=1; i<32; i++) begin
			in = i;						#300;
		end
		enable = 1; in = 5'b000;	#300;
		
		for(i=1; i<32; i++) begin
			in = i;						#300;
		end	
	end
	
endmodule 