module TIMER (
    input              clk_i,
    input              reset_n_i,

    // Bus interface
    input              cfg_sel_i,
    input              cfg_wr_i,
    input  [31:0]      cfg_addr_i,
    input  [31:0]      cfg_wdata_i,
    output reg [31:0]  cfg_rdata_o,

    // Output
    output reg         irq_o
);

    // ------------------------------------------------------------
    // Register map
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
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            timer_en       <= 1'b0;
            periodic_mode  <= 1'b0;
            reload_val     <= 32'd50;
        end
        else if (cfg_sel_i && cfg_wr_i) begin
            case (cfg_addr_i[7:0])
                TMR_CFG: begin
                    timer_en      <= cfg_wdata_i[0];
                    periodic_mode <= cfg_wdata_i[1];
                end
                TMR_RELOAD: begin
                    reload_val <= cfg_wdata_i;
                end
                default: ;
            endcase
        end
    end

    // ------------------------------------------------------------
    // Timer core + IRQ pulse
    // ------------------------------------------------------------
    always @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            count_val <= 32'd0;
            irq_o     <= 1'b0;
        end
        else begin
            irq_o <= 1'b0;   // 1-cycle pulse

            if (timer_en && tick) begin
                if (count_val > 0) begin
                    count_val <= count_val - 1'b1;
                end
                else begin
                    irq_o <= 1'b1;

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
        case (cfg_addr_i[7:0])
            TMR_CFG:     cfg_rdata_o = {30'b0, periodic_mode, timer_en};
            TMR_RELOAD:  cfg_rdata_o = reload_val;
            TMR_COUNT:   cfg_rdata_o = count_val;
            TMR_STATUS:  cfg_rdata_o = {31'b0, irq_o};
            default:     cfg_rdata_o = 32'b0;
        endcase
    end

endmodule
