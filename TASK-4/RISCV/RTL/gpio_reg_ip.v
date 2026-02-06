module gpio_reg_ip (
    input              clk,
    input              rst_n,

    input              bus_valid,
    input              bus_we,
    input      [31:0]  bus_addr,
    input      [31:0]  bus_wdata,
    output reg [31:0]  bus_rdata,

    input      [31:0]  gpio_in,
    output     [31:0]  gpio_out
);

    reg  [31:0] gpio_data;   // GPIO_DATA @ 0x00
    reg  [31:0] gpio_dir;    // GPIO_DIR  @ 0x04
    wire [31:0] gpio_read;   // GPIO_READ @ 0x08

    localparam GPIO_DATA_OFF = 8'h00;
    localparam GPIO_DIR_OFF  = 8'h04;
    localparam GPIO_READ_OFF = 8'h08;

    wire [7:0] addr_offset = bus_addr[7:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_data <= 32'h0;
            gpio_dir  <= 32'h0;
        end else if (bus_valid && bus_we) begin
            case (addr_offset)
                GPIO_DATA_OFF: gpio_data <= bus_wdata;
                GPIO_DIR_OFF:  gpio_dir  <= bus_wdata;
                default: ;
            endcase
        end
    end

    always @(*) begin
        case (addr_offset)
            GPIO_DATA_OFF: bus_rdata = gpio_data;
            GPIO_DIR_OFF:  bus_rdata = gpio_dir;
            GPIO_READ_OFF: bus_rdata = gpio_read;
            default:       bus_rdata = 32'h0;
        endcase
    end

    assign gpio_out = gpio_data & gpio_dir;

    assign gpio_read = (gpio_dir & gpio_data) |
                       (~gpio_dir & gpio_in);

endmodule

