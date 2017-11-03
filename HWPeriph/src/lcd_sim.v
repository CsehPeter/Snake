`timescale 1ns / 1ps

module lcd_sim();

    parameter C_SLV_DWIDTH = 32;
    parameter C_NUM_REG = 1;

    reg                      tb_Bus2IP_Clk;
    reg                      tb_Bus2IP_Resetn;

    reg [C_SLV_DWIDTH-1:0]   tb_Bus2IP_Data;
    reg [C_SLV_DWIDTH/8-1:0] tb_Bus2IP_BE;
    reg [C_NUM_REG-1:0]      tb_Bus2IP_RdCE;
    reg  [C_NUM_REG-1:0]      tb_Bus2IP_WrCE;
    wire [C_SLV_DWIDTH-1:0]   tb_IP2Bus_Data;
    wire                      tb_IP2Bus_RdAck;
    wire                      tb_IP2Bus_WrAck;
    wire                      tb_IP2Bus_Error;

    wire tb_sdcard_csn;
    wire tb_flash_csn;
    wire tb_lcd_csn;
    wire tb_sck;
    wire tb_mosi;
    wire tb_miso;

    user_logic user_logic_inst(
        .Bus2IP_Clk(tb_Bus2IP_Clk),
        .Bus2IP_Resetn(tb_Bus2IP_Resetn),
        .Bus2IP_Data(tb_Bus2IP_Data),
        .Bus2IP_BE(tb_Bus2IP_BE),
        .Bus2IP_RdCE(tb_Bus2IP_RdCE),
        .Bus2IP_WrCE(tb_Bus2IP_WrCE),
        .IP2Bus_Data(tb_IP2Bus_Data),
        .IP2Bus_RdAck(tb_IP2Bus_RdAck),
        .IP2Bus_WrAck(tb_IP2Bus_WrAck),
        .IP2Bus_Error(tb_IP2Bus_Error),
        .sdcard_csn(tb_sdcard_csn),
        .flash_csn(tb_flash_csn),
        .lcd_csn(tb_lcd_csn),
        .sck(tb_sck),
        .mosi(tb_mosi),
        .miso(tb_miso)
    );
    
    initial begin
        tb_Bus2IP_Clk <= 0;
        tb_Bus2IP_Resetn <= 0;
        tb_Bus2IP_Data <= 0;
        tb_Bus2IP_BE <= 0;
        tb_Bus2IP_RdCE <= 0;
        tb_Bus2IP_WrCE <= 0;
        
        #20
        tb_Bus2IP_Resetn <= 1;
        
        #20
        //STIMULUS
        write(32'h000001FF);

        write(32'h0000015A);

        read();
        
    end

    //GENERATE CLOCK (50MHz)
    always #10 tb_Bus2IP_Clk = ~tb_Bus2IP_Clk;
    
    //WRITE COMMAND
    task write;
        input [31:0] item;
    begin
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_WrCE <= 1'b1;
        tb_Bus2IP_Data <= item;
        tb_Bus2IP_BE <= 4'b1111;
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_WrCE <= 1'b0;
        tb_Bus2IP_Data <= 0;
        tb_Bus2IP_BE <= 4'b0000;
    end
    endtask

    //READ COMMAND
    task read;
    begin
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_RdCE <= 1'b1;
        tb_Bus2IP_BE <= 4'b1111;
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_RdCE <= 1'b0;
        tb_Bus2IP_BE <= 4'b0000;
    end
    endtask

endmodule
