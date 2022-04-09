// lab5.c - initialize SSD1331 and fill framebuffer with an image
// Robert Trost - Feb 3, 2020


#include <time.h>
#include <stdint.h>
#include "system.h"		// peripheral base addresses
#include <altera_avalon_spi.h> // function to control altera SPI IP
#include "graphic_top.h"
#include "image.h"		// image to write to display





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
	int x, y ; // array indices used to access pixel data in image arra
	unsigned char data;  // temporary storage of byte to be sent to display
	unsigned long int PIO_INPUT;
	unsigned int state_var; 
	unsigned char clear_Flag[4] = {1,1,1,1};
	
	// send controller initialization sequence
	CLEAR_DCN;
	alt_avalon_spi_command(SPI_0_BASE, 0, INITDATA_SIZE, initdata, 0, NULL, 0) ;
	clear_screen();
	//alt_avalon_spi_command(SPI_0_BASE, 0, CLEAR_SIZE, clear_data, 0, NULL, 0);
	 while(1)
	 {
	 	PIO_INPUT = (*(int*)PIO_BASE);	
	 	state_var = (PIO_INPUT >> 1) & STATE_MASK;
		

	 	switch (state_var)
	 	{
	 	case start_up   :
		 	if (clear_Flag[0])
			 clear_screen();
			 frame_delay();
			
			clear_Flag[0] = 0;
		 	set_draw_colour(0xff);
	 		for ( x=0 ; x < START_SIZE/4 ; x++)
	 		{
				draw_data[1] = start_0[x*4]	;
				draw_data[2] = start_0[x*4+1]	;
				draw_data[3] = start_0[x*4+2]	;
				draw_data[4] = start_0[x*4+3]	;
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
	 		}
			
			
	 		// fill framebuffer - note array starts from top left going across rows,
  	 		// but must fill buffer from top left, going down columns.
			break;
	 	case game_1		:
		 	if (clear_Flag[1])
			 clear_screen();
			 frame_delay();
			
			clear_Flag[1] = 0;
		
			set_draw_colour(0xff);
	 		for ( x=0 ; x < SPANK_0_SIZE/4 ; x++)
	 		{
				draw_data[1] = spank_0[x*4]	;
				draw_data[2] = spank_0[x*4+1]	;
				draw_data[3] = spank_0[x*4+2]	;
				draw_data[4] = spank_0[x*4+3]	;
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
	 		}
	 		break;
	 		//

	 	case game_2		:
			if (clear_Flag[2])
				clear_screen();
				frame_delay();
			
			clear_Flag[2] = 0;
			set_draw_colour(0x55);
	 		for ( x=0 ; x < SPANK_1_SIZE/4 ; x++)
			{
				draw_data[1] = spank_1[x*4]	;
				draw_data[2] = spank_1[x*4+1]	;
				draw_data[3] = spank_1[x*4+2]	;
				draw_data[4] = spank_1[x*4+3]	;
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
			}
	 		// PRINK SPANK ME HARDERs
	 		break;

	 	case game_3		:

	 		break;
		
	 	case victory 	:
			if (clear_Flag[3])
				clear_screen();
				frame_delay();
				
			clear_Flag[3] = 0;
			set_draw_colour(0xff);
			for ( x=0 ; x < VICTORY_SIZE/4 ; x++)
			{
				draw_data[1] = victory_0[x*4]	;
				draw_data[2] = victory_0[x*4+1]	;
				draw_data[3] = victory_0[x*4+2]	;
				draw_data[4] = victory_0[x*4+3]	;
				alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
			}
			  //VICTORY SCREEN
	 		break;

	 	default:
	 		draw_data[5]    = 0xff;
	 		draw_data[6]    = 0x00;
	 		draw_data[7]    = 0xff;
	 		draw_data[8]    = 0xff;
	 		draw_data[9]    = 0x00;
	 		draw_data[10]   = 0xff;
	 		alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
	 		break;
		};
	 	frame_delay();
	 };

   return 0;
}
