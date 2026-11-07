// Reusable T flip-flop (same core cell as before).
module t_ff (
    input  wire clk,
    input  wire rst_n,
    input  wire t,
    output reg  q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else if (t)
            q <= ~q;
    end
endmodule

// 3-bit synchronous UP counter built from T flip-flops.
// All FFs share one clock. A bit toggles only when all lower bits are 1.
module counter3 (
    input  wire clk,
    input  wire rst_n,
    output wire [2:0] q
);
    t_ff b0 (.clk(clk), .rst_n(rst_n), .t(1'b1),         .q(q[0]));
    t_ff b1 (.clk(clk), .rst_n(rst_n), .t(q[0]),         .q(q[1]));
    t_ff b2 (.clk(clk), .rst_n(rst_n), .t(q[0] & q[1]),  .q(q[2]));
endmodule

module counter3_tb;
    reg  clk, rst_n;
    wire [2:0] q;

    counter3 dut (.clk(clk), .rst_n(rst_n), .q(q));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        #12 rst_n = 1'b1;
        $display("  time | q2 q1 q0 = decimal");
        $monitor("%5t  |  %b  %b  %b  =  %0d", $time, q[2], q[1], q[0], q);
        #90;                   // let it count a full 0->7->0 wrap
        $finish;
    end
endmodule

