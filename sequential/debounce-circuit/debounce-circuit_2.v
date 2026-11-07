// press_counter_tb.v  --  why debouncing matters: naive vs debounced press count
`timescale 1ns/1ns

module debounce #(
    parameter integer STABLE_COUNT = 4    // clk cycles the input must stay stable
)(
    input  wire clk,
    input  wire rst_n,
    input  wire noisy_in,
    output reg  clean_out
);
    localparam integer CW = (STABLE_COUNT < 2) ? 1 : $clog2(STABLE_COUNT);

    reg          sync0, sync1;
    reg [CW-1:0] count;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) {sync1, sync0} <= 2'b00;
        else        {sync1, sync0} <= {sync0, noisy_in};

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            count     <= {CW{1'b0}};
            clean_out <= 1'b0;
        end else if (sync1 == clean_out) begin
            count <= {CW{1'b0}};
        end else begin
            count <= count + 1'b1;
            if (count == STABLE_COUNT - 1) begin
                clean_out <= sync1;
                count     <= {CW{1'b0}};
            end
        end
endmodule


module tb_press_counter;
    reg  clk, rst_n, noisy_in;
    wire clean;

    reg       naive_q, clean_q;
    reg [7:0] naive_cnt, clean_cnt;
    integer   k;

    debounce #(.STABLE_COUNT(4)) dut (
        .clk(clk), .rst_n(rst_n), .noisy_in(noisy_in), .clean_out(clean));

    initial clk = 1'b0;
    always  #5 clk = ~clk;

    // count rising edges on the RAW line (naive) and on the CLEAN line
    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            naive_q <= 1'b0; clean_q <= 1'b0;
            naive_cnt <= 8'd0; clean_cnt <= 8'd0;
        end else begin
            naive_q <= noisy_in;
            clean_q <= clean;
            if ( noisy_in & ~naive_q) naive_cnt <= naive_cnt + 1'b1;
            if ( clean    & ~clean_q) clean_cnt <= clean_cnt + 1'b1;
        end

    // one make/break bounce: HIGH then LOW, each 12 ns (well under the
    // 40 ns debounce window), so the raw line never settles mid-bounce
    task one_bounce;
        begin
            noisy_in = 1'b1; #12;
            noisy_in = 1'b0; #12;
        end
    endtask

    initial begin
        rst_n = 1'b0; noisy_in = 1'b0;
        #13 rst_n = 1'b1;

        // ONE physical button press, but the contact chatters several times
        #20;
        for (k = 0; k < 3; k = k + 1) one_bounce;
        noisy_in = 1'b1;              // finally settles pressed
        #120;

        $display("one physical press with contact bounce:");
        $display("  naive rising-edge count     = %0d", naive_cnt);
        $display("  debounced rising-edge count = %0d", clean_cnt);
        $finish;
    end
endmodule
