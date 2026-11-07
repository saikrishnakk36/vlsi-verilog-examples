// Wallace tree multiplier (4x4), Verilog-2005
// Partial products reduced with half adders and full adders (carry-save),
// then a final carry-propagate adder produces the 8-bit product.

module ha (input a, input b, output sum, output cout);
    assign sum  = a ^ b;
    assign cout = a & b;
endmodule

module fa (input a, input b, input cin, output sum, output cout);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

module wallace_mult_4x4 (input [3:0] a, input [3:0] b, output [7:0] p);
    // --- Partial product bits: txy = a[x] & b[y], weight = x + y ---
    wire t00 = a[0] & b[0];                                  // w0
    wire t10 = a[1] & b[0], t01 = a[0] & b[1];               // w1
    wire t20 = a[2] & b[0], t11 = a[1] & b[1], t02 = a[0] & b[2]; // w2
    wire t30 = a[3] & b[0], t21 = a[2] & b[1], t12 = a[1] & b[2], t03 = a[0] & b[3]; // w3
    wire t31 = a[3] & b[1], t22 = a[2] & b[2], t13 = a[1] & b[3]; // w4
    wire t32 = a[3] & b[2], t23 = a[2] & b[3];               // w5
    wire t33 = a[3] & b[3];                                  // w6

    // --- Stage A: first carry-save reduction layer ---
    wire s1, c1;  ha u_w1a (t10, t01, s1, c1);               // w1 -> s1(w1), c1(w2)
    wire s2, c2;  fa u_w2a (t20, t11, t02, s2, c2);          // w2 -> s2(w2), c2(w3)
    wire s3, c3;  fa u_w3a (t30, t21, t12, s3, c3);          // w3 (t03 kept)
    wire s4, c4;  fa u_w4a (t31, t22, t13, s4, c4);          // w4
    wire s5, c5;  ha u_w5a (t32, t23, s5, c5);               // w5

    // --- Stage B: reduce every column to at most two dots ---
    wire s2b, c2b; ha u_w2b (s2, c1, s2b, c2b);              // w2
    wire s3b, c3b; fa u_w3b (s3, c2, t03, s3b, c3b);         // w3
    wire s4b, c4b; ha u_w4b (s4, c3, s4b, c4b);              // w4
    wire s5b, c5b; ha u_w5b (s5, c4, s5b, c5b);              // w5
    wire s6b, c6b; ha u_w6b (t33, c5, s6b, c6b);             // w6

    // --- Two residual rows feeding the carry-propagate adder ---
    wire [7:0] row_sum   = {1'b0, s6b, s5b, s4b, s3b, s2b, s1,  t00};
    wire [7:0] row_carry = {c6b,  c5b, c4b, c3b, c2b, 1'b0, 1'b0, 1'b0};

    assign p = row_sum + row_carry;   // final CPA
endmodule

// --------------------- Testbench ---------------------
module tb_wallace;
    reg  [3:0] a, b;
    wire [7:0] p;
    integer i, j, errors;

    wallace_mult_4x4 dut (.a(a), .b(b), .p(p));

    initial begin
        errors = 0;
        // A few representative products
        a = 4'd3;  b = 4'd5;  #5 $display("  3 x  5 = %0d (expected %0d)", p, 3*5);
        a = 4'd9;  b = 4'd7;  #5 $display("  9 x  7 = %0d (expected %0d)", p, 9*7);
        a = 4'd15; b = 4'd15; #5 $display(" 15 x 15 = %0d (expected %0d)", p, 15*15);
        a = 4'd12; b = 4'd0;  #5 $display(" 12 x  0 = %0d (expected %0d)", p, 12*0);

        // Exhaustive self-check over all 256 input combinations
        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0]; b = j[3:0]; #2;
                if (p !== (i*j)) begin
                    errors = errors + 1;
                    $display("  MISMATCH %0d x %0d -> got %0d", i, j, p);
                end
            end

        if (errors == 0) $display("RESULT: all 256 products correct");
        else             $display("RESULT: %0d mismatches", errors);
        $finish;
    end
endmodule
