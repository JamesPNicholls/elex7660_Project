module adcinterface(	input logic clk, reset_n, 		// clock and reset
						input logic [2:0] chan, 		// ADC channel to sample
						output logic [11:0] result, 	// ADC result
						
						// ltc2308 signals
						output logic ADC_CONVST, ADC_SCK, ADC_SDI,
						input logic ADC_SDO
);
	//State Variables	
	localparam [2:0]
		RESET       = 0,
		WAIT		= 1,
		ARM			= 2,
		SCK_CYCLE	= 3,
		SEND		= 4;
	
	// Other Var
		// Track the states
	reg [2:0] current_State = '0;		
	reg [2:0] next_State		= '0;
		//store the result values to be sent out
	reg [11:0] result_Reg   = '0;
 	reg [12:0] command_Word;
	assign command_Word = { chan[0], chan[2:1], 1'b1, 8'b000000001};
	
	//Used to trigger state changes
	reg arm_Flag = 0;
	reg [3:0] sck_Count = '0;

	assign ADC_SCK = ((current_State == SCK_CYCLE)) ? clk : 1'b0; //gate the sck signal
	
	// Handle state progression
	always_ff @ (posedge clk) begin
		if( ~reset_n) 
			current_State <= RESET;
		else
			current_State <= next_State;
	end

	always @ (negedge clk) begin
		case(current_State)
			//reset the flags and send the 12 result bits out
			RESET		: 	begin								
								arm_Flag    <= '0;
								sck_Count 	<= '0;
								next_State  <= ARM;
								result <= result_Reg;
							end							
			
			// Pulse the ADC_CONVST signal to arm the ADC
			ARM			:	begin
									if(~arm_Flag) begin
										arm_Flag <= 1;
										ADC_CONVST <= 1;
									end else if (arm_Flag && ADC_CONVST)
										ADC_CONVST <= 0;
									else if (arm_Flag && ~ADC_CONVST)
										next_State <= SCK_CYCLE;
								end
			
			// Produce 12 pulses on ADC_SCK, and return to the first state when completed
			SCK_CYCLE	:	begin
								if(sck_Count < 11) begin
									sck_Count <= sck_Count + 1;
								end	else begin
									next_State <= RESET;						
								end								
							end	
		endcase
	end

	always @ (negedge ADC_SCK)//sends the command bits
		ADC_SDI <= command_Word[11-sck_Count];
		
	always @ (posedge ADC_SCK)//store the result in the result value
		result_Reg[11-sck_Count] <= ADC_SDO;
endmodule 