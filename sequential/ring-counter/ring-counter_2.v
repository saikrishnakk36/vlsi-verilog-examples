// johnson_counter.v  -- 4-bit Johnson (twisted-ring) counter with reset seeding
module johnson_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,     // synchronous, active-high
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};             // seed all-zeros -> 0000
        else
            q <= {~q[0], q[WIDTH-1:1]};     // shift right, feed inverted LSB into MSB
    end
endmodule

// tb_johnson_counter.v
module tb_johnson_counter;
    localparam WIDTH = 4;
    reg              clk = 1'b0;
    reg              rst;
    wire [WIDTH-1:0] q;

    johnson_counter #(.WIDTH(WIDTH)) dut (.clk(clk), .rst(rst), .q(q));

    always #5 clk = ~clk;   // 10 ns period

    integer i;
    initial begin
        $display("time | rst |  q(bin) | q(hex)");
        $monitor("%4t |  %b  |  %b  |   %h", $time, rst, q, q);

        rst = 1'b1;          // assert reset to seed 0000
        @(posedge clk); #1;
        rst = 1'b0;          // release, generate the 2*WIDTH-state sequence

        for (i = 0; i < 9; i = i + 1) @(posedge clk);
        #1;
        $display("Done: completed one full %0d-state Johnson cycle.", 2*WIDTH);
        $finish;
    end
endmodule
