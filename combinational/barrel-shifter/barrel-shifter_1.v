// barrel_shifter.v
// Parameterized combinational barrel shifter built from log2(WIDTH)
// stages of 2:1 multiplexers. Supports logical shift and rotate,
// in either direction, with no clock.
module barrel_shifter #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]         data_in,
    input  wire [$clog2(WIDTH)-1:0] shamt,   // shift/rotate amount
    input  wire                     dir,      // 0 = left, 1 = right
    input  wire                     rotate,   // 0 = fill zeros, 1 = rotate
    output wire [WIDTH-1:0]         data_out
);
    localparam STAGES = $clog2(WIDTH);

    // stage[0] is the raw input; each stage conditionally shifts by 2**s.
    wire [WIDTH-1:0] stage [0:STAGES];
    assign stage[0] = data_in;

    genvar s;
    generate
        for (s = 0; s < STAGES; s = s + 1) begin : g_stage
            localparam integer SH = (1 << s);          // this stage's distance
            wire [WIDTH-1:0] cur = stage[s];

            // Four candidate results for a fixed distance SH.
            wire [WIDTH-1:0] left_log  = {cur[WIDTH-1-SH:0], {SH{1'b0}}};
            wire [WIDTH-1:0] left_rot  = {cur[WIDTH-1-SH:0], cur[WIDTH-1:WIDTH-SH]};
            wire [WIDTH-1:0] right_log = {{SH{1'b0}}, cur[WIDTH-1:SH]};
            wire [WIDTH-1:0] right_rot = {cur[SH-1:0], cur[WIDTH-1:SH]};

            wire [WIDTH-1:0] moved = dir ? (rotate ? right_rot : right_log)
                                         : (rotate ? left_rot  : left_log);

            // Enable this stage only when the matching shamt bit is set.
            assign stage[s+1] = shamt[s] ? moved : cur;
        end
    endgenerate

    assign data_out = stage[STAGES];
endmodule

// tb_barrel_shifter.v
// Self-checking testbench. A behavioral reference computes the expected
// result for every vector and compares it against the structural DUT.
module tb_barrel_shifter;
    localparam WIDTH   = 8;
    localparam SHIFT_W = $clog2(WIDTH);

    reg  [WIDTH-1:0]   data_in;
    reg  [SHIFT_W-1:0] shamt;
    reg                dir;
    reg                rotate;
    wire [WIDTH-1:0]   data_out;

    integer errors = 0;

    barrel_shifter #(.WIDTH(WIDTH)) dut (
        .data_in (data_in),
        .shamt   (shamt),
        .dir     (dir),
        .rotate  (rotate),
        .data_out(data_out)
    );

    // Golden model using Verilog shift operators.
    function [WIDTH-1:0] model;
        input [WIDTH-1:0]   d;
        input [SHIFT_W-1:0] n;
        input               rdir;
        input               rrot;
        begin
            if (rrot)
                model = rdir ? ((d >> n) | (d << (WIDTH-n)))
                             : ((d << n) | (d >> (WIDTH-n)));
            else
                model = rdir ? (d >> n) : (d << n);
        end
    endfunction

    task check;
        input [WIDTH-1:0]   d;
        input [SHIFT_W-1:0] n;
        input               rdir;
        input               rrot;
        reg   [WIDTH-1:0]   exp;
        begin
            data_in = d; shamt = n; dir = rdir; rotate = rrot;
            #1;
            exp = model(d, n, rdir, rrot);
            $display("in=%b amt=%0d dir=%s rot=%b -> out=%b exp=%b %s",
                     d, n, rdir ? "R" : "L", rrot, data_out, exp,
                     (data_out === exp) ? "OK" : "MISMATCH");
            if (data_out !== exp) errors = errors + 1;
        end
    endtask

    initial begin
        $display("== Parameterized barrel shifter, WIDTH=%0d ==", WIDTH);
        check(8'b1001_0110, 3, 1'b0, 1'b0);   // logical left  by 3
        check(8'b1001_0110, 3, 1'b1, 1'b0);   // logical right by 3
        check(8'b0001_0011, 2, 1'b0, 1'b1);   // rotate  left  by 2
        check(8'b0001_0011, 5, 1'b1, 1'b1);   // rotate  right by 5
        check(8'b1111_0000, 0, 1'b0, 1'b1);   // amount 0 passes through
        check(8'b1010_1010, 4, 1'b1, 1'b0);   // logical right by 4
        check(8'b1100_0011, 1, 1'b0, 1'b1);   // rotate  left  by 1

        if (errors == 0) $display("RESULT: all vectors matched the model");
        else             $display("RESULT: %0d mismatch(es)", errors);
        $finish;
    end
endmodule

