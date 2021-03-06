module gameOne( input logic clk, enable, reset_n,
				output logic [19:0] bits, 
				output logic victoryflag,
				input logic [2:0] gameCounter );
	
	logic [19:0] stateBits;

	always_ff@(posedge clk) begin
		if (~reset_n || ~enable) begin
			bits <= 20'b11111100001000011111; //7-segs: 1st:off, 2nd:-, 3rd:-, 4th:off
			victoryflag <= 0;
		end
		else begin
			bits <= stateBits;
			if (gameCounter >= 7)//
				victoryflag <= 1;
			else
				victoryflag <= 0;
		end
	end
	
	always_comb begin
		case(gameCounter)
			0: stateBits <= 20'b00000100001000011111; //0--x
			1: stateBits <= 20'b00001100001000011111; //1--x
			2: stateBits <= 20'b00010100001000011111; //2--x
			3: stateBits <= 20'b00011100001000011111; //3--x
			4: stateBits <= 20'b00100100001000011111; //4--x
			5: stateBits <= 20'b00101100001000011111; //5--x
			6: stateBits <= 20'b00110100001000011111; //6--x
			7: stateBits <= 20'b00111100001000011111; //7--x
			default: stateBits <= 20'b01000100001000011111; //8--x
		endcase
	end
endmodule