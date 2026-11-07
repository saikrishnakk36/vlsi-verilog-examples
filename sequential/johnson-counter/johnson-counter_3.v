// johnson_selfcheck.v - self-checking testbench for a Johnson counter
module johnson_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst_n,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= {WIDTH{1'b0}};
        else
            q <= {q[WIDTH-2:0], ~q[WIDTH-1]};
    end
endmodule

module tb_johnson_selfcheck;
    localparam WIDTH = 4;
    localparam STATES = 2*WIDTH;          // expected period
    reg              clk;
    reg              rst_n;
    wire [WIDTH-1:0] q;
    reg  [WIDTH-1:0] seen [0:STATES-1];   // record one full lap
    integer          i, j, errors;

    johnson_counter #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .q(q)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        errors = 0;
        rst_n  = 1'b0;
        @(negedge clk);
        rst_n = 1'b1;

        // Capture one full lap of STATES values.
        for (i = 0; i < STATES; i = i + 1) begin
            #1 seen[i] = q;
            @(posedge clk);
        end

        // Check 1: the counter wrapped exactly to its start value.
        #1 if (q !== seen[0]) begin
            errors = errors + 1;
            $display("FAIL: period != %0d (did not wrap to start)", STATES);
        end

        // Check 2: all STATES captured values are unique.
        for (i = 0; i < STATES; i = i + 1)
            for (j = i + 1; j < STATES; j = j + 1)
                if (seen[i] === seen[j]) begin
                    errors = errors + 1;
                    $display("FAIL: duplicate state %b at steps %0d and %0d",
                             seen[i], i, j);
                end

        if (errors == 0)
            $display("PASS: %0d unique states, wraps correctly", STATES);
        else
            $display("TOTAL ERRORS: %0d", errors);
        $finish;
    end
endmodule
