// up_down_counter.v
// Parameterized synchronous up/down counter with enable,
// synchronous load, synchronous active-low reset and terminal count.
module up_down_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             rst_n,    // synchronous, active-low
    input  wire             en,       // count enable
    input  wire             up_down,  // 1 = count up, 0 = count down
    input  wire             load,     // synchronous parallel load
    input  wire [WIDTH-1:0] data_in,  // value loaded when load = 1
    output reg  [WIDTH-1:0] count,
    output wire             tc        // terminal count (combinational flag)
);
    // tc is high on the last value in the current direction while enabled,
    // i.e. the next enabled clock edge will wrap the counter.
    assign tc = en & (up_down ? (count == {WIDTH{1'b1}})
                              : (count == {WIDTH{1'b0}}));

    always @(posedge clk) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (load)
            count <= data_in;
        else if (en)
            count <= up_down ? count + 1'b1 : count - 1'b1;
    end
endmodule

// --- Testbench ---
module tb_up_down_counter;
    localparam WIDTH = 4;

    reg              clk;
    reg              rst_n;
    reg              en;
    reg              up_down;
    reg              load;
    reg  [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] count;
    wire             tc;

    up_down_counter #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .up_down(up_down),
        .load(load), .data_in(data_in), .count(count), .tc(tc)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Drive stimulus on the negedge so inputs are stable at each posedge.
    initial begin
        $monitor("t=%3t rst_n=%b en=%b up=%b load=%b din=%2d | count=%2d tc=%b",
                 $time, rst_n, en, up_down, load, data_in, count, tc);

        rst_n = 1'b0; en = 1'b0; up_down = 1'b1; load = 1'b0; data_in = 4'd0;
        @(negedge clk);            // reset sampled on first posedge -> count = 0

        rst_n = 1'b1; en = 1'b1;   // release reset, start counting up
        repeat (3) @(negedge clk); // 1, 2, 3

        load = 1'b1; data_in = 4'd13;
        @(negedge clk);            // load 13
        load = 1'b0;

        repeat (3) @(negedge clk); // 14, 15 (tc=1), 0 wraps

        up_down = 1'b0;            // switch to counting down
        repeat (3) @(negedge clk); // 15, 14, 13

        en = 1'b0;                 // freeze the counter
        repeat (2) @(negedge clk);

        $display("Final count = %0d", count);
        $finish;
    end
endmodule
