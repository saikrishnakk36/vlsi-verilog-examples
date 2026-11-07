// dff_async.v  -- D flip-flop with asynchronous active-low reset
module dff_async (
    input  wire clk,       // clock
    input  wire rst_n,     // asynchronous reset, active low
    input  wire d,         // data input
    output reg  q          // registered output
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;     // reset wins immediately, no clock needed
        else
            q <= d;        // sample d on the rising clock edge
    end
endmodule

// Testbench
module tb;
    reg  clk, rst_n, d;
    wire q;

    dff_async dut (.clk(clk), .rst_n(rst_n), .d(d), .q(q));

    // 10 ns clock: rising edges at t = 5, 15, 25, 35, ...
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display(" time | rst_n d | q");
        $monitor("%5t |   %b   %b | %b", $time, rst_n, d, q);

        rst_n = 1'b0; d = 1'b1;   // start held in reset
        #12 rst_n = 1'b1;         // release reset at t=12 (between edges)
        // edge at t=15 captures d=1 -> q=1
        #11 rst_n = 1'b0;         // t=23: assert reset BETWEEN edges -> q drops now
        #4  rst_n = 1'b1;         // t=27: release again
        // edge at t=35 captures d=1 -> q=1
        #13 d = 1'b0;             // t=40
        // edge at t=45 captures d=0 -> q=0
        #10 $finish;
    end
endmodule
