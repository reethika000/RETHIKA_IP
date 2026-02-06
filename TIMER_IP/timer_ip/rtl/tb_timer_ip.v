`timescale 1ns/1ps

module tb_timer_ip;

    reg         clk;
    reg         resetn;
    reg         sel;
    reg         we;
    reg [31:0]  addr;
    reg [31:0]  wdata;
    wire [31:0] rdata;
    wire        timeout;

    timer_ip dut (
        .clk     (clk),
        .resetn (resetn),
        .sel     (sel),
        .we      (we),
        .addr    (addr),
        .wdata   (wdata),
        .rdata   (rdata),
        .timeout (timeout)
    );

    always #5 clk = ~clk;

    task bus_write(input [31:0] waddr, input [31:0] data);
    begin
        @(posedge clk);
        sel   <= 1'b1;
        we    <= 1'b1;
        addr  <= waddr;
        wdata <= data;
        @(posedge clk);
        sel   <= 1'b0;
        we    <= 1'b0;
        addr  <= 32'b0;
        wdata <= 32'b0;
    end
    endtask

    task bus_read(input [31:0] raddr);
    begin
        @(posedge clk);
        sel  <= 1'b1;
        we   <= 1'b0;
        addr <= raddr;
        @(posedge clk);
        $display("TIME=%0t READ addr=0x%0h data=0x%0h",
                  $time, raddr, rdata);
        sel  <= 1'b0;
        addr <= 32'b0;
    end
    endtask

    initial begin
        // Dump waves
        $dumpfile("timer_ip.vcd");
        $dumpvars(0, tb_timer_ip);

        // Init
        clk    = 0;
        resetn = 0;
        sel    = 0;
        we     = 0;
        addr   = 0;
        wdata  = 0;

        
        #20;
        resetn = 1;

        
        $display("\n--- ONE-SHOT MODE TEST ---");

        bus_write(32'h04, 10);      // LOAD = 10
        bus_write(32'h00, 32'b01);  // CTRL: en=1, mode=0

        repeat (12) begin
            bus_read(32'h08);       // VALUE
            @(posedge clk);
        end

        bus_read(32'h0C);           // STATUS (timeout)

        
        $display("\n--- PERIODIC MODE TEST ---");

        bus_write(32'h04, 5);       // LOAD = 5
        bus_write(32'h00, 32'b11);  // CTRL: en=1, mode=1

        repeat (15) begin
            bus_read(32'h08);       // VALUE
            @(posedge clk);
        end

        $display("\nSimulation done.");
        #20;
        $finish;
    end

endmodule

