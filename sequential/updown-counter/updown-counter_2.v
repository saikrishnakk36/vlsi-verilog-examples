// ud_counter4.v
// Minimal 4-bit synchronous up/down counter.
// dir = 1 counts up, dir = 0 counts down; both directions wrap naturally.
module ud_counter4 (
    input  wire       clk,
    input  wire       rst,   // synchronous, active-high
    input  wire       dir,   // 1 = up, 0 = down
    output reg  [3:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= 4'd0;
        else if (dir)
            q <= q + 4'd1;
        else
            q <= q - 4'd1;
    end
endmodule

// --- Testbench ---
module tb_ud_counter4;
    reg        clk;
    reg        rst;
    reg        dir;
    wire [3:0] q;

    ud_counter4 dut (.clk(clk), .rst(rst), .dir(dir), .q(q));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $monitor("t=%3t rst=%b dir=%b | q=%2d", $time, rst, dir, q);

        rst = 1'b1; dir = 1'b1;
        @(negedge clk);          // q = 0 after first posedge

        rst = 1'b0;              // count up: 1,2,3,4,5
        repeat (5) @(negedge clk);

        dir = 1'b0;              // count down: 4,3,2,1,0,15 (wraps)
        repeat (6) @(negedge clk);

        $display("Final q = %0d", q);
        $finish;
    end
endmodule
