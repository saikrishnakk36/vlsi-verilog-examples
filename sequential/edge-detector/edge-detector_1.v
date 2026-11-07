// edge_detect.v -- rising / falling / both edge detector
// Registered-sample technique: one flip-flop remembers the previous
// synchronous sample of sig_in, then combinational logic compares the
// live sample with the stored one to emit single-cycle pulses.
module edge_detect (
    input  wire clk,     // sampling clock
    input  wire rst_n,   // active-low asynchronous reset
    input  wire sig_in,  // signal already synchronous to clk
    output wire rise,    // 1 for one clk when sig_in goes 0 -> 1
    output wire fall,    // 1 for one clk when sig_in goes 1 -> 0
    output wire both     // 1 for one clk on either transition
);
    // sig_q holds the value sig_in had at the previous rising clk edge.
    reg sig_q;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sig_q <= 1'b0;
        else
            sig_q <= sig_in;
    end

    // Compare the current sample against the stored previous sample.
    assign rise = sig_in & ~sig_q;  // low last cycle, high now
    assign fall = ~sig_in & sig_q;  // high last cycle, low now
    assign both = sig_in ^ sig_q;   // any difference between the two
endmodule

// ---------------------------------------------------------------------
// Testbench: inject a rising edge, a falling edge and a one-cycle pulse.
module edge_detect_tb;
    reg  clk, rst_n, sig_in;
    wire rise, fall, both;

    edge_detect dut (
        .clk(clk), .rst_n(rst_n), .sig_in(sig_in),
        .rise(rise), .fall(fall), .both(both)
    );

    // 10 time-unit clock period.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $monitor("t=%0t rst_n=%b sig_in=%b | rise=%b fall=%b both=%b",
                 $time, rst_n, sig_in, rise, fall, both);
        rst_n  = 1'b0;
        sig_in = 1'b0;

        // Release reset just after a clock edge.
        @(posedge clk); #1 rst_n = 1'b1;
        repeat (2) @(posedge clk);

        // Inject a rising edge (0 -> 1).
        #1 sig_in = 1'b1;
        repeat (2) @(posedge clk);

        // Inject a falling edge (1 -> 0).
        #1 sig_in = 1'b0;
        repeat (2) @(posedge clk);

        // Inject a one-cycle-wide pulse: rise then fall back to back.
        #1 sig_in = 1'b1;
        @(posedge clk);
        #1 sig_in = 1'b0;
        repeat (2) @(posedge clk);

        $display("simulation finished");
        $finish;
    end
endmodule

