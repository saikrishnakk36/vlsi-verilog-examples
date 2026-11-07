`timescale 1ns/1ps

// Reusable single-digit BCD stage (0..9 with carry).
module bcd_counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output reg  [3:0] count,
    output wire       carry
);

    assign carry = en & (count == 4'd9);

    always @(posedge clk) begin
        if (!rst_n)
            count <= 4'd0;
        else if (en) begin
            if (count == 4'd9)
                count <= 4'd0;
            else
                count <= count + 4'd1;
        end
    end

endmodule

// Two-digit BCD counter (00..99) built by cascading two stages.
// The tens stage only advances on the cycle the ones stage shows 9,
// so the display walks 00, 01, ... 09, 10, 11 ...
module bcd_counter_2digit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    output wire [3:0] ones,
    output wire [3:0] tens,
    output wire       carry_out   // pulses on 99 -> 00
);

    wire ones_carry;

    bcd_counter u_ones (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .count (ones),
        .carry (ones_carry)
    );

    bcd_counter u_tens (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (ones_carry),   // advance tens only when ones rolls over
        .count (tens),
        .carry (carry_out)
    );

endmodule

// Testbench: watch the first decade rollover (00..12).
module tb_bcd_counter_2digit;

    reg        clk;
    reg        rst_n;
    reg        en;
    wire [3:0] ones;
    wire [3:0] tens;
    wire       carry_out;
    integer    i;

    bcd_counter_2digit dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .en        (en),
        .ones      (ones),
        .tens      (tens),
        .carry_out (carry_out)
    );

    initial clk = 1'b0;
    always  #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;      // hold reset from time 0
        en    = 1'b0;
        #12;               // release between edges
        rst_n = 1'b1;
        en    = 1'b1;

        $display("tick  value  carry_out");
        for (i = 0; i < 13; i = i + 1) begin
            $display("  %0d     %0d%0d       %b", i, tens, ones, carry_out);
            @(posedge clk);
            #1;            // let outputs settle after the edge
        end
        $finish;
    end

endmodule
