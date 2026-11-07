// mux4to1_assign.v  -- 4:1 MUX, dataflow (assign) style + self-checking testbench

module mux4to1_assign (
    input  wire [3:0] d,    // data inputs d0..d3
    input  wire [1:0] sel,  // 2-bit select
    output wire       y      // output
);
    // Nested conditional (ternary) operators select one of four inputs.
    assign y = sel[1] ? (sel[0] ? d[3] : d[2])
                      : (sel[0] ? d[1] : d[0]);
endmodule

module tb_mux4to1_assign;
    reg  [3:0] d;
    reg  [1:0] sel;
    wire       y;
    integer    s, t, errors;
    reg        expected;

    mux4to1_assign dut (.d(d), .sel(sel), .y(y));

    initial begin
        errors = 0;
        $display("time sel  d[3:0]  y  exp");
        for (s = 0; s < 4; s = s + 1) begin
            for (t = 0; t < 4; t = t + 1) begin
                sel = s[1:0];
                case (t)
                    0: d = 4'b0001;
                    1: d = 4'b0010;
                    2: d = 4'b0100;
                    3: d = 4'b1000;
                endcase
                #5;
                expected = d[s];
                $display("%4t  %b   %b    %b  %b", $time, sel, d, y, expected);
                if (y !== expected) begin
                    errors = errors + 1;
                    $display("  ** MISMATCH at sel=%b d=%b : got %b expected %b", sel, d, y, expected);
                end
            end
        end
        if (errors == 0)
            $display("PASS: dataflow mux routed d[sel] correctly for all select lines.");
        else
            $display("FAIL: %0d mismatch(es).", errors);
        $finish;
    end
endmodule
