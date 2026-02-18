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
        .resetn  (resetn),
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
        addr  <= 32'd0;
        wdata <= 32'd0;
    end
    endtask

    
    task bus_read(input [31:0] raddr);
    begin
        @(posedge clk);
        sel  <= 1'b1;
        we   <= 1'b0;
        addr <= raddr;

        @(posedge clk);
        $display("TIME=%0t | READ [0x%0h] = 0x%0h",
                  $time, raddr, rdata);

        sel  <= 1'b0;
        addr <= 32'd0;
    end
    endtask

  
    initial begin
        
        $dumpfile("timer_ip.vcd");
        $dumpvars(0, tb_timer_ip);

        
        clk    = 0;
        resetn = 0;
        sel    = 0;
        we     = 0;
        addr   = 0;
        wdata  = 0;

        #30;
        resetn = 1;

        
        $display("\n==============================");
        $display(" ONE-SHOT MODE TEST ");
        $display("==============================");

        bus_write(32'h04, 5);        // LOAD = 5
        bus_write(32'h00, 32'b01);   // CTRL: EN=1, MODE=0

        repeat (8) begin
            bus_read(32'h08);        // VALUE
            @(posedge clk);
        end

        // Timeout must be sticky
        bus_read(32'h0C);            // STATUS

        // Clear TIMEOUT (W1C)
        bus_write(32'h0C, 32'h1);
        bus_read(32'h0C);

        // VALUE must remain 0 (one-shot stop)
        repeat (3) begin
            bus_read(32'h08);
            @(posedge clk);
        end

        $display("\n==============================");
        $display(" PERIODIC MODE TEST ");
        $display("==============================");

        bus_write(32'h04, 3);        // LOAD = 3
        bus_write(32'h00, 32'b11);   // CTRL: EN=1, MODE=1

        repeat (12) begin
            bus_read(32'h08);        // VALUE
            bus_read(32'h0C);        // STATUS

            // Clear timeout if set
            if (timeout) begin
                $display("Clearing TIMEOUT...");
                bus_write(32'h0C, 32'h1);
            end

            @(posedge clk);
        end

       
        $display("\nSimulation completed successfully.");
        #50;
        $finish;
    end

endmodule
