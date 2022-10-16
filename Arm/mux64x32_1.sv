`timescale 1ps/1ps
// 64 32:1 mux module use to control read output from 32 regisiters
// each bit of the 64 bit registers correspond to one bit input of
// the 32:1 mux, repeat for all 64 bit
// inputs:
//			i: 32 elements of 64 bit value correspond to 32 64 bit regsisters
//       sel: 5 bit selection input, determine which register to read from
// output:
//       out: 64 bit resulting output correspond to the value of one of the
//            regisiter output 
module mux64x32_1(out, i, sel);
	input logic [31:0][63:0] i;	// array of 32 elements of width 64 bit (registers)
	input logic [4:0] sel;
	output logic [63:0] out;
	logic [63:0][31:0] w;			// wire of 64 elements of width 32 bit
	integer k, j;
	
	// arange wire
	// swap the input dimensions [31:0][63:0]
	// to [63:0][31:0] so that there are 64 32 bits value
	// where each element's 32 bits value represent one bit 
	// out of the total 64 bit from all of the 32 registers
	// e.g: w[0][31:0] contains the first bit of all the 32 registers
	always_comb begin
		for (k=0; k<64; k++) begin
			for (j=0; j<32; j++) begin
				w[k][j] = i[j][k];
			end
		end
	end

	
	// generate 64 32:1mux and assign 64 x 32 bit wire (w)
	genvar y;	
	generate
		for (y=0; y<64; y++) begin : eachMux
			mux32_1 MUX (.out(out[y]), .i(w[y][31:0]), .sel);

		end
	endgenerate
	
	
endmodule

module mux64x32_1_testbench();
	logic [31:0][63:0] i;
	logic [4:0] sel;
	logic [63:0] out;
	
	mux64x32_1 dut (.out, .i, .sel);
	
	integer k;
	integer j;
	initial begin
		// with gate delay of 50 ps
		// the new output from the 32x1mux has a max delay of 550 ps
		// there are glitches due to gate delay
		// initalize all registers with value correspond to its number (0-31)
		// test all sel value and see corresponding output
		for (k=0; k<32; k++) begin
			i[k] = k; 	#10;
		end
		for (k=0; k<32; k++) begin
			sel = k;		#550;
		end
			repeat(100)				#550;
	end
endmodule
