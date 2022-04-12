module beep_beep( 
    input clk, enable,
    output spkr_on
);

    logic[15:0] count;
    assign count = enable == 1 ? count + 1 : 0;

	 always_ff @ (posedge clk) begin
		 if(count > 32'h7fff)
			  spkr_on <= 0;
		 else
			  spkr_on <= 1;
	end
        
endmodule