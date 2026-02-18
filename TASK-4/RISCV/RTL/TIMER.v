module TIMER (
    input            clk,
    input            resetn,

    // Bus interface
    input            sel,
    input            we,
    input  [31:0]    addr,
    input  [31:0]    wdata,
    output reg [31:0] rdata,

    // Output
    output           timeout
);

    // ------------------------------------------------------------
    // Register map (offsets)
    // ------------------------------------------------------------
    localparam REG_CTRL  = 4'h0;  // 0x00
    localparam REG_LOAD  = 4'h4;  // 0x04
    localparam REG_VALUE = 4'h8;  // 0x08
    localparam REG_STAT  = 4'hC;  // 0x0C

    // ------------------------------------------------------------
    // Internal Registers
    // ------------------------------------------------------------
    reg        en;
    reg        mode;           // 0 = one-shot, 1 = periodic
    reg [31:0] load_reg;
    reg [31:0] value_reg;

    reg        timeout_flag;   // Sticky timeout
    reg        en_d;           // Delayed EN for edge detection

    // ------------------------------------------------------------
    // Enable rising edge detection (LOAD-ON-ENABLE)
    // ------------------------------------------------------------
    wire en_rise = en & ~en_d;

    always @(posedge clk or negedge resetn) begin
        if (!resetn)
            en_d <= 1'b0;
        else
            en_d <= en;
    end

    // ------------------------------------------------------------
    // Write logic
    // ------------------------------------------------------------
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            en       <= 1'b0;
            mode     <= 1'b0;
            load_reg <= 32'd0;
        end
        else if (sel && we) begin
            case (addr[3:0])
                REG_CTRL: begin
                    en   <= wdata[0];
                    mode <= wdata[1];
                end

                REG_LOAD: begin
                    load_reg <= wdata;
                end

                // Write-1-to-clear TIMEOUT
                REG_STAT: begin
                    if (wdata[0])
                        timeout_flag <= 1'b0;
                end

                default: ;
            endcase
        end
    end

    // ------------------------------------------------------------
    // Timer Core Logic (Correct Semantics)
    // ------------------------------------------------------------
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            value_reg    <= 32'd0;
            timeout_flag <= 1'b0;
        end
        else begin

            // Load value when EN transitions 0 -> 1
            if (en_rise) begin
                value_reg <= load_reg;
            end

            // Countdown logic
            else if (en && (value_reg > 0)) begin
                value_reg <= value_reg - 1'b1;
            end

            // When countdown reaches zero
            else if (en && (value_reg == 0) && !timeout_flag) begin
                timeout_flag <= 1'b1;   // Sticky set

                if (mode) begin
                    // Periodic mode: reload automatically
                    value_reg <= load_reg;
                end
                else begin
                    // One-shot mode: stop timer
                    en <= 1'b0;         // Auto-clear enable
                end
            end
        end
    end

    // ------------------------------------------------------------
    // Read logic
    // ------------------------------------------------------------
    always @(*) begin
        case (addr[3:0])
            REG_CTRL:  rdata = {30'b0, mode, en};
            REG_LOAD:  rdata = load_reg;
            REG_VALUE: rdata = value_reg;
            REG_STAT:  rdata = {31'b0, timeout_flag};
            default:   rdata = 32'd0;
        endcase
    end

    // ------------------------------------------------------------
    // Output
    // ------------------------------------------------------------
    assign timeout = timeout_flag;

endmodule
