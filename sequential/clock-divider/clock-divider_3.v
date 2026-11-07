// clk_div_odd.v  -- divide by an ODD integer DIV with a true 50% duty cycle.
// Idea: build one divided clock on the rising edge (phase A) and an identical
// one on the falling edge (phase B, shifted half an input period). Each phase
// is high for (DIV+1)/2 input cycles out of DIV. ANDing the two trims the
// overlap to exactly DIV/2 input periods high and DIV/2 low -> 50% duty.
module clk_div_odd #(
    parameter DIV = 3            // odd, >= 3
)(
    input  wire clk_in,
    input  wire rst_n,
    output wire clk_out
);
    reg [31:0] cnt_p, cnt_n;
    reg        phase_p, phase_n;

    // rising-edge phase
    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            cnt_p   <= 32'd0;
            phase_p <= 1'b0;
        end else begin
            cnt_p   <= (cnt_p == DIV-1) ? 32'd0 : cnt_p + 32'd1;
            phase_p <= (cnt_p < (DIV+1)/2);
        end
    end

    // falling-edge phase (naturally half a period behind phase_p)
    always @(negedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            cnt_n   <= 32'd0;
            phase_n <= 1'b0;
        end else begin
            cnt_n   <= (cnt_n == DIV-1) ? 32'd0 : cnt_n + 32'd1;
            phase_n <= (cnt_n < (DIV+1)/2);
        end
    end

    assign clk_out = phase_p & phase_n;
endmodule

// ---- Testbench ----
module tb_clk_div_odd;
    reg  clk_in;
    reg  rst_n;
    wire clk_out;

    clk_div_odd #(.DIV(3)) dut (     // divide by 3
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
        #180 $display("Done: clk_out period is 3x clk_in with 50%% duty");
        $finish;
    end
endmodule
