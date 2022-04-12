#ifndef __GRAPHIC_TOP_H__
#define __GRAPHIC_TOP_H__

// For w/e reason 96 and 64 dont work if I want
// to draw over the entire screen i have to use 127 and 95
#define WIDTH   0x7f
#define HEIGHT  0x5f

#define IMAGE_HEIGHT 64
#define IMAGE_WIDTH 96
#define BYTES_PER_PIXEL 2

//Masks
#define DCN_MASK            0x00000001 // used toggle DCN for write read mode
#define ADC_VALUE_MASK      0x00000FFF // get the 12 MSB's, [31:20] 
#define ADC_CHANNEL_MASK    0x00080000 // channel axis is on [19], 1 for X, 0 for Y
#define ADC_X_COEFF         33 // convert ADC raw value to pixel position
#define ADC_Y_COEFF         49 

#define STATE_MASK          0x00000007 

// Stuff for spi_commnds
#define DRAW_SIZE   11
#define CLEAR_SIZE  5

// See sssd1331 manual for additional command codes
#define DRAW_COM    0x22
#define CLEAR_COM   0x25

// macros to set/clear rgb_dcn pin connected to bit 0 of gpio processor output
#define SET_DCN (*(int*)PIO_BASE)   = (*(int*)PIO_BASE) | DCN_MASK;
#define CLEAR_DCN (*(int*)PIO_BASE) = (*(int*)PIO_BASE) & ~DCN_MASK;

//State Variable
enum state{start_up = 0 , game_1 = 1, game_2 = 2, game_3 = 3, harder = 4, victory = 5, error = 7};

// Input array used in conjunction with alt_avalon_spi_command()
unsigned char draw_data[DRAW_SIZE] = {DRAW_COM, 0x00, 0x00, WIDTH, HEIGHT, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
unsigned char clear_data[CLEAR_SIZE] = {CLEAR_COM, 0x00, 0x00, WIDTH, HEIGHT};

//Clears the screen by drawwing a black rectangle over the it
void clear_screen()
{
    CLEAR_DCN;
    draw_data[1]    = 0x00;
    draw_data[2]    = 0x00;
    draw_data[3]    = HEIGHT;
    draw_data[4]    = WIDTH;
    draw_data[5]    = 0x00;
    draw_data[6]    = 0x00;
    draw_data[7]    = 0x00;
    draw_data[8]    = 0x00;
    draw_data[9]    = 0x00;
    draw_data[10]   = 0x00;
    alt_avalon_spi_command(SPI_0_BASE, 0, DRAW_SIZE, draw_data, 0, NULL , 0);
} 

// Sets the colour paramters in the draw_data[] array
// some input options found image.h
void set_draw_colour(unsigned char col[6])
{
    draw_data[5]    = col[0];
    draw_data[6]    = col[1];
    draw_data[7]    = col[2];
    draw_data[8]    = col[3];
    draw_data[9]    = col[4];
    draw_data[10]   = col[5];
    return;
}

// Sets the coordinates used in the DRAW_RECTANGLE avalon command
void set_draw_data( unsigned char *pos_d)
{
    draw_data[1] = pos_d[0];
    draw_data[2] = pos_d[1];
    draw_data[3] = pos_d[2];
    draw_data[4] = pos_d[3];
}

//Delays the screen refresh rate by 1ms to prevent screen tearing
void frame_delay()
{
    clock_t start_time = clock();
    while( clock() < (start_time + (int)1));
    return;
}

#endif /* __GRAPHIC_TOP_H__ */
