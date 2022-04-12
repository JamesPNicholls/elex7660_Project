/* Originally made by Robert Trost for ELEX 7660 @ BCIT

	Heavily modified by James Nicholls for use in ELEX 7660 final project
	Used as a top level driver module to control a SSD1331 OLED screen, via
	SPI and PIO through the Nios 2 Soft process on a De0-Nano-SoC(5CSEMA4U23C6)
*/

#include <time.h>
#include <stdint.h>
#include "system.h"				// peripheral base addresses
#include <altera_avalon_spi.h> 	// function to control altera SPI IP
#include "graphic_top.h"		// Header used to store additional functions
#include "image.h"				// Image arrays to print on screen

// rgb display initialization sequence
#define INITDATA_SIZE 40
unsigned char initdata[INITDATA_SIZE] = { 0xAE, 0x81, 0xFF, 0x82, 0xFF, 0x83, 0xFF,
		     0x87, 0x06, 0x8A, 0x64, 0x8B, 0x78, 0x8C,
		     0x64, 0xA0, 0x73, 0xA1, 0x00, 0xA2, 0x00,
		     0xA4, 0xA8, 0x3F, 0xAD, 0x8E, 0xB0, 0x00,
		     0xB1, 0x31, 0xB3, 0x10, 0xBB, 0x3A, 0xBE,
		     0x3E, 0x2E, 0xAF, 0x26, 0x01} ;

int main()
{
	int x, y ; 						// array indices used to access pixel data in image arra
	unsigned char data;  			// temporary storage of byte to be sent to display
	
	unsigned long int PIO_INPUT; 	// Used to store the contents of the PIO_BASE register
	
	// data taken from PIO_INPUT
	unsigned int state_var; 
	unsigned char x_val, y_val;

	// rectangles can be filled or unfilled to allow for more complex drawings
	// setting value to 1 causes drawings to be filled, 0 for unfilled
	unsigned char fill_com[2] = {0x26, 1};
	
	// send controller initialization sequence
	CLEAR_DCN;
	alt_avalon_spi_command(SPI_0_BASE, 0, INITDATA_SIZE, initdata, 0, NULL, 0) ;
	clear_screen();

	//Array of flags to clear the contents of the screen when entering a new state
	unsigned char flags[6] = {1,1,1,1,1,1};


	 while(1)
	 {
		//Stores the register data and masks out the desired information
	 	PIO_INPUT = (*(int*)PIO_BASE);	
	 	state_var = (PIO_INPUT >> 1) & STATE_MASK;
		x_val     = (PIO_INPUT  >> 24) & 0xf;
		y_val 	  = (PIO_INPUT  >> 16) & 0xf;
		

		frame_delay();

		//Reads state from the FPGA, and procduces the desired frame on the screen
	 	switch (state_var)
	 	{
	 	case start_up   :
			if(flags[0])
			{
				clear_screen();
				flags[0] = 0;
				flags[5] = 1;
			}
			else
			{
				set_draw_colour(white);
				for ( x=0 ; x < START_SIZE/4 ; x++)
				{
					set_draw_data(&start_0[x*4]);
					alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				}

			}
			break;
	 	case game_2		: // James game, out of order because debuggung is hard
			if(flags[1])
			{
				clear_screen();
				flags[1]=0;
			}
			else
			{
				// Draws 4 red squares on the screen
				set_draw_colour(red);
				set_draw_data(joy_res_TR);
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				set_draw_data(joy_res_BL);
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				set_draw_data(joy_res_TL);
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				set_draw_data(joy_res_BR);
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				
				//based on y and x values from the FPGA turn one of the cubes green.,
				if(y_val > 8)
				{
					if(x_val < 8)
					{
						set_draw_colour(green);
						set_draw_data(joy_res_TL);
						alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
					}
					else
					{
						set_draw_colour(green);
						set_draw_data(joy_res_TR);
						alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
					}

				}
				else
				{
					if(x_val < 8)
					{
						set_draw_colour(green);
						set_draw_data(joy_res_BL);
						alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);	
					}
					else
					{
						set_draw_colour(green);
						set_draw_data(joy_res_BR);
						alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
					}					
				}

			}
	 		break;

	 	case game_1		:
			if(flags[2])
			{
				clear_screen();
				flags[2]=0;
			}
			else
			{
				//Draws a cute little clock on the screen
				for(x = 0; x < CLOCK_SIZE/4; x++)
				{
					set_draw_colour(white);
					if(x == 0) //First rectangle is unfilled
					{
						fill_com[1] = 0;						
						alt_avalon_spi_command(SPI_0_BASE, 0, 2, fill_com, 0, NULL, 0); // clear fill
					}
					else
					{						
						fill_com[1] = 1;
						alt_avalon_spi_command(SPI_0_BASE, 0, 2, fill_com, 1, NULL, 0); // set fill
					}
					set_draw_data(&clock_0[x*4]);
					alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 1, NULL, 0);
				}

			} 
	 		break;

	 	case game_3		: //
			if(flags[3])
			{
				clear_screen();
				flags[3]=0;
			}
			else
			{
				set_draw_colour(white);
				for ( x=0 ; x < SPANK_0_SIZE/4 ; x++)
				{
					set_draw_data(&spank_0[x*4]);
					alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				}
	 		}
	 		break;

		case harder		:
			if(flags[4])
			{
				clear_screen();
				flags[4]=0;
			}
			else
			{
				set_draw_colour(white);
				for ( x=0 ; x < SPANK_1_SIZE/4 ; x++)
				{
					set_draw_data(&spank_1[x*4]);
					alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				}
			}
	 		break;
		
	 	case victory 	:

			if(flags[5]) //Clear the flags
			{
				clear_screen();
				flags[5]=0;
				flags[0]=1;
				flags[1]=1;
				flags[2]=1;
				flags[3]=1;
				flags[4]=1;
			}
			else
			{
				set_draw_colour(white); //Display the victory screen
				for ( x=0 ; x < VICTORY_SIZE/4 ; x++)
				{
					draw_data[1] = victory_0[x*4]	;
					draw_data[2] = victory_0[x*4+1]	;
					draw_data[3] = victory_0[x*4+2]	;
					draw_data[4] = victory_0[x*4+3]	;
					alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
				}
			}
			break;

	 	default:
	 		draw_data[5]    = 0x00;
	 		draw_data[6]    = 0x00;
	 		draw_data[7]    = 0xff;
	 		draw_data[8]    = 0x00;
	 		draw_data[9]    = 0x00;
	 		draw_data[10]   = 0xff;
	 		alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
	 		break;
		};
	 	frame_delay();
	 };

   return 0;
}
