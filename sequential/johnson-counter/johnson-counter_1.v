// johnson_counter.v - parameterized Johnson (twisted-ring) counter
module johnson_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst_n,
    output reg  [WIDTH-1:0] q
);
    // Twisted ring: shift left, feed the complement of the MSB into the LSB.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= {WIDTH{1'b0}};
        else
            q <= {q[WIDTH-2:0], ~q[WIDTH-1]};
    end
endmodule

module tb_johnson_counter;
    localparam WIDTH = 4;
    reg              clk;
    reg              rst_n;
    wire [WIDTH-1:0] q;
    integer          i;

    johnson_counter #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .q     (q)
    );

    // 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;            // assert reset
        @(negedge clk);
        rst_n = 1'b1;            // release reset between edges
        $display("step |  q");
        for (i = 0; i < 2*WIDTH; i = i + 1) begin
            #1 $display(" %2d  | %b", i, q);  // sample just after the edge
            @(posedge clk);
        end
        #1 $display("next | %b  (wrapped back to start)", q);
        $finish;
    end
endmodule
