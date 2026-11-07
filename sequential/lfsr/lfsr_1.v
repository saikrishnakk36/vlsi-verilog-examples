// Fibonacci (external-XOR) LFSR, parameterized width + tap mask
module lfsr_fibonacci #(
    parameter WIDTH = 8,
    parameter [WIDTH-1:0] TAPS = 8'hB8,   // x^8+x^6+x^5+x^4+1 -> maximal length
    parameter [WIDTH-1:0] SEED = 8'h01
)(
    input  wire              clk,
    input  wire              rst_n,
    output wire [WIDTH-1:0]  state,
    output wire              prbs      // serial output bit
);
    reg [WIDTH-1:0] lfsr;
    wire feedback = ^(lfsr & TAPS);     // reduction-XOR of the tapped bits

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            lfsr <= SEED;               // seed must be non-zero
        else
            lfsr <= {lfsr[WIDTH-2:0], feedback};
    end

    assign state = lfsr;
    assign prbs  = lfsr[WIDTH-1];
endmodule

module tb_lfsr_fibonacci;
    localparam WIDTH = 8;
    reg clk = 0, rst_n = 0;
    wire [WIDTH-1:0] state;
    wire prbs;
    integer count;
    reg [WIDTH-1:0] seed_val;

    lfsr_fibonacci #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .state(state), .prbs(prbs)
    );

    always #5 clk = ~clk;

    initial begin
        count = 0;
        @(negedge clk) rst_n = 1;       // release reset
        @(posedge clk);                 // register now holds SEED
        seed_val = state;
        $display("SEED      = 0x%02h", seed_val);
        $display("step  state  prbs");
        // walk the sequence until the seed recurs
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
