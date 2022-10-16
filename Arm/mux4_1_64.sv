`timescale 1ps/1ps
// a basic 64 bit 4:1 mux using 2 64 bit 2:1 mux and a 64 bit 2:1 mux
// critical path of 300ps
// params:
// inputs:
//			i: 4x 64 bit input 
//       sel: 2 bit selection input
// output:
//       out: 64 bit resulting output
module mux4_1_64(out, i, sel);
	input logic [1:0] sel;
	input logic [63:0] i [3:0] ;
	output logic [63:0] out;
	
	logic [63:0] w0, w1;
	
	mux2_1X #(.WIDTH(64)) m0 (.out(w0), .i0(i[0]), .i1(i[1]), .sel(sel[0]));
	mux2_1X #(.WIDTH(64)) m1 (.out(w1), .i0(i[2]), .i1(i[3]), .sel(sel[0]));
	mux2_1X #(.WIDTH(64)) m2 (.out, .i0(w0), .i1(w1), .sel(sel[1]));
	
endmodule

module mux4_1_64_testbench();
	logic [63:0] i [3:0];
	logic [1:0] sel;
	logic [63:0] out;
	
	mux4_1_64 dut (.out, .i, .sel);
	
	integer k;
	initial begin
		// with gate delay of 50 ps
		// the new output from the 4x1mux has a delay of 300 ps
		i[0] = 64'd5;	i[1] = 64'd2;
		i[2] = 64'd10; i[3] = 64'd20;			#350;
		for (k=0; k<4; k++) begin
			// test all possible combination of sel
			sel = k; 		#350;
		end
								#350;
	end
endmodule
