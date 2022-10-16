`timescale 1ps/1ps
// modular left  shifter by 2 preforming x4
// only wires
// inputs:
//			in: 64 bit input
//	output:
//			out: 64 bit shifted output
module LSL (in, out);
	input logic [63:0] in;
	output logic [63:0] out;
	
	integer i;
	always_comb begin
		for (i=63; i>1; i--) begin : eachComp
			out[i] = in[i-2];
		end
		
		out[0] = 1'b0;
		out[1] = 1'b0;
	end
	
endmodule

module LSL_testbench ();

	logic [63:0] in, out;
	
	LSL dut (.in, .out);
	
	// try left shift by 2 for in=1
	initial begin

		in = 64'b1;			#200;
								#200;
	end
endmodule

