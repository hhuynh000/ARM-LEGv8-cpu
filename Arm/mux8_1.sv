`timescale 1ps/1ps
// a basic 8:1 mux using 2 4:1 mux and a 2:1 mux
// critical path of 450ps
// params:
// inputs:
//			i: 8 bit input 
//       sel: 3 bit selection input
// output:
//       out: resulting output
module mux8_1(out, i, sel);
	input logic [7:0] i;
	input logic [2:0] sel;
	output logic out;
	
	logic w0, w1;
	
	mux4_1 m0 (.out(w0), .i(i[3:0]), .sel(sel[1:0]));
	mux4_1 m1 (.out(w1), .i(i[7:4]), .sel(sel[1:0]));
	mux2_1 m2 (.out, .i0(w0), .i1(w1), .sel(sel[2]));
	
endmodule

module mux8_1_testbench();
	logic [7:0] i;
	logic [2:0] sel;
	logic out;
	
	mux8_1 dut (.out, .i, .sel);
	
	integer k;
	initial begin
		// with gate delay of 50 ps
		// the new output from the 8x1mux has a delay of 450 ps
		// test all possible combination of i and sel
		for (k=0; k<2048; k++) begin
			{sel, i} = k; #500;
		end
							  #500;
	end
	
endmodule
