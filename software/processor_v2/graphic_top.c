// lab5.c - initialize SSD1331 and fill framebuffer with an image
// Robert Trost - Feb 3, 2020

#include <time.h>
#include <stdint.h>
#include "image.h"		// image to write to display
#include "harder_image.h"
#include "hitme_image.h"
#include "victory_frame.h"
#include "system.h"		// peripheral base addresses
#include <altera_avalon_spi.h> // function to control altera SPI IP
#include "graphic_top.h"


// rgb display initialization sequence
#define INITDATA_SIZE 38
unsigned char initdata[INITDATA_SIZE] = { 0xAE, 0x81, 0xFF, 0x82, 0xFF, 0x83, 0xFF,
		     0x87, 0x06, 0x8A, 0x64, 0x8B, 0x78, 0x8C,
		     0x64, 0xA0, 0x73, 0xA1, 0x00, 0xA2, 0x00,
		     0xA4, 0xA8, 0x3F, 0xAD, 0x8E, 0xB0, 0x00,
		     0xB1, 0x31, 0xB3, 0x10, 0xBB, 0x3A, 0xBE,
		     0x3E, 0x2E, 0xAF } ;

int main()
{
	int x, y ; // array indices used to access pixel data in image arra
	unsigned char data;  // temporary storage of byte to be sent to display
	unsigned long int PIO_INPUT;
	unsigned int state_var; 
	
	// send controller initialization sequence
	CLEAR_DCN;
	alt_avalon_spi_command(SPI_0_BASE, 0, INITDATA_SIZE, initdata, 0, NULL, 0) ;

	 while(1)
	 {
	 	PIO_INPUT = (*(int*)PIO_BASE);
	 	state_var = (PIO_INPUT >> 1) & STATE_MASK;
	 	switch (state_var)
	 	{
	 	case start_up   :
	 		SET_DCN;
	 		for ( x=0 ; x < IMAGE_WIDTH ; x++ ) {
	 			for ( y=0 ; y < IMAGE_HEIGHT ; y++ ) {
	 			// send 16 bits representing the pixel colour: RRRRRGGG_GGGBBBBB
	 			alt_avalon_spi_command(SPI_0_BASE, 0, 1, &start_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL], 0, NULL, 0 ) ;
	 			alt_avalon_spi_command(SPI_0_BASE, 0, 1, &start_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL+1], 0, NULL, 0) ;
	 			}
	 		}
	 		break;
	 		// fill framebuffer - note array starts from top left going across rows,
  	 		// but must fill buffer from top left, going down columns.

	 	case game_1		:
		 	CLEAR_DCN;
	 		draw_data[5]  = 0x40;
	 		draw_data[8]  = 0x40;
			
	 		alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL, 0);
			
	 		// Fill with colour
	 		// Print Code
	 		break;

	 	case game_2		:
			 SET_DCN;
	 		 for ( x=0 ; x < IMAGE_WIDTH ; x++ ) {
	 		 	for ( y=0 ; y < IMAGE_HEIGHT ; y++ ) {
	 		 	// send 16 bits representing the pixel colour: RRRRRGGG_GGGBBBBB
	 		 	alt_avalon_spi_command(SPI_0_BASE, 0, 1, &hitme_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL], 0, NULL, 0 ) ;
	 		 	alt_avalon_spi_command(SPI_0_BASE, 0, 1, &hitme_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL+1], 0, NULL, 0) ;
	 		 	}
	 		 }


	 		// PRINK SPANK ME HARDERs
	 		break;

	 	case game_3		:
			 SET_DCN;
	 		 for ( x=0 ; x < IMAGE_WIDTH ; x++ ) {
	 		 	for ( y=0 ; y < IMAGE_HEIGHT ; y++ ) {
	 		 	// send 16 bits representing the pixel colour: RRRRRGGG_GGGBBBBB
	 		 	alt_avalon_spi_command(SPI_0_BASE, 0, 1, &harder_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL], 0, NULL, 0 ) ;
	 		 	alt_avalon_spi_command(SPI_0_BASE, 0, 1, &harder_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL+1], 0, NULL, 0) ;
	 		 	}
	 		 }
	 		break;
		
	 	case victory:
		 	 SET_DCN;
	 		 for ( x=0 ; x < IMAGE_WIDTH ; x++ ) {
	 		 	for ( y=0 ; y < IMAGE_HEIGHT ; y++ ) {
	 		 	// send 16 bits representing the pixel colour: RRRRRGGG_GGGBBBBB
	 		 	alt_avalon_spi_command(SPI_0_BASE, 0, 1, &victory_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL], 0, NULL, 0 ) ;
	 		 	alt_avalon_spi_command(SPI_0_BASE, 0, 1, &victory_image[(y*IMAGE_WIDTH+x)*BYTES_PER_PIXEL+1], 0, NULL, 0) ;
	 		 	}
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
	 	}
	 	frame_delay();
		
	 };

   return 0;
}
