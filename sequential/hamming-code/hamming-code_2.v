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
    input  wire [6:0] rx,        // received word, rx[0]=c1 ... rx[6]=c7
    output wire [2:0] syndrome,  // binary error position, 0 = clean
    output wire [6:0] corrected, // word after correction
    output wire [3:0] data       // recovered 4-bit message
);
    wire c1 = rx[0];
    wire c2 = rx[1];
    wire c3 = rx[2];
    wire c4 = rx[3];
    wire c5 = rx[4];
    wire c6 = rx[5];
    wire c7 = rx[6];

    wire s1 = c1 ^ c3 ^ c5 ^ c7;
    wire s2 = c2 ^ c3 ^ c6 ^ c7;
    wire s4 = c4 ^ c5 ^ c6 ^ c7;
    assign syndrome = {s4, s2, s1};

    // syndrome gives the 1-based position of the flipped bit
    assign corrected = (syndrome == 3'd0) ? rx
                                          : (rx ^ (7'd1 << (syndrome - 3'd1)));

    // data bits live at positions 3,5,6,7 -> corrected[2],[4],[5],[6]
    assign data = {corrected[6], corrected[5], corrected[4], corrected[2]};
endmodule

module tb_hamming;
    reg  [3:0] data;
    wire [6:0] code;
    reg  [6:0] rx;
    wire [2:0] syn;
    wire [6:0] corr;
    wire [3:0] rdata;
    integer pos;

    hamming74_enc enc (.data(data), .code(code));
    hamming74_dec dec (.rx(rx), .syndrome(syn), .corrected(corr), .data(rdata));

    initial begin
        data = 4'b1011;
        #1;
        $display("message       = %b", data);
        $display("encoded word  = %b", code);

        pos = 3;                        // corrupt the bit at position 3
        rx  = code ^ (7'd1 << (pos - 1));
        #1;
        $display("flip position = %0d", pos);
        $display("received word = %b", rx);
        $display("syndrome      = %b  (decimal %0d)", syn, syn);
        $display("corrected word= %b", corr);
        $display("recovered msg = %b", rdata);
        if (rdata === data)
            $display("RESULT: single-bit error corrected, message recovered");
        else
            $display("RESULT: MISMATCH");
        $finish;
    end
endmodule
