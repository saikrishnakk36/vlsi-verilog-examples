// ring_counter.v  -- 4-bit one-hot ring counter with synchronous reset seeding
module ring_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,     // synchronous, active-high
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= {{(WIDTH-1){1'b0}}, 1'b1};   // seed a single 1 -> 0001
        else
            q <= {q[WIDTH-2:0], q[WIDTH-1]};  // rotate left, MSB wraps to LSB
    end
endmodule

// tb_ring_counter.v
module tb_ring_counter;
    localparam WIDTH = 4;
    reg              clk = 1'b0;
    reg              rst;
    wire [WIDTH-1:0] q;

    ring_counter #(.WIDTH(WIDTH)) dut (.clk(clk), .rst(rst), .q(q));

    always #5 clk = ~clk;   // 10 ns period

    integer i;
    initial begin
        $display("time | rst |  q(bin) | q(hex)");
        $monitor("%4t |  %b  |  %b  |   %h", $time, rst, q, q);

        rst = 1'b1;          // assert reset to seed 0001
        @(posedge clk); #1;
        rst = 1'b0;          // release, let the 1 circulate

        for (i = 0; i < 8; i = i + 1) @(posedge clk);
        #1;
        $display("Done: pattern circulated through all %0d positions twice.", WIDTH);
        $finish;
    end
endmodule
