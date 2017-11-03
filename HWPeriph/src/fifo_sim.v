`timescale 1ns / 1ps

module fifo_sim();

    parameter DEPTH = 36;
    parameter WIDTH = 9;

    reg tb_clk;
    reg tb_rst;

    reg [(WIDTH - 1) : 0] tb_din;
    wire [(WIDTH - 1) : 0] tb_dout;

    reg tb_rd;
    reg tb_wr;

    wire tb_empty;
    wire tb_full;

    fifo fifo_inst(
        .clk(tb_clk),
        .rst(tb_rst),
        .din(tb_din),
        .dout(tb_dout),
        .rd(tb_rd),
        .wr(tb_wr),
        .empty(tb_empty),
        .full(tb_full)
    );
    
    initial begin
        tb_clk <= 0;
        tb_rst <= 1;
        tb_din <= 0;
        tb_rd <= 0;
        tb_wr <= 0;
        
        #20
        tb_rst <= 0;
        
        #200
        //STIMULUS
        
        repeat (40) begin
            write(9'h0A5);
        end

        #40
        repeat (40) begin
            read();
        end
        
    end

    //GENERATE CLOCK (50MHz)
    always #10 tb_clk = ~tb_clk;
    
    //WRITE COMMAND
    task write;
        input [8:0] item;
    begin
        @ (posedge tb_clk)
        tb_wr <= 1'b1;
        tb_din <= item;
        @ (posedge tb_clk)
        tb_wr <= 1'b0;
    end
    endtask

    //READ COMMAND
    task read;
    begin
        @ (posedge tb_clk)
        tb_rd <= 1'b1;
        @ (posedge tb_clk)
        tb_rd <= 1'b0;
    end
    endtask

endmodule
