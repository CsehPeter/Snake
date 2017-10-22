`timescale 1ns / 1ps

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
   //input  wire [0:0]                Bus2IP_CS,         //A periféria címtartományának elérését jelz? jel.
   //input  wire                      Bus2IP_RNW,        //A m?velet típusát (0: írás, 1: olvasás) jelz? jel.
   input  wire [C_SLV_DWIDTH-1:0]   Bus2IP_Data,      //Írási adatbusz.
   input  wire [C_SLV_DWIDTH/8-1:0] Bus2IP_BE,        //Bájt engedélyez? jelek (csak írás esetén érvényesek).
   input  wire [C_NUM_REG-1:0]      Bus2IP_RdCE,      //A regiszterek olvasás engedélyez? jelei.
   input  wire [C_NUM_REG-1:0]      Bus2IP_WrCE,      //A regiszterek írás engedélyez? jelei.
   output wire [C_SLV_DWIDTH-1:0]   IP2Bus_Data,      //Olvasási adatbusz.
   output wire                      IP2Bus_RdAck,     //Az olvasási m?veletek nyugtázó jele.
   output wire                      IP2Bus_WrAck,     //Az írási m?veletek nyugtázó jele.
   output wire                      IP2Bus_Error,     //Hibajelzés.
   
   //Itt kell megadni a többi saját portot.
   input wire [2:0]                 btn,
   output wire                      irq
);

//Clock and reset
wire clk = Bus2IP_Clk;
wire rst = ~Bus2IP_Resetn;

//Synchronisation
reg [2:0] sync_reg [1:0];
always @(posedge clk) begin
   if (rst) begin
      sync_reg[1] <= 0;
      sync_reg[0] <= 0;
   end else begin
      sync_reg[1] <= sync_reg[0];
      sync_reg[0] <= btn;
   end
end

//Clock divider
reg [17:0] cntr;
always @(posedge clk) begin
   if (rst)
      cntr <= 18'd0;
   else
      cntr <= cntr + 1;
end

//Sample signal
wire sample = cntr == 18'd0;

//Button Register(base addr + 0x00), Read Only
//Reading cleares the register
reg [(C_SLV_DWIDTH - 1):0] btn_reg;
always @(posedge clk) begin
   if (rst)
      btn_reg <= 0;
   else begin
      if(Bus2IP_RdCE[1] && &Bus2IP_BE) //Highest RdCE -> Lowest address register
         btn_reg <= 0;
      else if(sample == 1) begin
         btn_reg <= sync_reg[1];
      end
   end
end

//Interrupt Register(base addr + 0x04), Read/Write
reg IE;
reg IF;
wire [(C_SLV_DWIDTH - 1):0] it_reg = {30'd0, IE, IF};
always @(posedge clk) begin
   if (rst) begin
      IE <= 0;
      IF <= 0;
   end
   else if (Bus2IP_WrCE[0] && &Bus2IP_BE) begin //Write interrupt bits
      IE <= Bus2IP_Data[1];
      if (Bus2IP_Data[0] == 1'b1)
         IF <= 0;
   end else begin
      IF <= sample & |sync_reg[1];
   end
end

//Interrupt Request
assign irq = IE & IF;

//IP2Bus_Data Multiplexer
reg [(C_SLV_DWIDTH - 1):0] data;
always @(*) begin
   case(Bus2IP_RdCE)
       2'b01: data <= it_reg;
       2'b10: data <= btn_reg;
       default: data <= 0;
   endcase
end

//Az IPIF felé men? jelek meghajtása.
assign IP2Bus_Data  = data;
assign IP2Bus_WrAck = |Bus2IP_WrCE;
assign IP2Bus_RdAck = |Bus2IP_RdCE;
assign IP2Bus_Error = 1'b0;

endmodule
