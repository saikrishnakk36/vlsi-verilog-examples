// Galois (internal-XOR) LFSR, parameterized width + polynomial mask
module lfsr_galois #(
    parameter WIDTH = 8,
    parameter [WIDTH-1:0] POLY = 8'hB8,   // same maximal polynomial, Galois form
    parameter [WIDTH-1:0] SEED = 8'h01
)(
    input  wire              clk,
    input  wire              rst_n,
    output wire [WIDTH-1:0]  state,
    output wire              prbs
);
    reg [WIDTH-1:0] lfsr;
    wire out_bit = lfsr[0];               // bit shifted out drives the taps

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            lfsr <= SEED;
        else if (out_bit)
            lfsr <= (lfsr >> 1) ^ POLY;   // XOR polynomial into the register
        else
            lfsr <= (lfsr >> 1);
    end

    assign state = lfsr;
    assign prbs  = out_bit;
endmodule

module tb_lfsr_galois;
    localparam WIDTH = 8;
    reg clk = 0, rst_n = 0;
    wire [WIDTH-1:0] state;
    wire prbs;
    integer count;
    reg [WIDTH-1:0] seed_val;

    lfsr_galois #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .state(state), .prbs(prbs)
    );

    always #5 clk = ~clk;

    initial begin
        count = 0;
        @(negedge clk) rst_n = 1;
        @(posedge clk);
        seed_val = state;
        $display("SEED      = 0x%02h, POLY = 0xB8", seed_val);
        $display("step  state  prbs");
        begin : walk
            integer i;
            for (i = 0; i < (1<<WIDTH); i = i + 1) begin
                if (i < 8)
                    $display(" %0d    0x%02h    %b", i, state, prbs);
                @(posedge clk);
                count = count + 1;
                if (state == seed_val) disable walk;
            end
        end
        $display("PERIOD    = %0d (max possible = %0d)", count, (1<<WIDTH)-1);
        $finish;
    end
endmodule
