// dff_sync.v  -- D flip-flop with synchronous active-low reset
module dff_sync (
    input  wire clk,       // clock
    input  wire rst_n,     // synchronous reset, active low
    input  wire d,         // data input
    output reg  q          // registered output
);
    always @(posedge clk) begin    // ONLY the clock in the sensitivity list
        if (!rst_n)
            q <= 1'b0;             // reset is sampled like any other input
        else
            q <= d;
    end
endmodule

// Testbench
module tb;
    reg  clk, rst_n, d;
    wire q;

    dff_sync dut (.clk(clk), .rst_n(rst_n), .d(d), .q(q));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display(" time | rst_n d | q");
        $monitor("%5t |   %b   %b | %b", $time, rst_n, d, q);

        rst_n = 1'b0; d = 1'b1;   // reset asserted
        #10 d = 1'b1;             // first edge: q goes 0 (reset)
        #10 rst_n = 1'b1;         // release reset
        #10 d = 1'b0;
        #3  rst_n = 1'b0;         // deassert between edges...
        #2  rst_n = 1'b1;         // ...and reassert before the edge: glitch ignored
        #10 d = 1'b1;
        #10 $finish;
    end
endmodule
