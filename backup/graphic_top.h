#ifndef __GRAPHIC_TOP_H__
#define __GRAPHIC_TOP_H__
//Misc
#define WIDTH   0x60
#define HEIGHT  0x40

//Masks
#define DCN_MASK            0x00000001
#define ADC_VALUE_MASK      0xFFF00000 // get the 12 MSB's, [31:20] 
#define ADC_CHANNEL_MASK    0x00080000 // channel axis is on [19], 1 for X, 0 for Y
#define ADC_X_COEFF         33 // convery ADC raw value to pixel position
#define ADC_Y_COEFF         49 //

// Stuff for spi_commnds
#define DRAW_SIZE   11
#define CLEAR_SIZE  5

#define DRAW_COM    0x22
#define CLEAR_COM   0x06

/* Object to store all the info for the cursor */
struct cursor
{
    int x_pos, y_pos, size;
    unsigned char f_colour;
    unsigned char l_colour;
    unsigned char draw_data[DRAW_SIZE];
    unsigned char clear_data[CLEAR_SIZE];
};//struct cursor

//clear location of cursor and redraw
void cursor_draw(struct cursor *self)
{
    alt_avalon_spi_command(SPI_0_BASE, 0, CLEAR_SIZE, self->clear_data, 0, NULL, 0);
    alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE,  self->draw_data,  0, NULL, 0);
};//void cursor_draw(struct cursor *self)

/*  Retrieve ADC value stored on the PIO_BASE, convert it to screen
    dimensions and store in the cursor struct
*/
void cursor_get_pos(struct cursor *self, int *pi_base)
{
    unsigned int adc_val    = *pi_base;
    char adc_conv           = 0;
    if(adc_val && ADC_CHANNEL_X_nY)
    {
        adc_conv = (adc_val >> 12)/ADC_X_COEFF;
        self->x_pos = adc_conv;
        self->draw_data[1] = self->x_pos;
        self->draw_data[3] = self->x_pos + self->size;
      
    }
    else
    {
        adc_conv = (adc_val >> 12)/ADC_Y_COEFF;
        self->y_pos = adc_conv;
        self->draw_data[2] = self->y_pos;
        self->draw_data[4] = self->y_pos + self->size;    
    }
    return;    
} //void cursor_get_pos(struct cursor *self, int *pi_base)


/* Non cursor functions*/
void clear_screen()
{
    unsigned char clear_data[CLEAR_SIZE] = {CLEAR_COM, 0x00, 0x00, WIDTH, HEIGHT};
    alt_avalon_spi_command(SPI_0_BASE, 0, CLEAR_SIZE, clear_data, 0, NULL , 0);
} 

#endif /* __GRAPHIC_TOP_H__ */
