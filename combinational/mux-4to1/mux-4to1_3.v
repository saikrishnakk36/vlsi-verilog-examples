// mux4to1_struct.v  -- 4:1 MUX, structural (gate-level) style + self-checking testbench

module mux4to1_struct (
    input  wire [3:0] d,    // data inputs d0..d3
    input  wire [1:0] sel,  // 2-bit select
    output wire       y      // output
);
    wire ns0, ns1;          // inverted select lines
    wire a0, a1, a2, a3;    // per-input AND terms

    not u_n0 (ns0, sel[0]);
    not u_n1 (ns1, sel[1]);

    and u_a0 (a0, d[0], ns1, ns0);   // sel = 00
    and u_a1 (a1, d[1], ns1, sel[0]);// sel = 01
    and u_a2 (a2, d[2], sel[1], ns0);// sel = 10
    and u_a3 (a3, d[3], sel[1], sel[0]);// sel = 11

    or  u_or (y, a0, a1, a2, a3);    // combine the one active term
endmodule

module tb_mux4to1_struct;
    reg  [3:0] d;
    reg  [1:0] sel;
    wire       y;
    integer    s, errors;
    reg        expected;

    mux4to1_struct dut (.d(d), .sel(sel), .y(y));

    initial begin
        errors = 0;
        $display("time sel  d[3:0]  y  exp");
        // One-hot data: only d[sel] is high, so a correct mux must output 1.
        for (s = 0; s < 4; s = s + 1) begin
            sel = s[1:0];
            d   = (4'b0001 << s);   // drive the selected line high
            #5;
            expected = d[s];
            $display("%4t  %b   %b    %b  %b", $time, sel, d, y, expected);
            if (y !== expected) begin
                errors = errors + 1;
                $display("  ** MISMATCH at sel=%b d=%b : got %b expected %b", sel, d, y, expected);
            end
            // Inverse one-hot: selected line low, others high -> output must be 0.
            d = ~(4'b0001 << s);
            #5;
            expected = d[s];
            $display("%4t  %b   %b    %b  %b", $time, sel, d, y, expected);
            if (y !== expected) begin
                errors = errors + 1;
                $display("  ** MISMATCH at sel=%b d=%b : got %b expected %b", sel, d, y, expected);
            end
        end
        if (errors == 0)
            $display("PASS: gate-level mux selected d[sel] on every select line.");
        else
            $display("FAIL: %0d mismatch(es).", errors);
        $finish;
    end
endmodule
