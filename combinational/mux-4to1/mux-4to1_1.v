// mux4to1_case.v  -- 4:1 MUX, behavioral (case) style + self-checking testbench

module mux4to1_case (
    input  wire [3:0] d,    // data inputs d0..d3
    input  wire [1:0] sel,  // 2-bit select
    output reg        y      // output
);
    always @(*) begin
        case (sel)
            2'b00: y = d[0];
            2'b01: y = d[1];
            2'b10: y = d[2];
            2'b11: y = d[3];
            default: y = 1'b0;
        endcase
    end
endmodule

module tb_mux4to1_case;
    reg  [3:0] d;
    reg  [1:0] sel;
    wire       y;
    integer    s, t, errors;
    reg        expected;

    mux4to1_case dut (.d(d), .sel(sel), .y(y));

    initial begin
        errors = 0;
        $display("time sel  d[3:0]  y  exp");
        // Drive all 4 select lines; for each, test several data patterns
        for (s = 0; s < 4; s = s + 1) begin
            for (t = 0; t < 4; t = t + 1) begin
                sel = s[1:0];
                case (t)
                    0: d = 4'b0000;
                    1: d = 4'b1111;
                    2: d = 4'b1010;
                    3: d = 4'b0101;
                endcase
                #5;                 // let combinational logic settle
                expected = d[s];    // golden reference
                $display("%4t  %b   %b    %b  %b", $time, sel, d, y, expected);
                if (y !== expected) begin
                    errors = errors + 1;
                    $display("  ** MISMATCH at sel=%b d=%b : got %b expected %b", sel, d, y, expected);
                end
            end
        end
        if (errors == 0)
            $display("PASS: all 16 vectors matched across every select line.");
        else
            $display("FAIL: %0d mismatch(es).", errors);
        $finish;
    end
endmodule
