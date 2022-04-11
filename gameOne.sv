module gameOne( input logic clk, reset_n
				output logic [19:0] bits, 
				output logic flag );
	
	logic [19:0] stateBits;
	logic state;
	logic [4:0] randnum;
	
	always_ff@(posedge clk, negedge reset_n) begin
		if (~reset_n) begin
			bits <= 20'b11111100001000011111; //7-segs: 1st:off, 2nd:-, 3rd:-, 4th:off
			flag <= 0;
		end
		
		else begin
			bits <= stateBits;
		end
	end
	
	always_comb begin

	end

endmodule