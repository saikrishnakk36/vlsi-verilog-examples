// 2-to-4 line decoder, dataflow style using continuous assignments
module decoder_2to4_df (
    input  wire       en,     // active-high enable
    input  wire [1:0] sel,    // 2-bit select input
    output wire [3:0] y       // 4-bit one-hot output
);
    assign y[0] = en & ~sel[1] & ~sel[0];
    assign y[1] = en & ~sel[1] &  sel[0];
    assign y[2] = en &  sel[1] & ~sel[0];
    assign y[3] = en &  sel[1] &  sel[0];
endmodule

// Testbench
module tb_decoder_2to4_df;
    reg        en;
    reg  [1:0] sel;
    wire [3:0] y;
    integer    i;

    decoder_2to4_df dut (.en(en), .sel(sel), .y(y));

    initial begin
        $display("time en sel | y");
        $monitor("%4t  %b  %b | %b", $time, en, sel, y);

        en = 1'b0; sel = 2'b11; #10;   // disabled

        en = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0];
            #10;
        end

        $display("Done: each assign drives exactly one output line.");
        $finish;
    end
endmodule
