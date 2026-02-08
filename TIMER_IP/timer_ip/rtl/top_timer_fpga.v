`default_nettype none

module top_timer_fpga (
    input  wire clk,        // FPGA clock
    input  wire rst_n,        // Active-low reset button
    output wire led          // LED shows timeout pulse
);

    // ------------------------------------------------------------
    // Wires to timer IP
    // ------------------------------------------------------------
    reg         sel;
    reg         we;
    reg [31:0]  addr;
    reg [31:0]  wdata;
    wire [31:0] rdata;
    wire        timeout;

    // ------------------------------------------------------------
    // Simple FSM to configure timer once after reset
    // ------------------------------------------------------------
    localparam S_IDLE  = 2'd0;
    localparam S_LOAD  = 2'd1;
    localparam S_CTRL  = 2'd2;
    localparam S_DONE  = 2'd3;

    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            sel   <= 1'b0;
            we    <= 1'b0;
            addr  <= 32'd0;
            wdata <= 32'd0;
        end else begin
            sel <= 1'b0;
            we  <= 1'b0;

            case (state)

                // ----------------------------------------
                // Write LOAD register
                // ----------------------------------------
                S_IDLE: begin
                    sel   <= 1'b1;
                    we    <= 1'b1;
                    addr  <= 32'h04;        // REG_LOAD
                    wdata <= 32'd25_000_000; // ~0.5s @ 50MHz
                    state <= S_LOAD;
                end

                // ----------------------------------------
                // Write CTRL register (enable + periodic)
                // ----------------------------------------
                S_LOAD: begin
                    sel   <= 1'b1;
                    we    <= 1'b1;
                    addr  <= 32'h00;        // REG_CTRL
                    wdata <= 32'b11;        // en=1, mode=1
                    state <= S_CTRL;
                end

                // ----------------------------------------
                // Done — timer runs forever
                // ----------------------------------------
                S_CTRL: begin
                    state <= S_DONE;
                end

                S_DONE: begin
                    // No bus activity
                end

            endcase
        end
    end

    // ------------------------------------------------------------
    // Timer IP instance
    // ------------------------------------------------------------
    timer_ip u_timer (
        .clk     (clk),
        .resetn (rst_n),

        .sel     (sel),
        .we      (we),
        .addr    (addr),
        .wdata   (wdata),
        .rdata   (rdata),

        .timeout (timeout)
    );

    // ------------------------------------------------------------
    // LED output
    // ------------------------------------------------------------
    assign led = timeout;

endmodule
