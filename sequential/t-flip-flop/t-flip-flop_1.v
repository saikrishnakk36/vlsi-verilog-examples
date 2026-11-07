// T flip-flop: behavioral, positive-edge clock, active-low async reset.
// t = 1 -> toggle Q on the clock edge; t = 0 -> hold Q.
module t_ff (
    input  wire clk,     // clock
    input  wire rst_n,   // active-low asynchronous reset
    input  wire t,       // toggle enable: 1 = toggle, 0 = hold
    output reg  q        // stored state
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;   // async clear, independent of clk
        else if (t)
            q <= ~q;     // toggle
        else
            q <= q;      // hold
    end
endmodule

// Testbench: shows reset, toggling, holding, then an async reset mid-run.
module t_ff_tb;
    reg  clk, rst_n, t;
    wire q;

    t_ff dut (.clk(clk), .rst_n(rst_n), .t(t), .q(q));

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display("  time rst_n t q   note");
        $monitor("%5t    %b   %b %b", $time, rst_n, t, q);
        rst_n = 1'b0; t = 1'b0;          // hold in async reset
        #12 rst_n = 1'b1;                // release reset between edges
        $display(">> t=1: expect Q to toggle every rising edge");
        t = 1'b1;
        #40;                             // ~4 clock edges of toggling
        $display(">> t=0: expect Q to hold its value");
        t = 1'b0;
        #20;                             // 2 edges, no change
        $display(">> t=1 again: resume toggling");
        t = 1'b1;
        #20;
        $display(">> async reset asserted (not on a clock edge)");
        rst_n = 1'b0;                    // clears Q immediately
        #8;
        $finish;
    end
endmodule

