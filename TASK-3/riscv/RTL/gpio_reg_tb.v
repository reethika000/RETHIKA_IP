tb code: 

`timescale 1ns/1ps

module tb_gpio_reg_ip;

    // --------------------------------------------------
    // Clock & Reset
    // --------------------------------------------------
    reg clk;
    reg rst_n;

    // --------------------------------------------------
    // Bus interface
    // --------------------------------------------------
    reg         bus_valid;
    reg         bus_we;
    reg [31:0]  bus_addr;
    reg [31:0]  bus_wdata;
    wire [31:0] bus_rdata;

    // --------------------------------------------------
    // GPIO
    // --------------------------------------------------
    reg  [31:0] gpio_in;
    wire [31:0] gpio_out;

    // --------------------------------------------------
    // DUT instantiation
    // --------------------------------------------------
    gpio_reg_ip dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .bus_valid (bus_valid),
        .bus_we    (bus_we),
        .bus_addr  (bus_addr),
        .bus_wdata (bus_wdata),
        .bus_rdata (bus_rdata),
        .gpio_in   (gpio_in),
        .gpio_out  (gpio_out)
    );

    // --------------------------------------------------
    // Clock generation (100 MHz)
    // --------------------------------------------------
    always #5 clk = ~clk;

    // --------------------------------------------------
    // Bus write task
    // --------------------------------------------------
    task bus_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            bus_valid <= 1'b1;
            bus_we    <= 1'b1;
            bus_addr  <= addr;
            bus_wdata <= data;

            @(posedge clk);
            bus_valid <= 1'b0;
            bus_we    <= 1'b0;
            bus_addr  <= 32'h0;
            bus_wdata <= 32'h0;
        end
    endtask

    // --------------------------------------------------
    // Bus read task
    // --------------------------------------------------
    task bus_read;
        input [31:0] addr;
        begin
            @(posedge clk);
            bus_valid <= 1'b1;
            bus_we    <= 1'b0;
            bus_addr  <= addr;

            @(posedge clk);
            bus_valid <= 1'b0;
            bus_addr  <= 32'h0;
        end
    endtask

    // --------------------------------------------------
    // Test sequence + waveform dump
    // --------------------------------------------------
    initial begin
        // ---------------- Waveform dump ----------------
        $dumpfile("gpio_ctrl_ip.vcd");
        $dumpvars(0, tb_gpio_ctrl_ip);

        // ---------------- Init ----------------
        clk       = 0;
        rst_n     = 0;
        bus_valid = 0;
        bus_we    = 0;
        bus_addr  = 0;
        bus_wdata = 0;
        gpio_in   = 32'h0;

        // ---------------- Reset ----------------
        #20;
        rst_n = 1;

        $display("---- GPIO IP TEST START ----");

        // ------------------------------------------
        // 1. Set GPIO_DIR (lower 16 output)
        // ------------------------------------------
        bus_write(32'h0000_0004, 32'h0000_FFFF);
        $display("GPIO_DIR written");

        // ------------------------------------------
        // 2. Write GPIO_DATA
        // ------------------------------------------
        bus_write(32'h0000_0000, 32'hA5A5_5A5A);
        $display("GPIO_DATA written");

        // ------------------------------------------
        // 3. Drive GPIO inputs (upper 16 bits)
        // ------------------------------------------
        gpio_in = 32'hFFFF_0000;
        #10;

        // ------------------------------------------
        // 4. Read GPIO_DATA
        // ------------------------------------------
        bus_read(32'h0000_0000);
        #1;
        $display("Read GPIO_DATA = %h", bus_rdata);

        // ------------------------------------------
        // 5. Read GPIO_DIR
        // ------------------------------------------
        bus_read(32'h0000_0004);
        #1;
        $display("Read GPIO_DIR  = %h", bus_rdata);

        // ------------------------------------------
        // 6. Read GPIO_READ
        // ------------------------------------------
        bus_read(32'h0000_0008);
        #1;
        $display("Read GPIO_READ = %h", bus_rdata);

        // ------------------------------------------
        // 7. Observe GPIO_OUT
        // ------------------------------------------
        $display("GPIO_OUT = %h", gpio_out);

        #50;
        $display("---- completed ----");
        $finish;
    end

endmodule
