// FowardingUnit for 5 stages pipelined cpu
// fix data hazard between RAW and WAR
// inputs:
// 		 MEM_Write: MemWrite signal right before Excu to Mem Reg
// 		 WB_Write: RegWrite signal right before Mem to WB Reg
// 		 Exc_Write: RegWrite signal right before Excu to Mem Reg
// 		 MEM_WriteReg: Register address right before Excu to Mem Reg
// 		 WB_WriteReg: Register address right before Mem to WB Reg
//			 source_reg_1: address A from the register file
//			 source_reg_2: address B from the register file
// outputs:
//			 ALU1_sel: control signal for the first source output (Da)
//			 ALU2_sel: control signal for the second source output (Db)
module ForwardingUnit(MEM_Write, WB_Write, Exc_Write, MEM_WriteReg,
							 WB_WriteReg, source_reg_1, source_reg_2, ALU1_sel, ALU2_sel);

input logic MEM_Write, WB_Write, Exc_Write;
input logic [4:0] MEM_WriteReg, WB_WriteReg, source_reg_1, source_reg_2;
output logic [1:0] ALU1_sel, ALU2_sel;

// sel 2'b00 original value
// sel 2'b01 alu/shift at MEM value (before the Excution to Mem register)
// sel 2'b10 WB value
// sel 2'b11 Mem Data value

