// Moore FSM: overlapping sequence detector for "1011"
// 3-always-block coding style: state register, next-state logic, output logic
module seq_detector_moore (
    input  wire clk,
    input  wire rst_n,   // active-low synchronous reset
    input  wire din,     // serial data input, MSB-first
    output reg  dout      // pulses high the cycle AFTER the 4th matching bit
);

    // State encoding (localparam keeps it readable and synthesizable)
    localparam [2:0] S_IDLE = 3'd0, // no useful bits yet
                     S_1    = 3'd1, // seen "1"
                     S_10   = 3'd2, // seen "10"
                     S_101  = 3'd3, // seen "101"
                     S_1011 = 3'd4; // seen "1011" -> match

    reg [2:0] state, next_state;

    // 1) State register: the ONLY sequential block
    always @(posedge clk) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // 2) Next-state logic: pure combinational, no memory
    always @(*) begin
        next_state = state; // safe default avoids latches
        case (state)
            S_IDLE : next_state = din ? S_1   : S_IDLE;
            S_1    : next_state = din ? S_1   : S_10;
            S_10   : next_state = din ? S_101 : S_IDLE;
            S_101  : next_state = din ? S_1011: S_10;
            S_1011 : next_state = din ? S_1   : S_10; // overlap-aware
            default: next_state = S_IDLE;
        endcase
    end

    // 3) Output logic: Moore output depends ONLY on the current state
    always @(*) begin
        dout = (state == S_1011);
    end

endmodule

module tb_seq_detector_moore;
    reg clk, rst_n, din;
    wire dout;
    integer i;

    // stimulus: 1 0 1 1 0 1 1  -> contains overlapping "1011" twice
    reg [0:6] stream = 7'b1011011;

    seq_detector_moore dut (.clk(clk), .rst_n(rst_n), .din(din), .dout(dout));

    initial clk = 1'b0;
    always #5 clk = ~clk; // 100 MHz

    initial begin
        $display("time rst din state_out match");
        rst_n = 1'b0; din = 1'b0;
        @(negedge clk); rst_n = 1'b1; // release reset

        for (i = 0; i < 7; i = i + 1) begin
            din = stream[i];
            @(posedge clk);          // din sampled here
            #1;                       // let combinational dout settle
            $display("%4t  %b   %b     ->      %b", $time, rst_n, din, dout);
            if (dout) $display("    >> MATCH: 1011 detected ending at bit index %0d", i);
        end

        din = 1'b0;
        @(posedge clk); #1;
        $display("%4t  %b   %b     ->      %b", $time, rst_n, din, dout);
        if (dout) $display("    >> MATCH: 1011 detected (trailing)");

        $display("Simulation finished.");
        $finish;
    end
endmodule

