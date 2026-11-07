`timescale 1ns/1ps

// Single-digit BCD counter: counts 0..9, then wraps to 0.
// carry pulses high for the cycle that holds 9 while enabled,
// so it is ready to clock the next decade.
module bcd_counter (
    input  wire       clk,
    input  wire       rst_n,   // synchronous active-low reset
    input  wire       en,      // count enable (tick)
    output reg  [3:0] count,   // current BCD digit, 0..9
    output wire       carry    // high when count == 9 and enabled
);

    assign carry = en & (count == 4'd9);

    always @(posedge clk) begin
        if (!rst_n)
            count <= 4'd0;
        else if (en) begin
            if (count == 4'd9)
                count <= 4'd0;      // wrap after 9, never reach 10..15
            else
                count <= count + 4'd1;
        end
    end

endmodule

// Testbench for the single-digit counter.
module tb_bcd_counter;

    reg        clk;
    reg        rst_n;
    reg        en;
    wire [3:0] count;
    wire       carry;
    integer    i;

    bcd_counter dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .count (count),
        .carry (carry)
    );

    // 10 ns clock
    initial clk = 1'b0;
    always  #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;      // hold reset from time 0
        en    = 1'b0;
        #12;               // release between edges, count is already 0
        rst_n = 1'b1;
        en    = 1'b1;

        $display("tick  count  carry");
        for (i = 0; i < 12; i = i + 1) begin
            $display("  %0d      %0d      %b", i, count, carry);
            @(posedge clk);
            #1;            // let the non-blocking update settle
        end
        $finish;
    end

endmodule
