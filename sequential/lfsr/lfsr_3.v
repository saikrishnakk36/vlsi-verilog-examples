// PRBS7 serial generator: x^7 + x^6 + 1 (ITU-T O.150), maximal length 127
module prbs7_gen (
    input  wire       clk,
    input  wire       rst_n,
    output wire       prbs      // one pseudo-random bit per clock
);
    reg [6:0] lfsr;
    wire feedback = lfsr[6] ^ lfsr[5];   // taps on bits 7 and 6

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            lfsr <= 7'h7F;               // any non-zero seed
        else
            lfsr <= {lfsr[5:0], feedback};
    end

    assign prbs = lfsr[6];
endmodule

module tb_prbs7_gen;
    reg clk = 0, rst_n = 0;
    wire prbs;
    integer count, ones;
    reg [6:0] seed_state;

    prbs7_gen dut (.clk(clk), .rst_n(rst_n), .prbs(prbs));

    always #5 clk = ~clk;

    initial begin
        count = 0; ones = 0;
        @(negedge clk) rst_n = 1;
        @(posedge clk);
        seed_state = dut.lfsr;
        $write("first 20 PRBS bits: ");
        begin : walk
            integer i;
            for (i = 0; i < 200; i = i + 1) begin
                if (i < 20) $write("%b", prbs);
                if (prbs) ones = ones + 1;
                @(posedge clk);
                count = count + 1;
                if (dut.lfsr == seed_state) disable walk;
            end
        end
        $display("");
        $display("PERIOD = %0d (expected 127)", count);
        $display("ONES   = %0d, ZEROS = %0d (balanced +1)", ones, count-ones);
        $finish;
    end
endmodule
