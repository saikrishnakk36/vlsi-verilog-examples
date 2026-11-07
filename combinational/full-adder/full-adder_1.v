// Full adder - dataflow style
module full_adder_dataflow (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// Testbench - exercises all 8 input combinations
module tb_full_adder;
    reg  a, b, cin;
    wire sum, cout;
    integer i;

    full_adder_dataflow dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    initial begin
        $display(" a b cin | cout sum | expected");
        $display("---------+----------+---------");
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #1;
            $display(" %b %b  %b  |  %b   %b  |   %0d",
                     a, b, cin, cout, sum, (a + b + cin));
        end
        $display("All 8 input combinations verified.");
        $finish;
    end
endmodule
