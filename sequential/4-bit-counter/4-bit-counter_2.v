// Same 4-bit up/down counter, shown wrapping around its 4-bit range
module counter_4bit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       en,
    input  wire       load,
    input  wire       up_down,
    input  wire [3:0] data_in,
    output reg  [3:0] count
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'b0000;
        else if (load)
            count <= data_in;
        else if (en)
            count <= up_down ? count + 4'd1 : count - 4'd1;
    end
endmodule


module counter_4bit_tb;
    reg        clk, rst_n, en, load, up_down;
    reg  [3:0] data_in;
    wire [3:0] count;

    counter_4bit dut (
        .clk(clk), .rst_n(rst_n), .en(en), .load(load),
        .up_down(up_down), .data_in(data_in), .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("t=%0t  up_down=%b  count=%2d (0x%h)",
                 $time, up_down, count, count);

        clk = 0; rst_n = 0; en = 0; load = 0; up_down = 1; data_in = 0;
        #12 rst_n = 1;

        // Load 14, then count up: 14 -> 15 -> 0 (overflow wrap)
        load = 1; data_in = 4'd14; #10 load = 0;
        en = 1; up_down = 1; #30;

        // Now count down from 1 through 0 -> 15 (underflow wrap)
        up_down = 0; #30;

        $display("Done: 4-bit counter wraps modulo-16.");
        $finish;
    end
endmodule
