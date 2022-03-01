/*********************************************************************
*KEYPAD DECODE MODULE
*
*Date: 2/25/2022
*
*Author: Mo Amirian, Clint Gaudet, James Nicholls
*
*Class: ELEX 7660 - Digital System Design
*
*Module Description: 
*
*Determines which button was pressed by reading the kpc and kpr signals.
*Also uses an output logic to drive the c[0] which turns on the Least 
*significant digit of the LED on button press.
*
**********************************************************************/

module kpdecode (input logic [3:0] kpr, input logic [3:0] kpc,
					output logic kphit, output logic [3:0] num);
	always_comb begin
		//check the columns / rows and assign num accordingly
		case (kpc)
			4'b0111://column 3 
				case (kpr)
					4'b0111:begin  //row 3
							num = 1;		//1
							kphit = 1; end	
					4'b1011: begin //row 2
							num = 4;		//4
							kphit = 1; end
					4'b1101: begin //row 1
							num = 7;		//7
							kphit = 1; end
					4'b1110: begin //row 0
							num = 14;		//e
							kphit = 1; end
					default: begin 			//don't care case
							num = 4'bxxxx;
							kphit = 0; end
				endcase	
			4'b1011://column 2 
				case (kpr)
					4'b0111:begin  //row 3
							num = 2;		//2
							kphit = 1; end	
					4'b1011: begin //row 2
							num = 5;		//5
							kphit = 1; end
					4'b1101: begin //row 1
							num = 8;		//8
							kphit = 1; end
					4'b1110: begin //row 0
							num = 0;		//0
							kphit = 1; end
					default: begin 			//don't care case
							num = 4'bxxxx;
							kphit = 0; end
				endcase
			4'b1101://column 1 
				case (kpr)
					4'b0111:begin  //row 3
							num = 3;		//3
							kphit = 1; end	
					4'b1011: begin //row 2
							num = 6;		//6
							kphit = 1; end
					4'b1101: begin //row 1
							num = 9;		//9
							kphit = 1; end
					4'b1110: begin //row 0
							num = 15;		//f
							kphit = 1; end
					default: begin 			//don't care case
							num = 4'bxxxx;
							kphit = 0; end
				endcase	
			4'b1110://column 0 
				case (kpr)
					4'b0111:begin  //row 3
							num = 10;		//A
							kphit = 1; end	
					4'b1011: begin //row 2
							num = 11;		//b
							kphit = 1; end
					4'b1101: begin //row 1
							num = 12;		//c
							kphit = 1; end
					4'b1110: begin //row 0
							num = 13;		//d
							kphit = 1; end
					default: begin 			//don't care case
							num = 4'bxxxx;
							kphit = 0; end
				endcase	
            default : begin
                num = 4'bxxxx;
                kphit = 0;				
            end				
		endcase
	end
endmodule
	