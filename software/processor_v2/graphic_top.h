#ifndef __GRAPHIC_TOP_H__
#define __GRAPHIC_TOP_H__
//Misc
#define WIDTH   0x60
#define HEIGHT  0x40

#define IMAGE_HEIGHT 64
#define IMAGE_WIDTH 96
#define BYTES_PER_PIXEL 2

//Masks
#define DCN_MASK            0x00000001
#define ADC_VALUE_MASK      0x00000FFF // get the 12 MSB's, [31:20] 
#define ADC_CHANNEL_MASK    0x00080000 // channel axis is on [19], 1 for X, 0 for Y
#define ADC_X_COEFF         33 // convery ADC raw value to pixel position
#define ADC_Y_COEFF         49 //

#define STATE_MASK          0x00000007 // State mask
#define VALID_MASK          0x000000F0 // 

// Stuff for spi_commnds
#define DRAW_SIZE   11
#define CLEAR_SIZE  5

#define DRAW_COM    0x22
#define CLEAR_COM   0x25

// macros to set/clear rgb_dcn pin connected to bit 0 of gpio processor output
#define SET_DCN (*(int*)PIO_BASE)   = (*(int*)PIO_BASE) | DCN_MASK;
#define CLEAR_DCN (*(int*)PIO_BASE) = (*(int*)PIO_BASE) & ~DCN_MASK;

enum state{start_up = 0 , game_1 = 1, game_2 = 2, game_3 = 3, victory = 4, error = 7};

unsigned char draw_data[DRAW_SIZE] = {DRAW_COM, 10, 10, WIDTH-10, HEIGHT-10, 0, 0, 0, 0, 0, 0 };

/* Non cursor functions*/
void clear_screen()
{
    CLEAR_DCN;
    draw_data[5]    = 0;
    draw_data[6]    = 0;
    draw_data[7]    = 0;
    draw_data[8]    = 0;
    draw_data[9]    = 0;
    draw_data[10]   = 0;

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
    while( clock() < (start_time + (int)1));
    return;
}

#endif /* __GRAPHIC_TOP_H__ */
