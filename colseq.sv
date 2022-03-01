/*********************************************************************
*COLUMN SEQUENCER MODULE
*
*Date: 2/25/2022
*
*Author: Mo Amirian, Clint Gaudet, James Nicholls
*
*Class: ELEX 7660 - Digital System Design
*
*Module Description: 
*
*Functions as a simple state machine, using the kpc output, drives 
*each output low in succession and uses kpr to determine if button 
*pressed. contains a clk and active-low reset.
*
**********************************************************************/

module colseq (input logic clk, input logic reset_n,
				input logic [3:0] kpr, output logic [3:0] kpc);
	
	logic [3:0] nextState;

	always_ff @(posedge clk, negedge reset_n)
		if(~reset_n)
			kpc <= 4'b0111;
		else
			kpc <= nextState;
	
	always_comb
		case (kpc)
			4'b0111: //set col 3 output low and check for row[3]->row[0] inputs
				if (kpr == 4'b0111 | kpr == 4'b1011 | kpr == 4'b1101 | kpr == 4'b1110)
					nextState = 4'b0111;
				else 
					nextState = 4'b1011;				
			4'b1011: //set col 2 output low and check for row[3]->row[0] inputs
				if (kpr == 4'b0111 | kpr == 4'b1011 | kpr == 4'b1101 | kpr == 4'b1110)
					nextState = 4'b1011;
				else 
					nextState = 4'b1101;				
			4'b1101: //set col 1 output low and check for row[3]->row[0] inputs
				if (kpr == 4'b0111 | kpr == 4'b1011 | kpr == 4'b1101 | kpr == 4'b1110)
					nextState = 4'b1101;
				else 
					nextState = 4'b1110;				
			4'b1110: //set col 0 output low and check for row[3]->row[0] inputs
				if (kpr == 4'b0111 | kpr == 4'b1011 | kpr == 4'b1101 | kpr == 4'b1110)
					nextState = 4'b1110;
				else 
					nextState = 4'b0111;						
			default: //default case, instantiating the state back to a known one
					nextState = 4'b0111;
		endcase
endmodule