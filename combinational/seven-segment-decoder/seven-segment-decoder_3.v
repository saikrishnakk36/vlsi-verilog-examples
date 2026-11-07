// seven_seg_anode.v -- One decoder, both display types via a parameter.
// COMMON_ANODE = 0 -> common-cathode (segment ON = 1)
// COMMON_ANODE = 1 -> common-anode   (segment ON = 0, pattern inverted)
module seven_seg #(
    parameter COMMON_ANODE = 0
) (
    input      [3:0] hex,
    output reg [6:0] seg   // {a,b,c,d,e,f,g}
);
    reg [6:0] pat;         // common-cathode (active-high) base pattern
    always @(*) begin
        case (hex)
            4'h0: pat = 7'b1111110;
            4'h1: pat = 7'b0110000;
            4'h2: pat = 7'b1101101;
            4'h3: pat = 7'b1111001;
            4'h4: pat = 7'b0110011;
            4'h5: pat = 7'b1011011;
            4'h6: pat = 7'b1011111;
            4'h7: pat = 7'b1110000;
            4'h8: pat = 7'b1111111;
            4'h9: pat = 7'b1111011;
            4'hA: pat = 7'b1110111;
            4'hB: pat = 7'b0011111;
            4'hC: pat = 7'b1001110;
            4'hD: pat = 7'b0111101;
            4'hE: pat = 7'b1001111;
            4'hF: pat = 7'b1000111;
            default: pat = 7'b0000000;
        endcase
        // Common-anode hardware sinks current, so it needs the inverse drive.
        seg = (COMMON_ANODE != 0) ? ~pat : pat;
    end
endmodule

module tb_seven_seg;
    reg  [3:0] hex;
    wire [6:0] seg_cc;   // common cathode
    wire [6:0] seg_ca;   // common anode
    integer    i;

    seven_seg #(.COMMON_ANODE(0)) u_cc (.hex(hex), .seg(seg_cc));
    seven_seg #(.COMMON_ANODE(1)) u_ca (.hex(hex), .seg(seg_ca));

    initial begin
        $display("hex | cathode | anode");
        $display("----+---------+--------");
        for (i = 0; i < 16; i = i + 1) begin
            hex = i[3:0];
            #5;
            $display("  %h | %b | %b", hex, seg_cc, seg_ca);
        end
        $finish;
    end
endmodule
