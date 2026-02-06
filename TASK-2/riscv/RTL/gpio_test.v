`timescale 1ns/1ps
`default_nettype none

module tb_gpio_ip;

    reg         tb_clk;
    reg         tb_rst_n;
    reg         tb_wr_en;
    reg         tb_rd_en;
    reg  [31:0] tb_wdata;
    wire [31:0] tb_rdata;
    wire [31:0] tb_gpio_out;

    gpio_ip dut (
        .clk      (tb_clk),
        .resetn   (tb_rst_n),
        .we       (tb_wr_en),
        .re       (tb_rd_en),
        .wdata    (tb_wdata),
        .rdata    (tb_rdata),
        .gpio_out (tb_gpio_out)
    );

    always #5 tb_clk = ~tb_clk;

    task write_gpio;
        input [31:0] data;
        begin
            @(posedge tb_clk);
            tb_wr_en <= 1'b1;
            tb_rd_en <= 1'b0;
            tb_wdata <= data;

            @(posedge tb_clk);
            tb_wr_en <= 1'b0;
            tb_wdata <= 32'b0;
        end
    endtask

    task read_gpio;
        begin
            @(posedge tb_clk);
            tb_rd_en <= 1'b1;
            tb_wr_en <= 1'b0;

            @(posedge tb_clk);
            tb_rd_en <= 1'b0;
        end
    endtask

    initial begin
        $dumpfile("gpio_ip.vcd");
        $dumpvars(0, tb_gpio_ip);

        tb_clk    = 0;
        tb_rst_n  = 0;
        tb_wr_en  = 0;
        tb_rd_en  = 0;
        tb_wdata  = 32'b0;

        #20;
        tb_rst_n = 1;

        $display("---- GPIO IP TEST START ----");

        write_gpio(32'h1234_FF3F);
        $display("Wrote GPIO = %h", 32'h1234_FF3F);

        read_gpio;
        #1;
        $display("Read GPIO  = %h", tb_rdata);

        $display("GPIO_OUT   = %h", tb_gpio_out);

        write_gpio(32'h111F_ABCD);
        $display("Wrote GPIO = %h", 32'h111F_ABCD);

        read_gpio;
        #1;
        $display("Read GPIO  = %h", tb_rdata);

        #40;
        $display("---- COMPLETED ----");
        $finish;
    end

endmodule

