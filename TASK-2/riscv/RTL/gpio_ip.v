`default_nettype none

module gpio_ip (
    input         clk,
    input         resetn,
    input         wr_en,        
    input         rd_en,        
    input  [31:0] wr_data,
    output [31:0] rd_data,
    output [31:0] gpio_out
);

    reg [31:0] gpio_reg;

    always @(posedge clk) begin
        if (!resetn) begin
            gpio_reg <= 32'b0;
        end else if (wr_en) begin
            gpio_reg <= wr_data;
        end
    end

    assign rd_data = rd ? gpio_reg : 32'b0;

    assign gpio_out = gpio_reg;

endmodule
