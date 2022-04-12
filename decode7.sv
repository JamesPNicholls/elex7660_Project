/*********************************************************************
*DECODE-7 MODULE
*
*Date: 2/25/2022
*
*Author: Mo Amirian, Clint Gaudet, James Nicholls
*
*Class: ELEX 7660 - Digital System Design
*
*Module Description: 
*
*Decodes a 4-bit input into it's corresponding 7-segment LED displayable 
*value.
**********************************************************************/

module decode7 (input logic [3:0] num, output logic [7:0] leds);

	always_comb
		case (num)
			//.gfedcba
			0 : leds = 8'b11000000; //leftmost dig is decimal
			1 : leds = 8'b11111001; //active low ouput
			2 : leds = 8'b10100100;
			3 : leds = 8'b10110000;
			4 : leds = 8'b10011001;
			5 : leds = 8'b10010010;
			6 : leds = 8'b10000010;
			7 : leds = 8'b11111000;
			8 : leds = 8'b10000000;
			9 : leds = 8'b10010000;			
			10: leds = 8'b10001000; //A			
            11: leds = 8'b10000011; //b
            12: leds = 8'b11000110; //c
            13: leds = 8'b10100001; //d
            14: leds = 8'b10000110; //e
            15: leds = 8'b10001110; //f
			default: leds = 8'b11111111;
		endcase
endmodule