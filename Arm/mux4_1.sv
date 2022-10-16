`timescale 1ps/1ps
// a basic 4:1 mux using 2 2:1 mux and a 2:1 mux
// critical path of 300ps
// params:
// inputs:
//			i: 4 bit input 
//       sel: 2 bit selection input
// output:
//       out: resulting output
module mux4_1(out, i, sel);
	input logic [1:0] sel;
	input logic [3:0] i;
	output logic out;
	
	logic w0, w1;
	
	mux2_1 m0 (.out(w0), .i0(i[0]), .i1(i[1]), .sel(sel[0]));
	mux2_1 m1 (.out(w1), .i0(i[2]), .i1(i[3]), .sel(sel[0]));
	mux2_1 m2 (.out, .i0(w0), .i1(w1), .sel(sel[1]));
	
endmodule

module mux4_1_testbench();
	logic [3:0] i;
	logic [1:0] sel;
	logic out;
	
	mux4_1 dut (.out, .i, .sel);
	
	integer k;
	initial begin
		// with gate delay of 50 ps
		// the new output from the 4x1mux has a delay of 300 ps
		for (k=0; k<64; k++) begin
			// test all possible combination of i and sel
			{sel, i} = k; #350;
		end
							  #350;
	end
endmodule

