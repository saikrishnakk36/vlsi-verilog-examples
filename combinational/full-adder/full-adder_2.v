// Full adder - behavioral style
module full_adder_behavioral (
    input  wire a,
    input  wire b,
    input  wire cin,
    output reg  sum,
    output reg  cout
);
    always @(*) begin
        {cout, sum} = a + b + cin;
    end
endmodule

// Testbench - checks all 8 cases and flags mismatches
module tb_full_adder;
    reg  a, b, cin;
    wire sum, cout;
    integer i;
    reg [1:0] expected;

    full_adder_behavioral dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    initial begin
        $display("Time  a b cin | cout sum");
        $monitor("%4t  %b %b  %b  |  %b   %b", $time, a, b, cin, cout, sum);
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #5;
            expected = a + b + cin;
            if ({cout, sum} !== expected)
                $display("  MISMATCH at a=%b b=%b cin=%b", a, b, cin);
        end
        $display("Done: behavioral full adder matched all 8 cases.");
        $finish;
    end
endmodule
