// 3-to-8 line decoder, behavioral style with a shift, active-high enable
module decoder_3to8_beh (
    input  wire       en,     // active-high enable
    input  wire [2:0] sel,    // 3-bit select input
    output reg  [7:0] y       // 8-bit one-hot output
);
    always @(*) begin
        if (!en)
            y = 8'b0000_0000;         // disabled: all outputs low
        else
            y = 8'b0000_0001 << sel;  // place the single '1' at position sel
    end
endmodule

// Testbench
module tb_decoder_3to8_beh;
    reg        en;
    reg  [2:0] sel;
    wire [7:0] y;
    integer    i;

    decoder_3to8_beh dut (.en(en), .sel(sel), .y(y));

    initial begin
        $display("time en sel  | y");
        $monitor("%4t  %b  %b | %b", $time, en, sel, y);

        en = 1'b0; sel = 3'b101; #10;  // disabled

        en = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            sel = i[2:0];
            #10;
        end

        $display("Done: active output index equals sel when en=1.");
        $finish;
    end
endmodule
