`timescale 1ps/1ps
// a basic 32:1 mux using 2 16:1 mux and a 2:1 mux
// params:
// inputs:
//			i: 32 bit input 
//       sel: 5 bit selection input
// output:
//       out: resulting output
module mux32_1(out, i, sel);
	input logic [31:0] i;
	input logic [4:0] sel;
	output logic out;
	
	logic w0, w1;
	
	mux16_1 m0 (.out(w0), .i(i[15:0]), .sel(sel[3:0]));
	mux16_1 m1 (.out(w1), .i(i[31:16]), .sel(sel[3:0]));
	mux2_1 m2 (.out, .i0(w0), .i1(w1), .sel(sel[4]));
	
endmodule

module mux32_1_testbench();
	logic [31:0] i;
	logic [4:0] sel;
	logic out;
	
	mux32_1 dut (.out, .i, .sel);
	
	integer k;
	integer j;
	initial begin
		// with gate delay of 50 ps
		// the new output from the 32x1mux has a max delay of 550 ps
		// test all sel value for each digit place in the input (i)
		// there are glitches due to gate delay
		for (k=0; k<32; k++) begin
			i = 2**k; sel = 0;	#550;
			for (j=1; j<32; j++) begin
				sel = j; 			#550;
			end
										#550;
		end
	end
endmodule
