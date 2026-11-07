// clk_div2.v  -- divide the input clock by 2 (exact 50% duty cycle)
module clk_div2 (
    input  wire clk_in,
    input  wire rst_n,
    output reg  clk_out
);
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n)
            clk_out <= 1'b0;
        else
            clk_out <= ~clk_out;
    end
endmodule

// ---- Testbench ----
module tb_clk_div2;
    reg  clk_in;
    reg  rst_n;
    wire clk_out;

    clk_div2 dut (
        .clk_in  (clk_in),
        .rst_n   (rst_n),
        .clk_out (clk_out)
    );

    // 100 MHz source clock: period = 10 time units
    initial clk_in = 1'b0;
    always #5 clk_in = ~clk_in;

    initial begin
        rst_n = 1'b0;
        #12 rst_n = 1'b1;              // release reset after a couple of edges
    end

    initial begin
        $monitor("t=%0t  clk_in=%b  clk_out=%b", $time, clk_in, clk_out);
        #90 $display("Done: clk_out toggles once per rising edge of clk_in");
        $finish;
    end
endmodule
