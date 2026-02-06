module timer_ip (
    input              sys_clk,
    input              rst_n,

    // Bus interface
    input              bus_sel,
    input              bus_wr,
    input  [31:0]      bus_addr,
    input  [31:0]      bus_wdata,
    output reg [31:0]  bus_rdata,

    // Output
    output reg         timer_irq
);

    // ------------------------------------------------------------
    // Register map (RENAMED + NEW OFFSETS)
    // ------------------------------------------------------------
    localparam TMR_CFG     = 32'h10;  // bit0: enable, bit1: periodic
    localparam TMR_RELOAD  = 32'h14;  // reload value
    localparam TMR_COUNT   = 32'h18;  // current counter (RO)
    localparam TMR_STATUS  = 32'h1C;  // bit0: timeout pulse

    // ------------------------------------------------------------
    // Internal registers
    // ------------------------------------------------------------
    reg        timer_en;
    reg        periodic_mode;
    reg [31:0] reload_val;
    reg [31:0] count_val;

    // ------------------------------------------------------------
    // Prescaler (1 tick per clock)
    // ------------------------------------------------------------
    wire tick = 1'b1;

    // ------------------------------------------------------------
    // Write logic
    // ------------------------------------------------------------
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_en       <= 1'b0;
            periodic_mode  <= 1'b0;
            reload_val     <= 32'd50;   // changed stimulus/default
        end
        else if (bus_sel && bus_wr) begin
            case (bus_addr[7:0])
                TMR_CFG: begin
                    timer_en      <= bus_wdata[0];
                    periodic_mode <= bus_wdata[1];
                end
                TMR_RELOAD: begin
                    reload_val <= bus_wdata;
                end
                default: ;
            endcase
        end
    end

    // ------------------------------------------------------------
    // Timer core + IRQ pulse
    // ------------------------------------------------------------
    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            count_val <= 32'd0;
            timer_irq <= 1'b0;
        end
        else begin
            timer_irq <= 1'b0;   // 1-cycle pulse

            if (timer_en && tick) begin
                if (count_val > 0) begin
                    count_val <= count_val - 1'b1;
                end
                else begin
                    timer_irq <= 1'b1;

                    if (periodic_mode)
                        count_val <= reload_val;
                    else
                        count_val <= 32'd0;
                end
            end
        end
    end

    // ------------------------------------------------------------
    // Read logic
    // ------------------------------------------------------------
    always @(*) begin
        case (bus_addr[7:0])
            TMR_CFG:     bus_rdata = {30'b0, periodic_mode, timer_en};
            TMR_RELOAD:  bus_rdata = reload_val;
            TMR_COUNT:   bus_rdata = count_val;
            TMR_STATUS:  bus_rdata = {31'b0, timer_irq};
            default:     bus_rdata = 32'b0;
        endcase
    end

endmodule

