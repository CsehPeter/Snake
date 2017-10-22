`uselib lib=unisims_ver
`uselib lib=proc_common_v3_00_a

module user_logic #(
   //Az IPIF interfészhez tartozó paraméterek.
   parameter C_NUM_REG                      = 1,		//Az IPIF által dekódolt 32 bites regiszterek száma.
   parameter C_SLV_DWIDTH                   = 32		//Az adatbusz szélessége bitekben.
   
   //Itt kell megadni a többi saját paramétert.
) (
   //Az IPIF interfészhez tartozó portok. Ha a Create or Import Peripheral
   //Wizard-ban nem jelöltük be a memória interfészhez tartozó Bus2IP_Addr,
   //Bus2IP_CS és Bus2IP_RNW jelek hozzáadását, akkor ezeket innen töröljük.
   input  wire                      Bus2IP_Clk,			//Órajel.
   input  wire                      Bus2IP_Resetn,		//Aktív alacsony reset jel.
   //input  wire [31:0]               Bus2IP_Addr,		//Címbusz.
   //input  wire [0:0]                Bus2IP_CS,			//A periféria címtartományának elérését jelző jel.
   //input  wire                      Bus2IP_RNW,			//A művelet típusát (0: írás, 1: olvasás) jelző jel.
   input  wire [C_SLV_DWIDTH-1:0]   Bus2IP_Data,		//Írási adatbusz.
   input  wire [C_SLV_DWIDTH/8-1:0] Bus2IP_BE,			//Bájt engedélyező jelek (csak írás esetén érvényesek).
   input  wire [C_NUM_REG-1:0]      Bus2IP_RdCE,		//A regiszterek olvasás engedélyező jelei.
   input  wire [C_NUM_REG-1:0]      Bus2IP_WrCE,		//A regiszterek írás engedélyező jelei.
   output wire [C_SLV_DWIDTH-1:0]   IP2Bus_Data,		//Olvasási adatbusz.
   output wire                      IP2Bus_RdAck,		//Az olvasási műveletek nyugtázó jele.
   output wire                      IP2Bus_WrAck,		//Az írási műveletek nyugtázó jele.
   output wire                      IP2Bus_Error,		//Hibajelzés.
   
   //Itt kell megadni a többi saját portot.
);


//Az IPIF felé menő jelek meghajtása.
assign IP2Bus_Data  = 
assign IP2Bus_WrAck = 
assign IP2Bus_RdAck = 
assign IP2Bus_Error = 1'b0;

endmodule
