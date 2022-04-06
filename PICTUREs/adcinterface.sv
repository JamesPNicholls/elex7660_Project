// This module will interface the ADC 

module adcinterface( input logic clk, reset_n, 
							input logic [2:0] chan,
							output logic [11:0] result,
							
							output logic ADC_CONVST, ADC_SCK, ADC_SDI, 
							input logic ADC_SDO );
	
	logic [3:0] count; // will count from 0 to 16
	logic [1:0] state; // 4 states
	logic [11:0] read_val; // 12 bit ADC value
	logic [11:0] configword;
	
	initial begin
	count = 4'b0000; // initialize count and ADC_CONVST
	ADC_CONVST = 1; // should be 1 only in state 1
	result = 12'b000000000000;
	end
	
	
	always_ff @(posedge clk, negedge reset_n)
		begin
		
			if(!reset_n)
				count <= 4'b0000; // reset count to 0 when reset @ negedge of clk
				
			else
				count <= count + 4'b0001; // increment count by 1 @ posedge of clk
		end
	
	always_comb 
		begin
		
			if(count == 1) begin
				state = 2'b00; // state 0
				ADC_CONVST = 1; end
				
			else if (count == 2) begin
				state = 2'b01; // state 1
				ADC_CONVST = 0; end
				
			else if (count >2 && count < 15) begin // when count is 3 to 14
				state = 2'b10; // state 2
			
				ADC_CONVST = 0; end
				
			else begin
				state = 2'b11; // state 3
				ADC_CONVST = 0; end
		
		end
		
	assign ADC_SCK = (state == 2'b10) ? clk : 1'b0; // @ state 2, match ADC_SCK with the FPGA clk 
	
	always_ff @(posedge ADC_SCK)
		begin
			read_val <= read_val << 1;
			read_val[0] <= ADC_SDO;
		end
		
		
		
	assign configword = {1'b1, chan[0], chan[2:1], 1'b1, 7'b0000000}; // 6-bits of ADC_SDI 1,ch0,ch1,ch2,1
		
	always_ff @ (negedge ADC_SCK)
		begin
			ADC_SDI <= configword[11];
				// for state 1,2,3 
		end
		
	
	
	
endmodule	
	

	
	
	