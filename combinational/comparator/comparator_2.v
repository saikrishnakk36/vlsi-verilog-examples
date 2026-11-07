// comparator_4bit_structural.v
// 4-bit magnitude comparator built from gate primitives.
module comparator_4bit_struct (
    input  [3:0] a,
    input  [3:0] b,
    output       a_gt_b,
    output       a_eq_b,
    output       a_lt_b
);
    wire [3:0] eq;    // eq[i] = 1 when a[i] == b[i]
    wire [3:0] nb;    // nb[i] = ~b[i]
    wire [3:0] hi;    // hi[i] = a[i] & ~b[i]  (a wins this bit)
    wire g2, g1, g0;

    // Per-bit equality using XNOR.
    xnor xn3 (eq[3], a[3], b[3]);
    xnor xn2 (eq[2], a[2], b[2]);
    xnor xn1 (eq[1], a[1], b[1]);
    xnor xn0 (eq[0], a[0], b[0]);

    // Per-bit "a is higher here" = a[i] AND NOT b[i].
    not i3 (nb[3], b[3]);
    not i2 (nb[2], b[2]);
    not i1 (nb[1], b[1]);
    not i0 (nb[0], b[0]);
    and h3 (hi[3], a[3], nb[3]);
    and h2 (hi[2], a[2], nb[2]);
    and h1 (hi[1], a[1], nb[1]);
    and h0 (hi[0], a[0], nb[0]);

    // Greater-than, resolved from the MSB downward.
    and t2 (g2, eq[3], hi[2]);
    and t1 (g1, eq[3], eq[2], hi[1]);
    and t0 (g0, eq[3], eq[2], eq[1], hi[0]);
    or  og (a_gt_b, hi[3], g2, g1, g0);

    // Equal when every bit matches.
    and ae (a_eq_b, eq[3], eq[2], eq[1], eq[0]);

    // Less-than is "not greater and not equal".
    nor nl (a_lt_b, a_gt_b, a_eq_b);
endmodule

// Testbench: exhaustive self-check against Verilog's own operators.
module comparator_4bit_struct_tb;
    reg  [3:0] a, b;
    wire a_gt_b, a_eq_b, a_lt_b;
    integer i, j, errors;

    comparator_4bit_struct dut (
        .a(a), .b(b),
        .a_gt_b(a_gt_b), .a_eq_b(a_eq_b), .a_lt_b(a_lt_b)
    );

    initial begin
        errors = 0;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];
                #1;
                if ((a_gt_b !== (a > b)) ||
                    (a_eq_b !== (a == b)) ||
                    (a_lt_b !== (a < b))) begin
                    errors = errors + 1;
                    $display("MISMATCH a=%0d b=%0d gt=%b eq=%b lt=%b", a, b, a_gt_b, a_eq_b, a_lt_b);
                end
            end
        end
        $display("Exhaustive check of 256 vectors complete; errors = %0d", errors);
        $display("Sample results:");
        a = 4'd9;  b = 4'd4;  #1 $display("  a=%0d b=%0d -> gt=%b eq=%b lt=%b", a, b, a_gt_b, a_eq_b, a_lt_b);
        a = 4'd7;  b = 4'd7;  #1 $display("  a=%0d b=%0d -> gt=%b eq=%b lt=%b", a, b, a_gt_b, a_eq_b, a_lt_b);
        a = 4'd2;  b = 4'd11; #1 $display("  a=%0d b=%0d -> gt=%b eq=%b lt=%b", a, b, a_gt_b, a_eq_b, a_lt_b);
        $finish;
    end
endmodule

