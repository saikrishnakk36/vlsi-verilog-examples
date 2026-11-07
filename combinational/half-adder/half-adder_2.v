// half_adder_gate.v
// Half adder built from Verilog built-in gate primitives (structural / gate-level).
module half_adder_gate (
    input  wire a,      // first input bit
    input  wire b,      // second input bit
    output wire sum,    // sum output
    output wire carry   // carry output
);
    // gate_primitive instance_name (output, input1, input2);
    xor g1 (sum,   a, b);   // sum   = a XOR b
    and g2 (carry, a, b);   // carry = a AND b
endmodule

// Testbench: $monitor logs every change across the 4 input combinations.
module half_adder_gate_tb;
    reg  a, b;
    wire sum, carry;

    half_adder_gate dut (.a(a), .b(b), .sum(sum), .carry(carry));

    initial begin
        // $monitor prints one line whenever any listed signal changes.
        $monitor("t=%0t | a=%b b=%b -> sum=%b carry=%b",
                 $time, a, b, sum, carry);
        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        $display("All 4 combinations applied to the gate-level half adder.");
        $finish;
    end
endmodule
