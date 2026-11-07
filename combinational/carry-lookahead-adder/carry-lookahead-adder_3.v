// rca_vs_cla.v  --  ripple-carry adder and CLA checked against each other
module rca #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              cin,
    output [WIDTH-1:0] sum,
    output             cout
);
    wire [WIDTH:0] c;
    assign c[0] = cin;
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : fa
            // full adder: carry of bit i must settle before bit i+1 starts
            assign sum[i] = a[i] ^ b[i] ^ c[i];
            assign c[i+1] = (a[i] & b[i]) | (a[i] & c[i]) | (b[i] & c[i]);
        end
    endgenerate
    assign cout = c[WIDTH];
endmodule

module cla #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input              cin,
    output [WIDTH-1:0] sum,
    output             cout
);
    wire [WIDTH-1:0] g = a & b;
    wire [WIDTH-1:0] p = a ^ b;
    wire [WIDTH:0]   c;
    assign c[0] = cin;
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : carry_chain
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate
    assign sum  = p ^ c[WIDTH-1:0];
    assign cout = c[WIDTH];
endmodule

// Testbench: both adders see the same stimulus; their outputs must agree.
module tb_compare;
    localparam WIDTH = 8;
    reg  [WIDTH-1:0] a, b;
    reg              cin;
    wire [WIDTH-1:0] sum_r, sum_c;
    wire             cout_r, cout_c;
    integer          k, errors;

    rca #(.WIDTH(WIDTH)) u_rca (.a(a), .b(b), .cin(cin), .sum(sum_r), .cout(cout_r));
    cla #(.WIDTH(WIDTH)) u_cla (.a(a), .b(b), .cin(cin), .sum(sum_c), .cout(cout_c));

    initial begin
        errors = 0;
        for (k = 0; k < 8; k = k + 1) begin
            a   = $random;
            b   = $random;
            cin = $random;
            #1;
            $display("a=%3d b=%3d cin=%b | rca={%b,%3d} cla={%b,%3d}",
                     a, b, cin, cout_r, sum_r, cout_c, sum_c);
            if ({cout_r, sum_r} !== {cout_c, sum_c}) errors = errors + 1;
        end
        $display("RIPPLE vs CLA %s (%0d mismatches)",
                 (errors==0)?"MATCH":"DIFFER", errors);
        $finish;
    end
endmodule
