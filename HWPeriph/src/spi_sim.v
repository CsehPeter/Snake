`timescale 1ns / 1ps

module spi_sim();

    reg tb_clk;
    reg tb_rst;

    //SPI signals
    wire tb_sdcard_csn;
    wire tb_flash_csn;
    wire tb_lcd_csn;
    wire tb_sck;
    wire tb_mosi;
    wire tb_miso;

    //Inner signals
    reg tb_valid;
    wire tb_ready;
    reg [7:0] tb_cmd;
    reg tb_mode;

    spi spi_inst(
        .clk(tb_clk),
        .rst(tb_rst),
        .sdcard_csn(tb_sdcard_csn),
        .flash_csn(tb_flash_csn),
        .lcd_csn(tb_lcd_csn),
        .sck(tb_sck),
        .mosi(tb_mosi),
        .miso(tb_miso),
        .valid(tb_valid),
        .ready(tb_ready),
        .cmd(tb_cmd),
        .mode(tb_mode)
    );
    
    initial begin
        tb_clk <= 0;
        tb_rst <= 1;
        tb_valid <= 0;
        tb_cmd <= 0;
        tb_mode <= 0;
        
        #20
        tb_rst <= 0;
        
        #200
        //STIMULUS
        send(8'hA5, 1'b0);
        
        #450
        send(8'h5A, 1'b1);
        
        #450
        send(8'hFF, 1'b1);
        
    end

    //GENERATE CLOCK (50MHz)
    always #10 tb_clk = ~tb_clk;
    
    //SEND COMMAND
    task send;
        input [7:0] cmd;
        input mode;
    begin
        @ (posedge tb_clk)
        tb_valid <= 1'b1;
        tb_cmd <= cmd;
        tb_mode <= mode;
        @ (posedge tb_clk)
        tb_valid <= 1'b0;
    end
    endtask

endmodule