always_comb begin
	// MEM/Exc take priority because it is the most recent value
	if ((MEM_Write || Exc_Write) && source_reg_1 == MEM_WriteReg && MEM_WriteReg != 5'b11111) begin
		if (MEM_Write) begin
			ALU1_sel = 2'b11; // Forward the source 1 value from the Mem Data at stage Mem
		end else begin
			ALU1_sel = 2'b01; // Forward the source 1 value from alu/shift at stage Mem
		end
		
		if ((MEM_Write || Exc_Write) && source_reg_2 == MEM_WriteReg && MEM_WriteReg != 5'b11111) begin
		
			if (MEM_Write) begin	// new value from MEM data take priority since MEM_Write only on for STUR
				ALU2_sel = 2'b11; // Forward the source 2 value from the Mem Data at stage Mem
			end else begin
				ALU2_sel = 2'b01; // Forward the source 2 value from alu/shift at stage Mem
			end
			
		end else if (WB_Write && source_reg_2 == WB_WriteReg && WB_WriteReg != 5'b11111) begin
			ALU2_sel = 2'b10; // Forward the source 2 value at WB stage
		end else begin
			ALU2_sel = 2'b00; // if source 2 reg is X31/ no write/ no match
		end
		
	end else if (WB_Write && source_reg_1 == WB_WriteReg && WB_WriteReg != 5'b11111) begin
		ALU1_sel = 2'b10;  // Forward the source 1 value at WB stage
		
		if ((MEM_Write || Exc_Write) && source_reg_2 == MEM_WriteReg && MEM_WriteReg != 5'b11111) begin
		
			if (MEM_Write) begin
				ALU2_sel = 2'b11; // Forward the source 2 value from the Mem Data at stage Mem
			end else begin
				ALU2_sel = 2'b01; // Forward the source 2 value from alu/shift at stage Mem
			end
			
		end else if (WB_Write && source_reg_2 == WB_WriteReg && WB_WriteReg != 5'b11111) begin
			ALU2_sel = 2'b10; // Forward the source 2 value at WB stage
		end else begin
			ALU2_sel = 2'b00; // if source 2 reg is X31/ no write/ no match
		end
		
	end else begin
		ALU1_sel = 2'b00;		// if source 1 reg is X31/ no write/ no match
		
		if ((MEM_Write || Exc_Write) && source_reg_2 == MEM_WriteReg && MEM_WriteReg != 5'b11111) begin
		
			if (MEM_Write) begin
				ALU2_sel = 2'b11; // Forward the source 2 value from the Mem Data at stage Mem
			end else begin
				ALU2_sel = 2'b01; // Forward the source 2 value from alu/shift at stage Mem
			end
			
		end else if (WB_Write && source_reg_2 == WB_WriteReg && WB_WriteReg != 5'b11111) begin
			ALU2_sel = 2'b10; // Forward the source 2 value at WB stage
		end else begin
			ALU2_sel = 2'b00; // if source 2 reg is X31/ no write/ no match
		end
		
	end
end
	
endmodule

module ForwardingUnit_testbench();
	logic MEM_Write, WB_Write, Exc_Write;
	logic [4:0] MEM_WriteReg, WB_WriteReg, source_reg_1, source_reg_2;
	logic [1:0] ALU1_sel, ALU2_sel;
	
	ForwardingUnit dut (.MEM_Write, .WB_Write, .Exc_Write, .MEM_WriteReg,
							 .WB_WriteReg, .source_reg_1, .source_reg_2, .ALU1_sel, .ALU2_sel);
							 
	initial begin
		// both source reg get fowarded from WB
		WB_Write = 1'b1; MEM_Write = 1'b0;
		Exc_Write = 1'b0;
		MEM_WriteReg = 5'b00000; WB_WriteReg = 5'b00001;
		source_reg_1 = 5'b00001; source_reg_2 = 5'b00001;		#10;
		
		// source 1 reg get fowarded from WB
		WB_Write = 1'b1; MEM_Write = 1'b0;
		Exc_Write = 1'b0;
		MEM_WriteReg = 5'b00000; WB_WriteReg = 5'b00001;
		source_reg_1 = 5'b00001; source_reg_2 = 5'b00011;		#10;
		
		// source 2 reg get fowarded from WB
		WB_Write = 1'b1; MEM_Write = 1'b0;
		Exc_Write = 1'b0;
		MEM_WriteReg = 5'b00000; WB_WriteReg = 5'b00001;
		source_reg_1 = 5'b00000; source_reg_2 = 5'b00001;		#10;
		
		// both source reg get fowarded from MEM
		WB_Write = 1'b0; MEM_Write = 1'b1;
		Exc_Write = 1'b0;
		MEM_WriteReg = 5'b00000; WB_WriteReg = 5'b00001;
		source_reg_1 = 5'b00000; source_reg_2 = 5'b00000;		#10;
		
		// source 1 reg get fowarded from MEM
		WB_Write = 1'b0; MEM_Write = 1'b1;
		Exc_Write = 1'b0;
		MEM_WriteReg = 5'b00000; WB_WriteReg = 5'b00001;
		source_reg_1 = 5'b00000; source_reg_2 = 5'b00011;		#10;
		
		// source 2 reg get fowarded from MEM
		WB_Write = 1'b0; MEM_Write = 1'b1;
		Exc_Write = 1'b0;
		MEM_WriteReg = 5'b00000; WB_WriteReg = 5'b00001;
		source_reg_1 = 5'b00001; source_reg_2 = 5'b00000;		#10;
		
		// no source get fowarded X31
		// both source reg get fowarded from WB
		WB_Write = 1'b1; MEM_Write = 1'b1;
		Exc_Write = 1'b1;
		MEM_WriteReg = 5'b11111; WB_WriteReg = 5'b11111;
		source_reg_1 = 5'b11111; source_reg_2 = 5'b11111;		#10;
		
		// no reg match
		WB_Write = 1'b1; MEM_Write = 1'b1;
		Exc_Write = 1'b1;
		MEM_WriteReg = 5'b10111; WB_WriteReg = 5'b11100;
		source_reg_1 = 5'b10011; source_reg_2 = 5'b00111;		#10;
		
		// no write on
		WB_Write = 1'b0; MEM_Write = 1'b0;
		Exc_Write = 1'b0;
		MEM_WriteReg = 5'b00000; WB_WriteReg = 5'b00001;
		source_reg_1 = 5'b00000; source_reg_2 = 5'b00001;		#10;
	end
endmodule
