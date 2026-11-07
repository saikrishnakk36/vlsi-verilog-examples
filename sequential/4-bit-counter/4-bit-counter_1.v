// 4-bit synchronous up/down counter
// Features: count enable, synchronous load, asynchronous active-low reset
module counter_4bit (
    input  wire       clk,       // clock
    input  wire       rst_n,     // asynchronous reset, active low
    input  wire       en,        // count enable
    input  wire       load,      // synchronous parallel load
    input  wire       up_down,   // 1 = count up, 0 = count down
    input  wire [3:0] data_in,   // value loaded when load = 1
    output reg  [3:0] count      // current count value
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'b0000;                      // async clear
        else if (load)
            count <= data_in;                      // sync load wins over count
        else if (en)
            count <= up_down ? count + 4'd1
                             : count - 4'd1;        // up or down
        // else: hold current value
    end

endmodule


// Testbench: drives reset, load, up, down and hold
module counter_4bit_tb;
    reg        clk, rst_n, en, load, up_down;
    reg  [3:0] data_in;
    wire [3:0] count;

    counter_4bit dut (
        .clk(clk), .rst_n(rst_n), .en(en), .load(load),
        .up_down(up_down), .data_in(data_in), .count(count)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        $display(" time rstn en ld ud din | count");
        $monitor("%5t   %b   %b  %b  %b  %0d |   %0d",
                 $time, rst_n, en, load, up_down, data_in, count);

        // Initialise and apply async reset
        clk = 0; rst_n = 0; en = 0; load = 0; up_down = 1; data_in = 4'd0;
        #12 rst_n = 1;          // release reset between edges

        // Count up for 5 clocks: 0->1->2->3->4->5
        en = 1; up_down = 1;
        #50;

        // Synchronous load of 9
        en = 0; load = 1; data_in = 4'd9;
        #10 load = 0;

        // Count down for 4 clocks: 9->8->7->6->5
        en = 1; up_down = 0;
        #40;

        // Hold for 2 clocks (enable low)
        en = 0;
        #20;

        // Asynchronous reset asserted mid-operation
        rst_n = 0;
        #3  rst_n = 1;
        #10;

        $display("Simulation complete.");
        $finish;
    end
endmodule
