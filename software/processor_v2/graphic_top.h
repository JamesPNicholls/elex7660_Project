#ifndef __GRAPHIC_TOP_H__
#define __GRAPHIC_TOP_H__
//Misc
#define WIDTH   0x60
#define HEIGHT  0x40

//Masks
#define DCN_MASK            0x00000001
#define ADC_VALUE_MASK      0x00000FFF // get the 12 MSB's, [31:20] 
#define ADC_CHANNEL_MASK    0x00080000 // channel axis is on [19], 1 for X, 0 for Y
#define ADC_X_COEFF         33 // convery ADC raw value to pixel position
#define ADC_Y_COEFF         49 //

#define STATE_MASK          0x0000000E // State mask
#define VALID_MASK          0x000000F0 // 

// Stuff for spi_commnds
#define DRAW_SIZE   11
#define CLEAR_SIZE  5

#define DRAW_COM    0x22
#define CLEAR_COM   0x25

// macros to set/clear rgb_dcn pin connected to bit 0 of gpio processor output
#define SET_DCN (*(int*)PIO_BASE)   = (*(int*)PIO_BASE) | DCN_MASK;
#define CLEAR_DCN (*(int*)PIO_BASE) = (*(int*)PIO_BASE) & ~DCN_MASK;

enum state{start_up, game_1, game_2, game_3, victory, error = 7};

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
    alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE,  self->draw_data,  0, NULL, 0);
};//void cursor_draw(struct cursor *self)

void cursor_screen_colour(struct  cursor *self)
{

};

/*  Retrieve ADC value stored on the PIO_BASE, convert it to screen
    dimensions and store in the cursor struct
*/
void cursor_get_pos(struct cursor *self, int pi_base)
{
    unsigned long int adc_val   = (unsigned long int) pi_base;
    unsigned int adc_conv       = 0;

    adc_conv = ((adc_val) >> 20) & ADC_VALUE_MASK/ADC_X_COEFF;
    self->x_pos = adc_conv;
    self->draw_data[1] = self->x_pos;
    self->draw_data[3] = self->x_pos + self->size;
    
    adc_conv = ((adc_val) >> 8) & ADC_VALUE_MASK/ADC_Y_COEFF;
    self->y_pos = adc_conv;
    self->draw_data[2] = self->y_pos;
    self->draw_data[4] = self->y_pos + self->size;    
    
    return;    
} //void cursor_get_pos(struct cursor *self, int *pi_base)


/* Non cursor functions*/
void clear_screen()
{
    CLEAR_DCN;
    unsigned char clear_data[CLEAR_SIZE] = {CLEAR_COM, 0x00, 0x00, WIDTH-1, HEIGHT-1};
    alt_avalon_spi_command(SPI_0_BASE, 0, CLEAR_SIZE, clear_data, 0, NULL , 0);
} 

//Waits for the 
void checkvalid()
{
    while(1)
    {
        if((*(int*)PIO_BASE) & VALID_MASK)
        {
            return;
        }    
    }
}

void frame_delay()
{
    clock_t start_time = clock();
    while( clock() < (start_time + (int)10));   
    return;
}

#endif /* __GRAPHIC_TOP_H__ */
