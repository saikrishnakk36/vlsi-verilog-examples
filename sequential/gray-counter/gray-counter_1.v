// gray_counter_4bit.v -- 4-bit binary counter with binary->gray conversion
module gray_counter_4bit (
    input  wire       clk,
    input  wire       rst_n,    // active-low synchronous reset
    output reg  [3:0] bin,      // underlying binary count
    output wire [3:0] gray      // Gray-coded output
);
    // Count up in binary on every rising clock edge
    always @(posedge clk) begin
        if (!rst_n)
            bin <= 4'b0000;
        else
            bin <= bin + 4'b0001;
    end

    // Binary-to-Gray: gray = bin XOR (bin >> 1)
    assign gray = bin ^ (bin >> 1);
endmodule

// --- Testbench (last module) ---
module tb_gray_counter_4bit;
    reg        clk;
    reg        rst_n;
    wire [3:0] bin;
    wire [3:0] gray;
    integer    i;

    gray_counter_4bit dut (
        .clk(clk), .rst_n(rst_n), .bin(bin), .gray(gray)
    );

    // 10-time-unit clock period: rising edges at 5, 15, 25, ...
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;              // hold reset over the first edge
        #12 rst_n = 1'b1;          // release mid-cycle, away from any edge
        $display("time  bin   gray");
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            #1 $display("%4t  %b  %b", $time, bin, gray);
        end
        $finish;
    end
endmodule
