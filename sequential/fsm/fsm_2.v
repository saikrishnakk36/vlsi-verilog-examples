// Mealy FSM: overlapping sequence detector for "1011"
// 3-always-block style. Mealy output depends on state AND current input,
// so the detect pulse appears one cycle earlier than the Moore version.
module seq_detector_mealy (
    input  wire clk,
    input  wire rst_n,  // active-low synchronous reset
    input  wire din,    // serial data input, MSB-first
    output reg  dout     // high during the cycle the 4th bit arrives
);

    localparam [1:0] S_IDLE = 2'd0, // no useful bits
                     S_1    = 2'd1, // seen "1"
                     S_10   = 2'd2, // seen "10"
                     S_101  = 2'd3; // seen "101"

    reg [1:0] state, next_state;

    // 1) State register
    always @(posedge clk) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // 2) Next-state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE : next_state = din ? S_1   : S_IDLE;
            S_1    : next_state = din ? S_1   : S_10;
            S_10   : next_state = din ? S_101 : S_IDLE;
            S_101  : next_state = din ? S_1   : S_10; // on the matching 1, overlap back to S_1
            default: next_state = S_IDLE;
        endcase
    end

    // 3) Output logic: Mealy output = f(state, input)
    always @(*) begin
        dout = (state == S_101) && (din == 1'b1); // last bit of 1011 seen
    end

endmodule

module tb_seq_detector_mealy;
    reg clk, rst_n, din;
    wire dout;
    integer i;

    reg [0:6] stream = 7'b1011011; // two overlapping "1011" matches

    seq_detector_mealy dut (.clk(clk), .rst_n(rst_n), .din(din), .dout(dout));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display("time rst din match");
        rst_n = 1'b0; din = 1'b0;
        @(negedge clk); rst_n = 1'b1;

        for (i = 0; i < 7; i = i + 1) begin
            din = stream[i];
            #1;                 // Mealy output reacts to din within the cycle
            $display("%4t  %b   %b    %b", $time, rst_n, din, dout);
            if (dout) $display("    >> MATCH: 1011 detected as bit index %0d arrives", i);
            @(posedge clk);
        end

        $display("Simulation finished.");
        $finish;
    end
endmodule

