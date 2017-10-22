`timescale 1ns / 1ps

module btn_sim();

    parameter C_SLV_DWIDTH = 32;
    parameter C_NUM_REG    = 2;

    reg                         tb_Bus2IP_Clk;
    reg                         tb_Bus2IP_Resetn;
    
    reg [C_SLV_DWIDTH-1 : 0]    tb_Bus2IP_Data;
    reg [C_SLV_DWIDTH/8-1 : 0]  tb_Bus2IP_BE;
    reg [C_NUM_REG-1 : 0]       tb_Bus2IP_RdCE;
    reg [C_NUM_REG-1 : 0]       tb_Bus2IP_WrCE;
    
    wire [C_SLV_DWIDTH-1 : 0]   tb_IP2Bus_Data;
    wire                        tb_IP2Bus_RdAck;
    wire                        tb_IP2Bus_WrAck;
    wire                        tb_IP2Bus_Error;
    
    reg [2:0]                   tb_btn;
    wire                        tb_irq;

    user_logic btn_inst(
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
        .btn(tb_btn),
        .irq(tb_irq)
    );
    
    initial begin
        tb_Bus2IP_Clk <= 0;
        tb_Bus2IP_Resetn <= 1;
        tb_Bus2IP_Data <= 0;
        tb_Bus2IP_BE <= 0;
        tb_Bus2IP_RdCE <= 0;
        tb_Bus2IP_WrCE <= 0;
        
        #20
        tb_Bus2IP_Resetn <= 0;
        
        #20
        tb_Bus2IP_Resetn <= 1;
        
        //STIMULUS
        #5000000
        it_wr(32'hFFFFFFFE);
        
        #5000000 //5ms
        btn_rd();
        
        #5000000
        btn_rd();

        #5000000
        btn_rd();

        #5000000
        btn_rd();
        
        #5000000
        it_rd();
    end

    //GENERATE CLOCK (50MHz)
    always #10 tb_Bus2IP_Clk = ~tb_Bus2IP_Clk;
    
    //GENERATE BUTTON STIMULUS (Johnson counter)
    reg [2:0] cntr;
    always @ (posedge tb_Bus2IP_Clk)
    begin
        if(tb_Bus2IP_Resetn == 0)
            cntr <= 0;
        else begin
            cntr <= {cntr[1:0], ~cntr[2]};
            tb_btn <= cntr;
        end
    end
    
    //BUTTON READ TASK
    task btn_rd;
    begin
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_RdCE[1] <= 1'b1;
        tb_Bus2IP_BE <= 4'hF;
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_RdCE <= 0;
        tb_Bus2IP_BE <= 0;
    end
    endtask
            
    //INTERRUPT WRITE TASK
    task it_wr;
        input [0 : C_SLV_DWIDTH - 1] data;
    begin
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_WrCE[0] <= 1'b1;
        tb_Bus2IP_Data <= data;
        tb_Bus2IP_BE <= 4'hF;
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_WrCE <= 0;
        tb_Bus2IP_Data <= 0;
        tb_Bus2IP_BE <= 0;
    end
    endtask
        
    //INTERRUPT READ TASK
    task it_rd;
    begin
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_RdCE[0] <= 1'b1;
        tb_Bus2IP_BE <= 4'hF;
        @ (posedge tb_Bus2IP_Clk)
        tb_Bus2IP_RdCE <= 0;
        tb_Bus2IP_BE <= 0;
    end
    endtask

endmodule
