module hamming74_enc (
    input  wire [3:0] data,   // message bits d1 d2 d3 d4 = data[0..3]
    output wire [6:0] code     // code[0]=c1 (pos 1) ... code[6]=c7 (pos 7)
);
    wire d1 = data[0];
    wire d2 = data[1];
    wire d3 = data[2];
    wire d4 = data[3];

    wire p1 = d1 ^ d2 ^ d4;    // parity over positions 1,3,5,7
    wire p2 = d1 ^ d3 ^ d4;    // parity over positions 2,3,6,7
    wire p4 = d2 ^ d3 ^ d4;    // parity over positions 4,5,6,7

    // positions: 7=d4 6=d3 5=d2 4=p4 3=d1 2=p2 1=p1
    assign code = {d4, d3, d2, p4, d1, p2, p1};
endmodule

module tb_enc;
    reg  [3:0] data;
    wire [6:0] code;
    integer i;
    hamming74_enc dut (.data(data), .code(code));
    initial begin
        $display("message | codeword(c7..c1)");
        for (i = 0; i < 16; i = i + 1) begin
            data = i[3:0];
            #1;
            $display("  %b   |    %b", data, code);
        end
        $finish;
    end
endmodule
