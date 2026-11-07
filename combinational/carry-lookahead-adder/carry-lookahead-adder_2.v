// cla_param.v  --  parameterized N-bit carry look-ahead adder
module cla #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              cin,
    output [WIDTH-1:0] sum,
    output             cout
);
    wire [WIDTH-1:0] g = a & b;   // generate
    wire [WIDTH-1:0] p = a ^ b;   // propagate
    wire [WIDTH:0]   c;           // carry chain, c[0] = cin

    assign c[0] = cin;

    // The look-ahead recurrence c[i+1] = g[i] | (p[i] & c[i]) is unrolled
    // by the generate loop. A synthesis tool flattens this into the
    // same parallel carry logic for any WIDTH you pick.
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_chain
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate

    assign sum  = p ^ c[WIDTH-1:0];
    assign cout = c[WIDTH];
endmodule

// Testbench: instantiate a 12-bit adder and hit it with random vectors.
module tb_cla;
    localparam WIDTH = 12;
    reg  [WIDTH-1:0] a, b;
    reg              cin;
    wire [WIDTH-1:0] sum;
    wire             cout;
    reg  [WIDTH:0]   expected;
    integer          k, errors;

    cla #(.WIDTH(WIDTH)) dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        errors = 0;
        for (k = 0; k < 10; k = k + 1) begin
            a   = $random;
            b   = $random;
            cin = $random;
            #1;
            expected = a + b + cin;
            $display("W=%0d a=%4d b=%4d cin=%b | {cout,sum}=%5d | expect=%5d",
                     WIDTH, a, b, cin, {cout, sum}, expected);
            if ({cout, sum} !== expected) errors = errors + 1;
        end
        $display("TEST %s (%0d mismatches)", (errors==0)?"PASSED":"FAILED", errors);
        $finish;
    end
endmodule
