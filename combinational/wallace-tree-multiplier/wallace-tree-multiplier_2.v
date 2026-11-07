// 3-to-2 carry-save adder (compressor) over 4-bit vectors, Verilog-2005.
// Demonstrates the core operation a Wallace tree repeats: three rows of dots
// collapse into one sum vector and one carry vector, with NO carry propagation.

module csa4 (input [3:0] x, input [3:0] y, input [3:0] z,
             output [3:0] s,   // bitwise sum  (same weight)
             output [3:0] c);  // bitwise carry (one weight higher)
    assign s = x ^ y ^ z;                       // full-adder sum, per bit
    assign c = (x & y) | (x & z) | (y & z);     // full-adder carry, per bit
endmodule

// --------------------- Testbench ---------------------
module tb_csa;
    reg  [3:0] x, y, z;
    wire [3:0] s, c;
    wire [5:0] total;
    integer k, errors;

    csa4 dut (.x(x), .y(y), .z(z), .s(s), .c(c));

    // Recombine the two saved vectors: total = s + (c << 1)
    assign total = s + (c << 1);

    initial begin
        errors = 0;
        x = 4'd6; y = 4'd5; z = 4'd3;
        #5 $display(" x=%0d y=%0d z=%0d -> sum=%b carry=%b total=%0d (expected %0d)",
                    x, y, z, s, c, total, 6+5+3);
        x = 4'd15; y = 4'd15; z = 4'd15;
        #5 $display(" x=%0d y=%0d z=%0d -> sum=%b carry=%b total=%0d (expected %0d)",
                    x, y, z, s, c, total, 15+15+15);

        // Random self-check: carry-save must preserve the true sum
        for (k = 0; k < 40; k = k + 1) begin
            x = $random; y = $random; z = $random; #2;
            if (total !== (x + y + z)) begin
                errors = errors + 1;
                $display(" MISMATCH %0d+%0d+%0d -> %0d", x, y, z, total);
            end
        end

        if (errors == 0) $display("RESULT: carry-save preserved every sum");
        else             $display("RESULT: %0d mismatches", errors);
        $finish;
    end
endmodule
