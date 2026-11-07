// baud_gen.v  -- baud-rate tick generator
// Build & run:  iverilog -g2005 -o sim baud_gen.v && vvp sim

module baud_gen #(parameter integer CLKS_PER_BIT = 4) (
    input  wire clk,
    input  wire rst_n,
    output reg  tick            // 1-cycle pulse every CLKS_PER_BIT clocks
);
    localparam integer W = (CLKS_PER_BIT < 2) ? 1 : $clog2(CLKS_PER_BIT);
    reg [W-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0; tick <= 1'b0;
        end else if (count == CLKS_PER_BIT-1) begin
            count <= 0; tick <= 1'b1;          // one bit period elapsed
        end else begin
            count <= count + 1'b1; tick <= 1'b0;
        end
    end
endmodule

module tb_baud_gen;
    localparam integer CLKS_PER_BIT = 4;
    reg clk=1'b0, rst_n=1'b0;
    wire tick;
    integer ticks = 0;

    baud_gen #(CLKS_PER_BIT) dut (.clk(clk), .rst_n(rst_n), .tick(tick));

    always #5 clk = ~clk;                      // 100 MHz

    always @(posedge clk)
        if (rst_n && tick) begin
            ticks = ticks + 1;
            $display("[%0t] tick #%0d (one serial bit period)", $time, ticks);
        end

    initial begin
        $display("CLKS_PER_BIT=%0d -> a tick is expected every %0d clocks", CLKS_PER_BIT, CLKS_PER_BIT);
        repeat (2) @(posedge clk); rst_n = 1'b1;
        repeat (20) @(posedge clk);
        $display("Ticks counted over 20 clocks = %0d", ticks);
        $finish;
    end
endmodule
