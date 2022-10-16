//`timescale 1ns/10ps
`timescale 1ps/1ps
// top-level testbench for cpu
module cpusim ();
	logic clk, reset;
	
	parameter CLOCK_PERIOD = 7400;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	cpu dut (.clk, .reset);
	// change benchmark file in instrumem to test all cases
	initial begin
		reset <= 1'b1; 	@(posedge clk);
		reset <= 1'b0;		@(posedge clk);
			repeat(1500)	   @(posedge clk); // sort benchmark take a long time 700 cycles	(~2min)
														 // CRC-16 benchmark take a long time 1500 cycles (~5min)
			
		$stop;
	end
endmodule
