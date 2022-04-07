
module processor (
	clk_clk,
	gpio_in_port,
	gpio_out_port,
	reset_reset_n,
	spi_MISO,
	spi_MOSI,
	spi_SCLK,
	spi_SS_n);	

	input		clk_clk;
	input	[31:0]	gpio_in_port;
	output	[31:0]	gpio_out_port;
	input		reset_reset_n;
	input		spi_MISO;
	output		spi_MOSI;
	output		spi_SCLK;
	output	[15:0]	spi_SS_n;
endmodule
