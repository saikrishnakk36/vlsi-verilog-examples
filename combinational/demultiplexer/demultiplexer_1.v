// 1-to-4 demultiplexer -- behavioral style
module demux_1to4_behav (
    input  wire       din,   // single data input
    input  wire [1:0] sel,   // 2-bit select
    output reg  [3:0] y      // 4 outputs
);
    always @(*) begin
        y = 4'b0000;          // default: every output low
        case (sel)
            2'b00: y[0] = din;
            2'b01: y[1] = din;
            2'b10: y[2] = din;
            2'b11: y[3] = din;
        endcase
    end
endmodule

// Testbench: drive din through every select line
module tb_demux_behav;
    reg        din;
    reg  [1:0] sel;
    wire [3:0] y;
    integer    i;

    demux_1to4_behav dut (.din(din), .sel(sel), .y(y));

    initial begin
        $display("time din sel | y3 y2 y1 y0");
        $display("------------+------------");
        din = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0];
            #5;
            $display("%4t  %b   %b |  %b  %b  %b  %b",
                     $time, din, sel, y[3], y[2], y[1], y[0]);
        end
        din = 1'b0; sel = 2'b10; #5;
        $display("%4t  %b   %b |  %b  %b  %b  %b   (din=0 => all low)",
                 $time, din, sel, y[3], y[2], y[1], y[0]);
        $finish;
    end
endmodule
