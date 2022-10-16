// modular zero extension with parameter WIDTH = size of Imm
// input:
//			Imm: Immediate vaue with WIDTH bit
// output:
//			out: 64 bit output
module ZE #(parameter WIDTH=9)(Imm, out);
	input logic [WIDTH-1:0] Imm;
	output logic [63:0] out;
	logic [63-WIDTH:0] fill;
	
	// assign fill with 0
	assign fill = '0;

	assign out = {fill,Imm};

endmodule

module ZE_testbench ();
	parameter WIDTH = 9;
	logic [WIDTH-1:0] Imm;
	logic [63:0] out;

	
	ZE #(.WIDTH(WIDTH)) dut (.Imm, .out);
	
	// test 9 bit Imm sign extension
	initial begin
		Imm = 9'b111000111;		#200;
	end
	
endmodule
