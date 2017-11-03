`uselib lib=unisims_ver
`uselib lib=proc_common_v3_00_a

module user_logic #(
   //Az IPIF interfészhez tartozó paraméterek.
   parameter C_NUM_REG                      = 2,      //Az IPIF által dekódolt 32 bites regiszterek száma.
   parameter C_SLV_DWIDTH                   = 32      //Az adatbusz szélessége bitekben.
   
   //Itt kell megadni a többi saját paramétert.
) (
   //Az IPIF interfészhez tartozó portok. Ha a Create or Import Peripheral
   //Wizard-ban nem jelöltük be a memória interfészhez tartozó Bus2IP_Addr,
   //Bus2IP_CS és Bus2IP_RNW jelek hozzáadását, akkor ezeket innen töröljük.
   input  wire                      Bus2IP_Clk,       //Órajel.
   input  wire                      Bus2IP_Resetn,    //Aktív alacsony reset jel.
   //input  wire [31:0]               Bus2IP_Addr,    //Címbusz.
   //input  wire [0:0]                Bus2IP_CS,         //A periféria címtartományának elérését jelző jel.
   //input  wire                      Bus2IP_RNW,        //A művelet típusát (0: írás, 1: olvasás) jelző jel.
   input  wire [C_SLV_DWIDTH-1:0]   Bus2IP_Data,      //Írási adatbusz.
   input  wire [C_SLV_DWIDTH/8-1:0] Bus2IP_BE,        //Bájt engedélyező jelek (csak írás esetén érvényesek).
   input  wire [C_NUM_REG-1:0]      Bus2IP_RdCE,      //A regiszterek olvasás engedélyező jelei.
   input  wire [C_NUM_REG-1:0]      Bus2IP_WrCE,      //A regiszterek írás engedélyező jelei.
   output wire [C_SLV_DWIDTH-1:0]   IP2Bus_Data,      //Olvasási adatbusz.
   output wire                      IP2Bus_RdAck,     //Az olvasási műveletek nyugtázó jele.
   output wire                      IP2Bus_WrAck,     //Az írási műveletek nyugtázó jele.
   output wire                      IP2Bus_Error,     //Hibajelzés.
   
   //Itt kell megadni a többi saját portot.
   output wire sdcard_csn,
   output wire flash_csn,
   output wire lcd_csn,
   output wire sck,
   output wire mosi,
   output wire miso
);

wire rst = ~Bus2IP_Resetn;

wire [8:0] cmd;
wire sel;
wire [5:0] cnt;
wire valid;
wire ready;
wire [31:0] draw;

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
   .sel(sel),
   .cnt(cnt),
   .valid(valid),
   .ready(ready),
   .draw(draw)
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
        .valid(valid),
        .ready(ready),
        .cmd(cmd[7:0]),
        .mode(cmd[8])
    );

endmodule
