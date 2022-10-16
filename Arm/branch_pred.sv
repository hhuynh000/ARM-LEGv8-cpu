module branch_pred (clk, reset, guess, branch, en);
	input logic clk, reset, branch, en;
	output logic guess;
	
	// at (always true), st (sometime true)
	// sf (sometine false), af (always false)
	enum {at=3, st=2, sf=1, af=0} ps, ns;
	
	always_comb begin
		case(ps)
					at: begin
						if (branch)
							ns = at;
						else
							ns = st;
					end
					
					st: begin
						if (branch)
							ns = at;
						else
							ns = sf;
					end
					
					sf: begin
						if (branch)
							ns = st;
						else
							ns = af;
					end
					
					af: begin
						if (branch)
							ns = sf;
						else
							ns = af;
					end
		endcase		
	end
	
	// start at sometime true
	always_ff @(posedge clk) begin 
		if (reset)
			ps <= st;
		else
			ps <= ns;
	end
	
	// at and st -> 11 and 10 guess branch if ps[1] = 1
	assign guess = ps[1];
	
endmodule

module branch_pred_testbench ();
	logic clk, reset, branch, guess;
	
	branch_pred dut (.clk, .reset, .guess, .branch);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		reset <= 1;	branch <= 0;
		en <= 0; 								@(posedge clk);
		reset <= 0;								@(posedge clk);
									repeat(5)	@(posedge clk);		// state states sometime true
		en <= 0;									@(posedge clk);							
									repeat(5)	@(posedge clk);		// state -> always false
		branch <= 1;							@(posedge clk);		// state -> always true
									repeat(5)	@(posedge clk);
		
		$stop;
	end
endmodule
