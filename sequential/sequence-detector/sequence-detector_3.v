// seq_moore_1011_novlp.v -- Moore FSM, detects "1011" (NON-overlapping)
// After a hit the machine restarts the search from scratch (no reuse of '1').
module seq_moore_1011_novlp (
    input  wire clk,
    input  wire rst,
    input  wire din,
    output wire detected
);
    localparam [2:0] S0 = 3'd0, // matched ""
                     S1 = 3'd1, // matched "1"
                     S2 = 3'd2, // matched "10"
                     S3 = 3'd3, // matched "101"
                     S4 = 3'd4; // matched "1011" (accept, then restart)

    reg [2:0] state, nxt;

    always @(*) begin
        case (state)
            S0: nxt = din ? S1 : S0;
            S1: nxt = din ? S1 : S2;
            S2: nxt = din ? S3 : S0;
            S3: nxt = din ? S4 : S2;
            S4: nxt = din ? S1 : S0; // NO overlap: behave like a fresh S0
            default: nxt = S0;
        endcase
    end

    always @(posedge clk) begin
        if (rst) state <= S0;
        else     state <= nxt;
    end

    assign detected = (state == S4);
endmodule

// -------- testbench (feeds a serial bit stream) --------
module tb_novlp;
    reg clk, rst, din;
    wire detected;
    integer i, hits;

    // Same stream 1 0 1 1 0 1 1 : with overlap you get 2 hits,
    // without overlap only the first 1011 (bit 4) counts.
    localparam STREAM_LEN = 10;
    reg [0:STREAM_LEN-1] stream = 10'b1011011000;

    seq_moore_1011_novlp dut (.clk(clk), .rst(rst), .din(din), .detected(detected));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst = 1'b1; din = 1'b0; hits = 0;
        @(negedge clk); @(negedge clk);
        rst = 1'b0;
        $display("time | bit | state | detected");
        for (i = 0; i < STREAM_LEN; i = i + 1) begin
            din = stream[i];
            @(negedge clk);
            $display("%4t |  %b  |   %0d   |    %b", $time, din, dut.state, detected);
            if (detected) begin
                hits = hits + 1;
                $display("        --> 1011 DETECTED (non-overlapping)");
            end
        end
        $display("Total detections = %0d (expected 1)", hits);
        $finish;
    end
endmodule
