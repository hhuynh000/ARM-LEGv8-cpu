`timescale 1ps/1ps
// modular right shifter with parameter SHIFT
// determine how much to shift (1,2,4,8,16,32) for 64 bit
// inputs:
//			in: 64 bit input
//			shift: 1 bit signal to shift or not
//	output:
//			out: 64 bit shifted output
module LSR #(parameter SHIFT=1) (in, shift, out);
	input logic [63:0] in;
	input logic shift;
	output logic [63:0] out;
	
	// update lower bit to SHIFT amount of bit higher
	genvar i;
	generate
		for (i=0; i<(64-SHIFT); i++) begin : eachComp
			mux2_1 MUX (.out(out[i]), .i0(in[i]), .i1(in[i+SHIFT]), .sel(shift));
		end
	endgenerate
	
	// SHIFT amount of upper bit value update to 0 if shift
	generate
		for (i=0; i<SHIFT; i++) begin : eachMux
			mux2_1 MUXTOP (.out(out[63-i]), .i0(in[63-i]), .i1(1'b0), .sel(shift));
		end
	endgenerate
	
endmodule

module LSR_testbench ();
	logic [63:0] in, out;
	logic shift;
	
	LSR #(.SHIFT(32)) dut (.in, .shift, .out);
	
	// try shift by 32 for in=1111...
	initial begin
		shift = 1'b0; 
		in = '1;		#200;
		shift = 1'b1;		#200;
								#200;
	end
endmodule

