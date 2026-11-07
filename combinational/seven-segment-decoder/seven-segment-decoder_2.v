// seven_seg_hex.v -- Hexadecimal (0-F) to 7-segment decoder, common cathode
// Segment order: seg = {a,b,c,d,e,f,g}, a segment lights when its bit is 1.
module seven_seg_hex (
    input      [3:0] hex,   // 0x0 .. 0xF
    output reg [6:0] seg    // {a,b,c,d,e,f,g}, active-high
);
    always @(*) begin
        case (hex)
            4'h0: seg = 7'b1111110;
            4'h1: seg = 7'b0110000;
            4'h2: seg = 7'b1101101;
            4'h3: seg = 7'b1111001;
            4'h4: seg = 7'b0110011;
            4'h5: seg = 7'b1011011;
            4'h6: seg = 7'b1011111;
            4'h7: seg = 7'b1110000;
            4'h8: seg = 7'b1111111;
            4'h9: seg = 7'b1111011;
            4'hA: seg = 7'b1110111;
            4'hB: seg = 7'b0011111;
            4'hC: seg = 7'b1001110;
            4'hD: seg = 7'b0111101;
            4'hE: seg = 7'b1001111;
            4'hF: seg = 7'b1000111;
            default: seg = 7'b0000000;
        endcase
    end
endmodule

module tb_seven_seg_hex;
    reg  [3:0] hex;
    wire [6:0] seg;
    integer    i;

    seven_seg_hex dut (.hex(hex), .seg(seg));

    initial begin
        $display("hex | abcdefg");
        $display("----+--------");
        for (i = 0; i < 16; i = i + 1) begin
            hex = i[3:0];
            #5;
            $display("  %h | %b", hex, seg);
        end
        $finish;
    end
endmodule
