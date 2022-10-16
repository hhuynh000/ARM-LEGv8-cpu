`timescale 1ps/1ps
// DFF with an enable to write to the DFF
// using a 2:1 mux fo wren 
// Note: reset wire is not used in Lab 1
// params:
// inputs:
//			D: input
//       wren: enable input
//			clk: clock
//			reset: reset to 0 signal
// output:
//       Q: output
module D_FF_en (Q, D, wren, clk, reset);
	output logic Q;
	input logic D, wren, clk, reset;
	logic temp;	// output from mux either new input D
					// out old output Q from DFF

	// is wren is on then the input D will be fed to the DFF else
	// the previous value Q is fed back into the DFF
	mux2_1 MUX (.out(temp), .i0(Q), .i1(D), .sel(wren));
	
	// reset remain off state since Lab 1 does not use reset
	D_FF DFFs (.q(Q), .d(temp), .reset, .clk);		
			
endmodule

module D_FF_en_testbench ();
	logic Q, D, wren, clk;
	
	D_FF_en dut (.Q, .D, .wren, .clk);
	
	// initialize clock with period 200
	// in order to avoid glitches from 2:1 mux
	// with critical path of 150ps
	parameter CLOCK_PERIOD = 200;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// test wren 
	initial begin
		wren <= 0;	D <= 1;		@(posedge clk);
						repeat(4)   @(posedge clk);
		wren <= 1;					@(posedge clk);
						repeat(4)   @(posedge clk);
		$stop;
	end
endmodule

