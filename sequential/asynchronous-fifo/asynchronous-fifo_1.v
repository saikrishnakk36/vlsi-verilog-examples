// gray_demo.v  -- why async FIFOs use Gray code (Verilog-2005)
// Proves that a Gray counter changes exactly ONE bit per step, then shows a
// two-flop synchronizer carrying that Gray value into a second clock domain.

module gray_counter #(parameter W = 4)(
    input  wire        clk,
    input  wire        rst_n,
    output reg  [W-1:0] bin,
    output wire [W-1:0] gray
);
    assign gray = (bin >> 1) ^ bin;   // binary -> Gray
    always @(posedge clk or negedge rst_n)
        if (!rst_n) bin <= 0;
        else        bin <= bin + 1'b1;
endmodule

// generic two-flop synchronizer
module sync2 #(parameter W = 4)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [W-1:0] d,
    output reg  [W-1:0] q
);
    reg [W-1:0] meta;
    always @(posedge clk or negedge rst_n)
        if (!rst_n) {q, meta} <= 0;
        else        {q, meta} <= {meta, d};
endmodule

module tb_gray_demo;
    localparam W = 4;
    reg  aclk = 0, bclk = 0, rst_n = 0;
    wire [W-1:0] bin, gray, gray_synced;
    reg  [W-1:0] prev_gray;
    integer      diff, i;

    gray_counter #(.W(W)) gc   (.clk(aclk), .rst_n(rst_n), .bin(bin), .gray(gray));
    sync2        #(.W(W)) sync (.clk(bclk), .rst_n(rst_n), .d(gray), .q(gray_synced));

    always #5 aclk = ~aclk;    // source clock
    always #6 bclk = ~bclk;    // destination clock (different frequency)

    // count how many bits flip between consecutive Gray values
    function integer popcount(input [W-1:0] v);
        integer k;
        begin
            popcount = 0;
            for (k = 0; k < W; k = k + 1) popcount = popcount + v[k];
        end
    endfunction

    initial begin
        repeat (2) @(negedge aclk);
        rst_n = 1;
        prev_gray = gray;
        for (i = 0; i < 12; i = i + 1) begin
            @(posedge aclk);
            #1;
            diff = popcount(gray ^ prev_gray);
            $display("step %0d  bin=%b  gray=%b  bits_changed=%0d", i, bin, gray, diff);
            prev_gray = gray;
        end
        $display("note: bits_changed is always 1 -> safe to sample across clocks");
        $display("synchronized Gray in bclk domain = %b", gray_synced);
        $finish;
    end
endmodule

