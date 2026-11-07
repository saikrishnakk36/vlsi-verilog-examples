// clk_div_even.v  -- divide by any EVEN integer DIV, 50% duty cycle
module clk_div_even #(
    parameter DIV = 4            // even, >= 2
)(
    input  wire clk_in,
    input  wire rst_n,
    output reg  clk_out
);
    localparam HALF = DIV / 2;
    reg [31:0] count;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            count   <= 32'd0;
            clk_out <= 1'b0;
        end else if (count == HALF - 1) begin
            count   <= 32'd0;
            clk_out <= ~clk_out;     // flip output every HALF input cycles
        end else begin
            count   <= count + 32'd1;
        end
    end
endmodule

// ---- Testbench ----
module tb_clk_div_even;
    reg  clk_in;
    reg  rst_n;
    wire clk_out;

    clk_div_even #(.DIV(4)) dut (    // divide by 4
        .clk_in  (clk_in),
        .rst_n   (rst_n),
        .clk_out (clk_out)
    );

    initial clk_in = 1'b0;
    always #5 clk_in = ~clk_in;      // period 10

    initial begin
        rst_n = 1'b0;
        #12 rst_n = 1'b1;
    end

    initial begin
        $monitor("t=%0t  clk_in=%b  clk_out=%b", $time, clk_in, clk_out);
        #180 $display("Done: clk_out period is 4x clk_in period");
        $finish;
    end
endmodule
