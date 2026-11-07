// debounce_tb.v  --  counter-based switch debouncer + bounce-injecting bench
`timescale 1ns/1ns

module debounce #(
    parameter integer STABLE_COUNT = 16   // clk cycles the input must stay stable
)(
    input  wire clk,
    input  wire rst_n,      // active-low reset
    input  wire noisy_in,   // raw, bouncing switch line
    output reg  clean_out   // debounced, glitch-free level
);
    // counter width: enough bits to reach STABLE_COUNT-1
    localparam integer CW = (STABLE_COUNT < 2) ? 1 : $clog2(STABLE_COUNT);

    reg          sync0, sync1;   // two-FF synchronizer
    reg [CW-1:0] count;

    // 1) bring the asynchronous switch line into the clk domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
        end else begin
            sync0 <= noisy_in;
            sync1 <= sync0;
        end
    end

    // 2) require the synced input to hold a new value for STABLE_COUNT cycles
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count     <= {CW{1'b0}};
            clean_out <= 1'b0;
        end else if (sync1 == clean_out) begin
            count <= {CW{1'b0}};              // input agrees with output: reset timer
        end else begin
            count <= count + 1'b1;            // input differs: keep timing it
            if (count == STABLE_COUNT - 1) begin
                clean_out <= sync1;           // stable long enough -> accept it
                count     <= {CW{1'b0}};
            end
        end
    end
endmodule


module tb_debounce;
    reg  clk, rst_n, noisy_in;
    wire clean_out;

    // small STABLE_COUNT so the simulation finishes quickly
    debounce #(.STABLE_COUNT(4)) dut (
        .clk(clk), .rst_n(rst_n),
        .noisy_in(noisy_in), .clean_out(clean_out)
    );

    initial clk = 1'b0;
    always  #5 clk = ~clk;                    // 100 MHz, 10 ns period

    // print every time the debounced output changes
    always @(clean_out)
        $display("[%4t ns] clean_out = %b", $time, clean_out);

    // drive 6 chattering samples, then settle on final_val
    task inject_bounce(input final_val);
        integer k;
        begin
            for (k = 0; k < 6; k = k + 1) begin
                noisy_in = $random;           // random contact chatter
                #8;
            end
            noisy_in = final_val;             // mechanical contact settles
        end
    endtask

    initial begin
        rst_n = 1'b0; noisy_in = 1'b0;
        #13 rst_n = 1'b1;

        #20 $display("[%4t ns] PRESS  : bouncing, will settle HIGH", $time);
        inject_bounce(1'b1);
        #120;

        $display("[%4t ns] RELEASE: bouncing, will settle LOW", $time);
        inject_bounce(1'b0);
        #120;

        $display("[%4t ns] done, final clean_out = %b", $time, clean_out);
        $finish;
    end
endmodule
