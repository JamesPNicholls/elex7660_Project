// A module to act as a debounce circuit, where the output only follows the input
// after it has been stable for at least 10ms
//
// ELEX 7660 - ASSIGNMENT 03 - Clinton Gaudet - March 27th, 2022

module debounce (input logic rawInput,
					  output logic debouncedInput,
					  input logic clk, reset_n);
					  
	logic Q1, Q2, xor_out;
	logic [3:0] count; // 4-bit count has a range from 0-15
	
	always_ff @(posedge clk, negedge reset_n)	//first-flip flop takes "rawInput"
	begin
		
		if (~reset_n)
		begin
			Q1 <= 0;
		end
		
		else if (rawInput)
		begin
			Q1 <= 1;
		end
		
		else
		begin
			Q1 <= 0;
		end
		
	end
	
	
	always_ff @(posedge clk, negedge reset_n)	//synchronizer stage flip-flop
	begin
		
		if (~reset_n)
		begin
			Q2 <= 0;
		end
		
		else if (Q1)	//first ff feeds into sync. stage ff
		begin
			Q2 <= 1;
		end
		
		else
		begin
			Q2 <= 0;
		end
		
	end
	
	
	always_comb
	begin
		xor_out <= Q1 ^ Q2;	//LOW if Q1 and Q2 are the SAME (bounce might be over)
	end
	
	
	always_ff @(posedge clk, negedge reset_n)
	begin
		
		if (~reset_n)
		begin
			debouncedInput <= 0;
			count <= 0;
		end
		
		else if (xor_out)		//if Q1 and Q2 are different, don't start counting
		begin
			count <= 0;
		end
		
		else if (count < 8 && !xor_out)	//if count<8 AND Q1&Q2 are the same, start counting
		begin
			count <= count + 1;
		end
		
		else if (count >= 8)	//count 8 instead of 10 accounts for 2 delays through FFs
		begin
			debouncedInput <= Q2;
			count <= 0;
		end
		
	end
		

endmodule

