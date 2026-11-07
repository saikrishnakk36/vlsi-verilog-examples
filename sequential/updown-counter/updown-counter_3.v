// mod_n_updown.v
// Modulo-N up/down counter (decade counter when MOD = 10).
// Counts 0..MOD-1 going up and MOD-1..0 going down, wrapping at the ends.
module mod_n_updown #(
    parameter MOD   = 10,
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst,      // synchronous, active-high
    input  wire             en,       // count enable
    input  wire             up_down,  // 1 = up, 0 = down
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else if (en) begin
            if (up_down)
                q <= (q == MOD-1) ? {WIDTH{1'b0}} : q + 1'b1;
            else
                q <= (q == {WIDTH{1'b0}}) ? (MOD-1) : q - 1'b1;
        end
    end
endmodule

// --- Testbench ---
module tb_mod_n_updown;
    localparam MOD   = 10;
    localparam WIDTH = 4;

    reg              clk;
    reg              rst;
    reg              en;
    reg              up_down;
    wire [WIDTH-1:0] q;

    mod_n_updown #(.MOD(MOD), .WIDTH(WIDTH)) dut (
        .clk(clk), .rst(rst), .en(en), .up_down(up_down), .q(q)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $monitor("t=%3t rst=%b en=%b up=%b | q=%2d", $time, rst, en, up_down, q);

        rst = 1'b1; en = 1'b0; up_down = 1'b1;
        @(negedge clk);              // q = 0

        rst = 1'b0; en = 1'b1;       // count up 1..9 then wrap to 0
        repeat (11) @(negedge clk);

        up_down = 1'b0;              // now at 1, count down to 0 then wrap to 9
        repeat (3) @(negedge clk);

        $display("Final q = %0d", q);
        $finish;
    end
endmodule
