`timescale 1ps/1ps
// modular register with WIDTH bit and a write enable
// and a reset to 0
// parameter WIDTH size of register
// inputs:
//			clk: clock
//       wren: write enable
//       D: WIDTH bits input
//       reset: reset to 0 signal 
// output:
//       Q: WIDTH bits output
// Note: reset wire is not used in Lab 1
module reg_X #(parameter WIDTH=64) (clk, wren, D, Q, reset);
	input logic clk, wren, reset;
	input logic [WIDTH-1:0] D; 
	output logic [WIDTH-1:0] Q;
	
	// generate WIDTH D_FF to make one WIDTH bits register
	genvar i;
	generate
		for (i=0; i<WIDTH; i++) begin : eachDFF
			D_FF_en DFFs (.Q(Q[i]), .D(D[i]), .wren, .clk, .reset);
		end
	endgenerate
	
			
endmodule

module reg_X_testbench ();
	parameter WIDTH = 64;
	logic [WIDTH-1:0] Q, D;
	logic wren, clk;
	
	reg_X dut (.clk, .wren, .D, .Q);
	
	// initialize clock
	// in order to avoid glitches from 2:1 mux
	// with critical path of 150ps
	parameter CLOCK_PERIOD = 200;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// test wren where input has the 32nd bit turned on
	initial begin
		wren <= 0;	D <= 2**32;		@(posedge clk);
						repeat(4)   	@(posedge clk);
		wren <= 1;						@(posedge clk);
						repeat(4)   	@(posedge clk);
		$stop;
	end
endmodule
