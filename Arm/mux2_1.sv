`timescale 1ps/1ps
// a basic 2:1 mux with a gate delay of 50ps
// critical path of 150 ps
// params:
// inputs:
//			i0: the first input (correspond to sel=0)
//       i1: the second input (correspond to sel=1)
//       sel: selection input
// output:
//       out: resulting output
module mux2_1(out, i0, i1, sel);
	output logic out;
	input logic i0, i1, sel;
	logic andOut1, andOut2, selNot;
	
	not #50 NOT (selNot, sel);
	and #50 AND1 (andOut1, i1, sel);
	and #50 AND2 (andOut2, i0, selNot);
	or #50 OR (out, andOut1, andOut2);

endmodule

module mux2_1_testbench();
	logic i0, i1, sel;
	logic out;
	mux2_1 dut (.out, .i0, .i1, .sel);
	// with gate delay of 50 ps
	// the new output from the mux has a max delay of 150 ps
   // test all combination of sel,i0 and i1	
	initial begin
		sel=0; i0=0; i1=0; #200;
		sel=0; i0=0; i1=1; #200;
		sel=0; i0=1; i1=0; #200;
		sel=0; i0=1; i1=1; #200;
		sel=1; i0=0; i1=0; #200;
		sel=1; i0=0; i1=1; #200;
		sel=1; i0=1; i1=0; #200;
		sel=1; i0=1; i1=1; #200;
	end
endmodule
