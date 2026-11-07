// seq_mealy_1011.v -- Mealy FSM, detects "1011" (overlapping)
module seq_mealy_1011 (
    input  wire clk,
    input  wire rst,      // synchronous, active-high
    input  wire din,      // serial input, one bit per clock
    output reg  detected  // asserted on the detecting transition
);
    localparam [1:0] S0 = 2'd0, // matched ""
                     S1 = 2'd1, // matched "1"
                     S2 = 2'd2, // matched "10"
                     S3 = 2'd3; // matched "101"

    reg [1:0] state, nxt;

    // Next-state + Mealy output (combinational)
    always @(*) begin
        nxt = state;
        detected = 1'b0;
        case (state)
            S0: nxt = din ? S1 : S0;
            S1: nxt = din ? S1 : S2;
            S2: nxt = din ? S3 : S0;
            S3: begin
                    if (din) begin
                        detected = 1'b1; // 101 + 1 => 1011 seen
                        nxt = S1;        // overlap: trailing '1' starts next
                    end else begin
                        nxt = S2;        // 101 + 0 => suffix "10"
                    end
                end
            default: nxt = S0;
        endcase
    end

    // State register (sequential)
    always @(posedge clk) begin
        if (rst) state <= S0;
        else     state <= nxt;
    end
endmodule

// -------- testbench (feeds a serial bit stream) --------
module tb_mealy;
    reg clk, rst, din;
    wire detected;
    integer i, hits;

    // Same stream as the Moore demo: 1 0 1 1 0 1 1 (plus flush zeros)
    localparam STREAM_LEN = 10;
    reg [0:STREAM_LEN-1] stream = 10'b1011011000;

    seq_mealy_1011 dut (.clk(clk), .rst(rst), .din(din), .detected(detected));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst = 1'b1; din = 1'b0; hits = 0;
        @(negedge clk); @(negedge clk);
        rst = 1'b0;
        $display("time | bit | state | detected");
        for (i = 0; i < STREAM_LEN; i = i + 1) begin
            din = stream[i];
            #1; // let Mealy output settle on the current bit
            $display("%4t |  %b  |   %0d   |    %b", $time, din, dut.state, detected);
            if (detected) begin
                hits = hits + 1;
                $display("        --> 1011 DETECTED (Mealy, overlapping)");
            end
            @(negedge clk);
        end
        $display("Total detections = %0d (expected 2)", hits);
        $finish;
    end
endmodule
