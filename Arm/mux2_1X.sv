`timescale 1ps/1ps
// WIDTH bit 2:1 mux module use to control datapath
// parameter WIDTH determine the I/O of 2:1 mux
// critical path 150ps
// inputs:
//			i: WIDTH bit input 
//       sel: 1 bit selection input
// output:
//       out: WIDTH bit output
module mux2_1X #(parameter WIDTH=64) (out, i0, i1, sel);
	input logic [WIDTH-1:0] i0, i1;	
	input logic sel;
	output logic [WIDTH-1:0] out;
	
	// generate WIDTH 2:1mux 
	genvar y;	
	generate
		for (y=0; y<WIDTH; y++) begin : eachMux
			mux2_1 MUX (.out(out[y]), .i0(i0[y]), .i1(i1[y]), .sel);

		end
	endgenerate
	
	
endmodule

module mux2_1X_testbench();
	parameter WIDTH = 64;
	logic [WIDTH:0] i0, i1, out;
	logic sel;
	
	mux2_1X #(.WIDTH(64)) dut (.out, .i0, .i1, .sel);
	
	// test selecting i0 and i1 value
	initial begin
		i0 = 64'd4; i1 = 64'd64;
		sel = 1'b0;							#200;
		sel = 1'b1;							#200;
	end
endmodule
