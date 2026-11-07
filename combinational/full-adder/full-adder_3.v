// Half adder building block
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule

// Full adder - structural style (two half adders + OR gate)
module full_adder_structural (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire ha1_sum, ha1_carry, ha2_carry;

    half_adder ha1 (.a(a),       .b(b),   .sum(ha1_sum), .carry(ha1_carry));
    half_adder ha2 (.a(ha1_sum), .b(cin), .sum(sum),     .carry(ha2_carry));

    assign cout = ha1_carry | ha2_carry;
endmodule

// Testbench - drives all 8 combinations
module tb_full_adder;
    reg  a, b, cin;
    wire sum, cout;
    integer i;

    full_adder_structural dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    initial begin
        $display(" a b cin | cout sum");
        $display("---------+---------");
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #2;
            $display(" %b %b  %b  |  %b   %b", a, b, cin, cout, sum);
        end
        $display("Structural (2x half adder) full adder: 8/8 combinations done.");
        $finish;
    end
endmodule
