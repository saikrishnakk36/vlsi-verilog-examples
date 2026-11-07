// mod_n_counter.v  -- parameterized Mod-N counter with terminal-count output
// Counts 0, 1, ... , N-1, then wraps back to 0. `tc` is high on the last state.
module mod_n_counter #(
    parameter N     = 10,                 // modulus: number of distinct states
    parameter WIDTH = (N <= 2) ? 1 : $clog2(N)
)(
    input  wire             clk,
    input  wire             rst_n,        // active-low synchronous-free async reset
    input  wire             en,           // count enable
    output reg  [WIDTH-1:0] count,
    output wire             tc            // terminal count: count == N-1
);
    assign tc = (count == (N-1));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (tc)
                count <= {WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end
endmodule

// tb_mod10.v -- testbench exercising the counter as a mod-10 (decade) counter
module tb_mod10;
    localparam N = 10;

    reg             clk;
    reg             rst_n;
    reg             en;
    wire [3:0]      count;
    wire            tc;

    integer         wraps;

    mod_n_counter #(.N(N)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .count (count),
        .tc    (tc)
    );

    // 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n  = 1'b0;
        en     = 1'b0;
        wraps  = 0;
        #12;
        rst_n  = 1'b1;   // release reset
        en     = 1'b1;   // start counting
    end

    // Log every rising edge and tally the complete decades.
    always @(posedge clk) begin
        if (rst_n && en) begin
            $display("t=%0t  count=%0d  tc=%b", $time, count, tc);
            if (tc) wraps = wraps + 1;
        end
    end

    initial begin
        // Run long enough to see two full 0..9 cycles.
        #230;
        $display("Completed %0d full decade wraps (expected 2).", wraps);
        $finish;
    end
endmodule
