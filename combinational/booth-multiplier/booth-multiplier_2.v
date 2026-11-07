// booth_comb.v  --  Combinational radix-2 Booth multiplier (parameterized, signed)
module booth_comb #(parameter WIDTH = 4) (
    input  wire signed [WIDTH-1:0]   a,   // multiplicand
    input  wire signed [WIDTH-1:0]   b,   // multiplier
    output wire signed [2*WIDTH-1:0] p    // signed product
);
    integer i;
    reg signed [2*WIDTH+1:0] acc;         // {A[WIDTH+1], Q[WIDTH], Q_1[1]}
    reg signed [WIDTH:0]     m_ext;       // multiplicand, sign-extended by 1 bit

    always @(*) begin
        m_ext = {a[WIDTH-1], a};
        acc   = {{(WIDTH+1){1'b0}}, b, 1'b0};   // A=0, Q=b, Q_1=0
        for (i = 0; i < WIDTH; i = i + 1) begin
            case (acc[1:0])                      // Booth bits = {Q[0], Q_1}
                2'b01: acc[2*WIDTH+1:WIDTH+1] = acc[2*WIDTH+1:WIDTH+1] + m_ext;
                2'b10: acc[2*WIDTH+1:WIDTH+1] = acc[2*WIDTH+1:WIDTH+1] - m_ext;
                default: ;                       // 00 / 11: skip
            endcase
            acc = acc >>> 1;                     // arithmetic right shift
        end
    end

    assign p = acc[2*WIDTH:1];                   // drop Q_1 + spare sign bit
endmodule

// -------- testbench: exhaustive signed check for WIDTH=4 --------
module tb_booth_comb;
    localparam WIDTH = 4;
    reg  signed [WIDTH-1:0]   a, b;
    wire signed [2*WIDTH-1:0] p;
    reg  signed [2*WIDTH-1:0] exp;
    integer i, j, errors;

    booth_comb #(.WIDTH(WIDTH)) dut (.a(a), .b(b), .p(p));

    initial begin
        errors = 0;
        for (i = 0; i < (1<<WIDTH); i = i + 1)
            for (j = 0; j < (1<<WIDTH); j = j + 1) begin
                a = i[WIDTH-1:0];
                b = j[WIDTH-1:0];
                #1;
                exp = a * b;
                if (p !== exp) begin
                    errors = errors + 1;
                    $display("MISMATCH %0d * %0d = %0d (expected %0d)", a, b, p, exp);
                end
            end
        // spot-check a few edge cases on screen
        a = -8; b = -8; #1; $display("-8 * -8 = %0d", p);
        a = -8; b =  7; #1; $display("-8 *  7 = %0d", p);
        a =  5; b = -3; #1; $display(" 5 * -3 = %0d", p);
        if (errors == 0)
            $display("PASS: all 256 signed products correct");
        else
            $display("FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule

