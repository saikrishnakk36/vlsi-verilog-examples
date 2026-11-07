module hamming74_enc (
    input  wire [3:0] data,
    output wire [6:0] code
);
    wire d1 = data[0];
    wire d2 = data[1];
    wire d3 = data[2];
    wire d4 = data[3];
    wire p1 = d1 ^ d2 ^ d4;
    wire p2 = d1 ^ d3 ^ d4;
    wire p4 = d2 ^ d3 ^ d4;
    assign code = {d4, d3, d2, p4, d1, p2, p1};
endmodule

module hamming74_dec (
    input  wire [6:0] rx,
    output wire [2:0] syndrome,
    output wire [6:0] corrected,
    output wire [3:0] data
);
    wire s1 = rx[0] ^ rx[2] ^ rx[4] ^ rx[6];
    wire s2 = rx[1] ^ rx[2] ^ rx[5] ^ rx[6];
    wire s4 = rx[3] ^ rx[4] ^ rx[5] ^ rx[6];
    assign syndrome  = {s4, s2, s1};
    assign corrected = (syndrome == 3'd0) ? rx
                                          : (rx ^ (7'd1 << (syndrome - 3'd1)));
    assign data = {corrected[6], corrected[5], corrected[4], corrected[2]};
endmodule

module tb_sweep;
    reg  [3:0] data;
    wire [6:0] code;
    reg  [6:0] rx;
    wire [2:0] syn;
    wire [6:0] corr;
    wire [3:0] rdata;
    integer p;

    hamming74_enc enc (.data(data), .code(code));
    hamming74_dec dec (.rx(rx), .syndrome(syn), .corrected(corr), .data(rdata));

    initial begin
        data = 4'b0110;
        #1;
        $display("message = %b, codeword = %b", data, code);
        $display("errpos | received | syndrome | recovered | ok");
        for (p = 0; p <= 7; p = p + 1) begin
            if (p == 0) rx = code;
            else        rx = code ^ (7'd1 << (p - 1));
            #1;
            $display("   %0d   | %b |   %b    |   %b    | %s",
                     p, rx, syn, rdata, (rdata === data) ? "yes" : "no");
        end
        $finish;
    end
endmodule
