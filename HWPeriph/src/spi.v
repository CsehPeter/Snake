module spi
(
	//SPI interface
	output wire miso;
	output wire mosi;
	output wire sck;
	output wire ss;
	output wire lcd_csn;
	output wire flash_csn;
	output wire sd_card_csn;

	//
	input wire valid;
	output wire ready;
);