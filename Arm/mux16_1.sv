`timescale 1ps/1ps
// a basic 16:1 mux using 2 8:1 mux and a 2:1 mux
// params:
// inputs:
//			i: 16 bit input 
//       sel: 4 bit selection input
// output:
//       out: resulting output
module mux16_1(out, i, sel);
	input logic [15:0] i;
	input logic [3:0] sel;
	output logic out;
	
	logic w0, w1;
	
	mux8_1 m0 (.out(w0), .i(i[7:0]), .sel(sel[2:0]));
	mux8_1 m1 (.out(w1), .i(i[15:8]), .sel(sel[2:0]));
	mux2_1 m2 (.out, .i0(w0), .i1(w1), .sel(sel[3]));
	
endmodule

module mux16_1_testbench();
	logic [15:0] i;
	logic [3:0] sel;
	logic out;
	
	mux16_1 dut (.out, .i, .sel);
	
	integer k;
	integer j;
	initial begin
		// with gate delay of 50 ps
		// the new output from the 16x1mux has a delay of 450 ps
		// test all sel value for each bit place in the input (i)
		// there are glitches due to gate delay
		for (k=0; k<16; k++) begin
			i = 2**k; sel = 0;	#550;
			for (j=1; j<16; j++) begin
				sel = j; 			#550;
			end
										#550;
		end
	end
endmodule
