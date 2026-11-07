// seven_seg_bcd.v -- BCD (0-9) to 7-segment decoder, common cathode
// Segment order: seg = {a,b,c,d,e,f,g}, a segment lights when its bit is 1.
module seven_seg_bcd (
    input      [3:0] bcd,   // binary-coded decimal 0..9
    output reg [6:0] seg    // {a,b,c,d,e,f,g}, active-high
);
    always @(*) begin
        case (bcd)
            4'd0: seg = 7'b1111110;
            4'd1: seg = 7'b0110000;
            4'd2: seg = 7'b1101101;
            4'd3: seg = 7'b1111001;
            4'd4: seg = 7'b0110011;
            4'd5: seg = 7'b1011011;
            4'd6: seg = 7'b1011111;
            4'd7: seg = 7'b1110000;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1111011;
            default: seg = 7'b0000000; // blank for invalid BCD
        endcase
    end
endmodule

module tb_seven_seg_bcd;
    reg  [3:0] bcd;
    wire [6:0] seg;
    integer    i;

    seven_seg_bcd dut (.bcd(bcd), .seg(seg));

    initial begin
        $display("digit | abcdefg");
        $display("------+--------");
        for (i = 0; i <= 11; i = i + 1) begin
            bcd = i[3:0];
            #5;
            $display("  %2d  | %b", bcd, seg);
        end
        $finish;
    end
endmodule
