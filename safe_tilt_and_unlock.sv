module safe_tilt_and_unlock (input logic  knock_input, 		//knock sensor input
									  input logic  reset_n, CLOCK_50,
									  output logic output_elmag,		//elmag output
									  output logic unlocked_flag);
	
	debounce debounce1 (.rawInput(knock_input), .debouncedInput(debounceGood), .clk(CLOCK_50), .reset_n);
	
	logic debounceGood;

   always_ff @(posedge CLOCK_50)
	begin

		if (~reset_n)
		begin
			output_elmag = 1;
			unlocked_flag = 0;
		end
	
		else if (debounceGood)	
		begin
			output_elmag = 0;
			unlocked_flag = 1;
		end
		
		else
		begin
			output_elmag = 1;
			unlocked_flag = 0;
		end
		
	end

endmodule
