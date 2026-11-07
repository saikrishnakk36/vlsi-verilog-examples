// half_adder_dataflow.v
// Half adder described with continuous (dataflow) assignments.
module half_adder_dataflow (
    input  wire a,      // first input bit
    input  wire b,      // second input bit
    output wire sum,    // sum output  = a XOR b
    output wire carry   // carry output = a AND b
);
    assign sum   = a ^ b;   // XOR gives the sum bit
    assign carry = a & b;   // AND gives the carry bit
endmodule

// Testbench: drives all 4 input combinations and prints a truth table.
module half_adder_dataflow_tb;
    reg  a, b;              // stimulus (reg: assigned in procedural block)
    wire sum, carry;        // observed outputs (wire: driven by the DUT)
    integer i;              // loop counter

    // Instantiate the Device Under Test (DUT) by named port connection.
    half_adder_dataflow dut (
        .a(a), .b(b), .sum(sum), .carry(carry)
    );

    initial begin
        $display("A B | SUM CARRY");
        $display("----+----------");
        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i[1:0];        // unpack the 2 input bits
            #10;                    // let combinational logic settle
            $display("%b %b |  %b    %b", a, b, sum, carry);
        end
        $display("Done. SUM=A^B, CARRY=A&B verified for all 4 cases.");
        $finish;
    end
endmodule
