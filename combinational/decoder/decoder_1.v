// 2-to-4 line decoder, behavioral style, active-high enable and outputs
module decoder_2to4_beh (
    input  wire       en,     // active-high enable
    input  wire [1:0] sel,    // 2-bit select input
    output reg  [3:0] y       // 4-bit one-hot output
);
    always @(*) begin
        if (!en)
            y = 4'b0000;              // disabled: all outputs low
        else begin
            case (sel)
                2'b00: y = 4'b0001;
                2'b01: y = 4'b0010;
                2'b10: y = 4'b0100;
                2'b11: y = 4'b1000;
                default: y = 4'b0000;
            endcase
        end
    end
endmodule

// Testbench
module tb_decoder_2to4_beh;
    reg        en;
    reg  [1:0] sel;
    wire [3:0] y;
    integer    i;

    decoder_2to4_beh dut (.en(en), .sel(sel), .y(y));

    initial begin
        $display("time en sel | y");
        $monitor("%4t  %b  %b | %b", $time, en, sel, y);

        // Enable low: output must stay 0 regardless of sel
        en = 1'b0; sel = 2'b10; #10;

        // Enable high: sweep every select value
        en = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0];
            #10;
        end

        $display("Done: one-hot output follows sel when en=1.");
        $finish;
    end
endmodule
