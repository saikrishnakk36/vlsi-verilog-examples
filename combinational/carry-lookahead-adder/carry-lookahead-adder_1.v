// cla4.v  --  4-bit carry look-ahead adder with explicit generate/propagate
module cla4 (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);
    wire [3:0] g;   // generate:  g[i] = a[i] & b[i]
    wire [3:0] p;   // propagate: p[i] = a[i] ^ b[i]
    wire [4:0] c;   // carries, c[0] = cin

    assign g = a & b;
    assign p = a ^ b;

    // Each carry is written as a flat sum-of-products, so every bit
    // sees its carry at the same time instead of waiting for the one below.
    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])
                       | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
                       | (p[3] & p[2] & p[1] & g[0])
                       | (p[3] & p[2] & p[1] & p[0] & c[0]);

    assign sum  = p ^ c[3:0];
    assign cout = c[4];
endmodule

// Testbench: sweep a grid of inputs and check against Verilog's own + operator.
module tb_cla4;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;
    reg  [4:0] expected;
    integer    i, j, errors;

    cla4 dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        errors = 0;
        cin = 1'b0;
        for (i = 0; i < 16; i = i + 5) begin
            for (j = 0; j < 16; j = j + 3) begin
                a = i[3:0];
                b = j[3:0];
                #1;
                expected = a + b + cin;
                $display("a=%2d b=%2d cin=%b | sum=%2d cout=%b | expect=%2d",
                         a, b, cin, sum, cout, expected);
                if ({cout, sum} !== expected) errors = errors + 1;
            end
        end
        // one case that forces cin=1 and an output carry
        cin = 1'b1; a = 4'd9; b = 4'd7; #1;
        $display("a=%2d b=%2d cin=%b | sum=%2d cout=%b | expect=%2d",
                 a, b, cin, sum, cout, a + b + cin);
        if ({cout, sum} !== (a + b + cin)) errors = errors + 1;
        $display("TEST %s (%0d mismatches)", (errors==0)?"PASSED":"FAILED", errors);
        $finish;
    end
endmodule
