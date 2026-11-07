// latch_vs_dff.v  -- level-sensitive D latch vs edge-triggered D flip-flop
module d_latch (
    input  wire en,        // enable (level sensitive)
    input  wire d,
    output reg  q
);
    always @(*) begin          // combinational sensitivity: en and d
        if (en)
            q = d;             // transparent while en is high
        // else: q holds its value (this is the latch)
    end
endmodule

module d_ff (
    input  wire clk,
    input  wire d,
    output reg  q
);
    always @(posedge clk)
        q <= d;                // captures d only on the rising edge
endmodule

// Testbench
module tb;
    reg  clk, d;
    wire q_latch, q_ff;

    d_latch u_latch (.en(clk), .d(d), .q(q_latch));  // reuse clk as the latch enable
    d_ff    u_ff    (.clk(clk), .d(d), .q(q_ff));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display(" time | clk d | latch  ff");
        $monitor("%5t |  %b  %b |   %b    %b", $time, clk, d, q_latch, q_ff);

        d = 1'b0;
        #7  d = 1'b1;   // d changes WHILE clk is high -> latch follows, ff waits
        #2  d = 1'b0;   // d changes again while clk still high -> latch follows again
        #6  d = 1'b1;   // d changes while clk is low -> latch holds, ff will take it next edge
        #10 d = 1'b0;
        #10 $finish;
    end
endmodule
