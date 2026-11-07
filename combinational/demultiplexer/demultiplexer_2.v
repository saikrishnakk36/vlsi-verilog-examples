// 1-to-4 demultiplexer -- dataflow style
module demux_1to4_dataflow (
    input  wire       din,
    input  wire [1:0] sel,
    output wire [3:0] y
);
    // Each output = din gated by one decoded select combination
    assign y[0] = din & ~sel[1] & ~sel[0];
    assign y[1] = din & ~sel[1] &  sel[0];
    assign y[2] = din &  sel[1] & ~sel[0];
    assign y[3] = din &  sel[1] &  sel[0];
endmodule

// Testbench: monitor outputs while select cycles 00 -> 11
module tb_demux_dataflow;
    reg        din;
    reg  [1:0] sel;
    wire [3:0] y;
    integer    i;

    demux_1to4_dataflow dut (.din(din), .sel(sel), .y(y));

    initial begin
        $monitor("t=%4t din=%b sel=%b -> y=%b", $time, din, sel, y);
        din = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0];
            #5;
        end
        din = 1'b0; sel = 2'b11; #5;
        $finish;
    end
endmodule
