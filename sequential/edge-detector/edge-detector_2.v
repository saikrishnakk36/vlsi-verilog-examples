// edge_detect_sync.v -- edge detector with a 2-FF synchronizer and
// fully registered pulse outputs, for a signal from another clock domain.
//
// Two back-to-back flip-flops (sync0, sync1) first retime the asynchronous
// input into the clk domain. A third flip-flop (sync2) keeps the sample
// from one cycle earlier. Edges are detected between sync1 and sync2 and
// the pulses themselves are registered, so the outputs are glitch-free.
module edge_detect_sync (
    input  wire clk,
    input  wire rst_n,
    input  wire async_in,   // unsynchronized input
    output reg  rise,
    output reg  fall
);
    reg sync0, sync1, sync2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
            sync2 <= 1'b0;
            rise  <= 1'b0;
            fall  <= 1'b0;
        end else begin
            sync0 <= async_in;          // metastability catcher
            sync1 <= sync0;             // clean synchronous sample
            sync2 <= sync1;             // previous synchronous sample
            rise  <= sync1 & ~sync2;    // registered rising pulse
            fall  <= ~sync1 & sync2;    // registered falling pulse
        end
    end
endmodule

// ---------------------------------------------------------------------
// Testbench: drive async_in off the clock grid to mimic another domain.
module edge_detect_sync_tb;
    reg  clk, rst_n, async_in;
    wire rise, fall;

    edge_detect_sync dut (
        .clk(clk), .rst_n(rst_n), .async_in(async_in),
        .rise(rise), .fall(fall)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $monitor("t=%0t async_in=%b | rise=%b fall=%b",
                 $time, async_in, rise, fall);
        rst_n    = 1'b0;
        async_in = 1'b0;
        #12 rst_n = 1'b1;   // deassert reset off the clock edge

        #23 async_in = 1'b1;  // rising edge at an odd time
        #37 async_in = 1'b0;  // falling edge at an odd time
        #40 async_in = 1'b1;  // rising edge again

        #40 $display("simulation finished");
        $finish;
    end
endmodule

