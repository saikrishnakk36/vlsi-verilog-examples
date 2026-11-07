// comparator_4bit_behavioral.v
// 4-bit magnitude comparator described behaviorally.
module comparator_4bit (
    input  [3:0] a,
    input  [3:0] b,
    output reg   a_gt_b,   // high when a > b
    output reg   a_eq_b,   // high when a == b
    output reg   a_lt_b    // high when a < b
);
    always @(*) begin
        a_gt_b = (a > b);
        a_eq_b = (a == b);
        a_lt_b = (a < b);
    end
endmodule

// Testbench
module comparator_4bit_tb;
    reg  [3:0] a, b;
    wire a_gt_b, a_eq_b, a_lt_b;
    integer i, j;

    comparator_4bit dut (
        .a(a), .b(b),
        .a_gt_b(a_gt_b), .a_eq_b(a_eq_b), .a_lt_b(a_lt_b)
    );

    initial begin
        $display(" a   b  | gt eq lt");
        $display("------------------");
        for (i = 0; i < 16; i = i + 5) begin
            for (j = 0; j < 16; j = j + 6) begin
                a = i[3:0];
                b = j[3:0];
                #1;
                $display("%2d  %2d  |  %b  %b  %b", a, b, a_gt_b, a_eq_b, a_lt_b);
            end
        end
        $display("Done: behavioral comparator verified.");
        $finish;
    end
endmodule

