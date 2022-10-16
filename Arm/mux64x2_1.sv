`timescale 1ps/1ps
// 64 2:1 mux module use to control datapath
// critical path 150ps
// inputs:
//			i: 64 bit input 
//       sel: 1 bit selection input
// output:
//       out: 64 bit output
module mux64x2_1(out, i0, i1, sel);
	input logic [63:0] i0, i1;	
	input logic sel;
	output logic [63:0] out;
	
	// generate 64 32:1mux and assign 64 x 32 bit wire (w)
	genvar y;	
	generate
		for (y=0; y<64; y++) begin : eachMux
			mux2_1 MUX (.out(out[y]), .i0(i0[y]), .i1(i1[y]), .sel);

		end
	endgenerate
	
	
endmodule

module mux64x2_1_testbench();
	logic [63:0] i0, i1, out;
	logic sel;
	
	mux64x2_1 dut (.out, .i0, .i1, .sel);
	
	// test selecting i0 and i1 value
	initial begin
		i0 = 64'd4; i1 = 64'd64;
		sel = 1'b0;							#200;
		sel = 1'b1;							#200;
	end
endmodule
