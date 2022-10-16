`timescale 1ps/1ps
// 32x64 bits registers with a write enable
// params:
// inputs:
//			clk: clock
//       wren: 32 bit write enable
//       D: 64 bits input
// output:
//       Q: 32x64 bits output
// Note: reset wire is not used in Lab 1
module reg_64x32 (clk, wren, D, Q);
	input logic clk;
	input logic [31:0] wren;
	input logic [63:0] D;
	output logic [31:0][63:0] Q;
	
	// generate 31 writable register
	genvar i;
	generate 
		for (i=0; i<31; i++) begin : eachREG
			reg_X #(.WIDTH(64)) REG (.clk, .wren(wren[i]), .D, .Q(Q[i][63:0]), .reset(1'b0));
		end
	endgenerate
	
	// X31 register with 0 value
	// can not be written to by outside input
	// always writing 0 to the register
	reg_X #(.WIDTH(64)) REG (.clk, .wren(1'b1), .D(64'b0), .Q(Q[31][63:0]), .reset(1'b0));
	
endmodule

module reg_64x32_testbench ();
	logic clk;
	logic [31:0] wren;
	logic [63:0] D;
	logic [31:0][63:0] Q;
	
	reg_64x32 dut (.clk, .wren, .D, .Q);
	
	// initialize clock with period 600ps
	// to avoid glitches due to mux which have a
	// critical path of 550ps
	parameter CLOCK_PERIOD = 600;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// test writing to X1 and X31
	// with value 2**32
	initial begin
		wren <= 0;	D <= 2**32;			@(posedge clk);
						repeat(4)   		@(posedge clk);
		wren[1] <= 1'b1;					@(posedge clk);
						repeat(4)   		@(posedge clk);
		wren[1] <= 1'b0;					@(posedge clk);
		wren[31] <= 1'b1;					@(posedge clk);
						repeat(4)   		@(posedge clk);
		$stop;
	end
endmodule
