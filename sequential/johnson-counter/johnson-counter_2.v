// johnson_decoded.v - Johnson counter with one-hot decoded outputs (MOD-6)
module johnson_decoded (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [2:0] q,       // 3 flip-flops -> 6 unique states
    output wire [5:0] y        // one-hot: exactly one line high per state
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 3'b000;
        else
            q <= {q[1:0], ~q[2]};
    end

    // Decode the six valid Johnson states into a one-hot bus.
    assign y[0] = (q == 3'b000);
    assign y[1] = (q == 3'b001);
    assign y[2] = (q == 3'b011);
    assign y[3] = (q == 3'b111);
    assign y[4] = (q == 3'b110);
    assign y[5] = (q == 3'b100);
endmodule

module tb_johnson_decoded;
    reg        clk;
    reg        rst_n;
    wire [2:0] q;
    wire [5:0] y;
    integer    i;

    johnson_decoded dut (
        .clk   (clk),
        .rst_n (rst_n),
        .q     (q),
        .y     (y)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        @(negedge clk);
        rst_n = 1'b1;
        $display("step |  q  |   y");
        for (i = 0; i < 6; i = i + 1) begin
            #1 $display(" %2d  | %b | %b", i, q, y);
            @(posedge clk);
        end
        $finish;
    end
endmodule
