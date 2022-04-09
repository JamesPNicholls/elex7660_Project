// This module will interface the ADC I/P 

module adcinterface( input logic clk, reset_n, 
							input logic [2:0] chan,
							output logic [11:0] result,
							
							output logic ADC_CONVST, ADC_SCK, ADC_SDI, 
							input logic ADC_SDO );
	
	reg [3:0] count = '0; // will count from 0 to 16
	reg [1:0] state = '0; // 4 states
	reg [11:0] read_val = '0; // 12 bit ADC value
	reg [11:0] configword;
	
	
	always_ff @(posedge clk, negedge reset_n)
		begin
		
			if(!reset_n) begin
				count <= 4'b0000; // reset count to 0 when reset @ negedge of clk
			end
			else
				count <= count + 4'b0001; // increment count by 1 @ posedge of clk
		end
	
	always @*
		begin
		
			if(count == 1) begin

				state  <= 2'b00; // state 0: adc_convst goes high
				ADC_CONVST = 1; end
				
			else if (count == 2) begin
				state = 2'b01; // state 1: adc_convst goes low
				ADC_CONVST = 0; end
				
			else if (count >2 && count < 15) begin 
				state = 2'b10; // state 2: adc_sck follows the system clk
			
				ADC_CONVST = 0; end
				
			else begin
				state = 2'b11; // state 3
				ADC_CONVST = 0; 
				result <= read_val; // result takes 12 bit value
			end
		
		end
		
	assign ADC_SCK = (state == 2'b10) ? clk : 1'b0; // @ state 2, match ADC_SCK with the FPGA clk 
	
	always_ff @(posedge ADC_SCK) 
		begin
			if(state == 2'b10)
				read_val[11 + 3 - count] <= ADC_SDO; // acquire the 12 bit O/P
		end
		
		
		
	assign configword = {chan[0], chan[2:1], 1'b1, 8'b00000001}; // 
		
	always_ff @ (negedge ADC_SCK)
		begin
			if(state == 2'b10)
				ADC_SDI <= configword[11 + 3 - count ]; // 				 
		end
		
	
	
	
endmodule	
	

	
	
	