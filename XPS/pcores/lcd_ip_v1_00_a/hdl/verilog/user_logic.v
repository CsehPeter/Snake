`uselib lib=unisims_ver
`uselib lib=proc_common_v3_00_a

module user_logic #(
   //Az IPIF interfÃ©szhez tartozÃ³ paramÃ©terek.
   parameter C_NUM_REG                      = 1,      //Az IPIF Ã¡ltal dekÃ³dolt 32 bites regiszterek szÃ¡ma.
   parameter C_SLV_DWIDTH                   = 32      //Az adatbusz szÃ©lessÃ©ge bitekben.
   
   //Itt kell megadni a tÃ¶bbi sajÃ¡t paramÃ©tert.
) (
   //Az IPIF interfÃ©szhez tartozÃ³ portok. Ha a Create or Import Peripheral
   //Wizard-ban nem jelÃ¶ltÃ¼k be a memÃ³ria interfÃ©szhez tartozÃ³ Bus2IP_Addr,
   //Bus2IP_CS Ã©s Bus2IP_RNW jelek hozzÃ¡adÃ¡sÃ¡t, akkor ezeket innen tÃ¶rÃ¶ljÃ¼k.
   input  wire                      Bus2IP_Clk,       //Ã“rajel.
   input  wire                      Bus2IP_Resetn,    //AktÃ­v alacsony reset jel.
   //input  wire [31:0]               Bus2IP_Addr,    //CÃ­mbusz.
   //input  wire [0:0]                Bus2IP_CS,         //A perifÃ©ria cÃ­mtartomÃ¡nyÃ¡nak elÃ©rÃ©sÃ©t jelzÅ‘ jel.
   //input  wire                      Bus2IP_RNW,        //A mÅ±velet tÃ­pusÃ¡t (0: Ã­rÃ¡s, 1: olvasÃ¡s) jelzÅ‘ jel.
   input  wire [C_SLV_DWIDTH-1:0]   Bus2IP_Data,      //Ã�rÃ¡si adatbusz.
   input  wire [C_SLV_DWIDTH/8-1:0] Bus2IP_BE,        //BÃ¡jt engedÃ©lyezÅ‘ jelek (csak Ã­rÃ¡s esetÃ©n Ã©rvÃ©nyesek).
   input  wire [C_NUM_REG-1:0]      Bus2IP_RdCE,      //A regiszterek olvasÃ¡s engedÃ©lyezÅ‘ jelei.
   input  wire [C_NUM_REG-1:0]      Bus2IP_WrCE,      //A regiszterek Ã­rÃ¡s engedÃ©lyezÅ‘ jelei.
   output wire [C_SLV_DWIDTH-1:0]   IP2Bus_Data,      //OlvasÃ¡si adatbusz.
   output wire                      IP2Bus_RdAck,     //Az olvasÃ¡si mÅ±veletek nyugtÃ¡zÃ³ jele.
   output wire                      IP2Bus_WrAck,     //Az Ã­rÃ¡si mÅ±veletek nyugtÃ¡zÃ³ jele.
   output wire                      IP2Bus_Error,     //HibajelzÃ©s.
   
   //Itt kell megadni a tÃ¶bbi sajÃ¡t portot.
   output wire sdcard_csn,
   output wire flash_csn,
   output wire lcd_csn,
   output wire sck,
   output wire mosi,
   output wire miso
);

wire rst = ~Bus2IP_Resetn;

wire [8:0] cmd;
wire wr;
wire full;

wire [8:0] fifo_dout;
wire [7:0] spi_cmd = fifo_dout[7:0];
wire spi_mode = fifo_dout[8];

reg spi_valid;
wire spi_ready;

reg fifo_rd;
wire fifo_empty;

always @(posedge Bus2IP_Clk) begin
      if (fifo_empty == 0 && spi_ready == 1) begin
         fifo_rd <= 1;
         spi_valid <= 1;
      end

      if(spi_valid == 1) begin
         fifo_rd <= 0;
         spi_valid <= 0;
      end
end

bus_if bus_if_inst(
   .Bus2IP_Clk(Bus2IP_Clk),
   .Bus2IP_Resetn(Bus2IP_Resetn),
   .Bus2IP_Data(Bus2IP_Data),
   .Bus2IP_BE(Bus2IP_BE),
   .Bus2IP_RdCE(Bus2IP_RdCE),
   .Bus2IP_WrCE(Bus2IP_WrCE),
   .IP2Bus_Data(IP2Bus_Data),
   .IP2Bus_RdAck(IP2Bus_RdAck),
   .IP2Bus_WrAck(IP2Bus_WrAck),
   .IP2Bus_Error(IP2Bus_Error),
   .cmd(cmd),
   .wr(wr),
   .full(full)
   );

spi spi_inst(
        .clk(Bus2IP_Clk),
        .rst(rst),
        .sdcard_csn(sdcard_csn),
        .flash_csn(flash_csn),
        .lcd_csn(lcd_csn),
        .sck(sck),
        .mosi(mosi),
        .miso(miso),
        .valid(spi_valid),
        .ready(spi_ready),
        .cmd(spi_cmd),
        .mode(spi_mode)
    );

fifo fifo_inst(
   .clk(Bus2IP_Clk),
   .rst(rst),
   .din(cmd),
   .dout(fifo_dout),
   .rd(fifo_rd),
   .wr(wr),
   .empty(fifo_empty),
   .full(full)
);

endmodule
