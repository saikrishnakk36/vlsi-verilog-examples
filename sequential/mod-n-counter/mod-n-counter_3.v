// mod_n_counter.v (same design) + a self-checking mod-10 testbench
module mod_n_counter #(
    parameter N     = 10,
    parameter WIDTH = (N <= 2) ? 1 : $clog2(N)
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    output reg  [WIDTH-1:0] count,
    output wire             tc
);
    assign tc = (count == (N-1));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (tc)
                count <= {WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end
endmodule

// tb_selfcheck.v -- predicts the expected value and fails loudly on a mismatch
module tb_selfcheck;
    localparam N = 10;

    reg        clk, rst_n, en;
    wire [3:0] count;
    wire       tc;

    reg  [3:0] expected;
    integer    errors;
    integer    i;

    mod_n_counter #(.N(N)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .count(count), .tc(tc)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        errors   = 0;
        expected = 4'd1;   // counter holds 0 in reset; first enabled edge -> 1
        rst_n    = 1'b0;
        en       = 1'b0;
        @(negedge clk);
        rst_n = 1'b1;
        en    = 1'b1;

        // Check 25 counted edges against the predicted sequence.
        for (i = 0; i < 25; i = i + 1) begin
            @(posedge clk);
            #1;  // let the non-blocking update settle before sampling
            if (count !== expected) begin
                $display("MISMATCH at edge %0d: got %0d, expected %0d",
                         i, count, expected);
                errors = errors + 1;
            end
            if (tc !== (expected == N-1)) begin
                $display("TC WRONG at edge %0d: tc=%b expected=%b",
                         i, tc, (expected == N-1));
                errors = errors + 1;
            end
            expected = (expected == N-1) ? 4'd0 : expected + 4'd1;
        end

        if (errors == 0)
            $display("PASS: mod-10 sequence and terminal count verified over 25 edges.");
        else
            $display("FAIL: %0d error(s) detected.", errors);
        $finish;
    end
endmodule
