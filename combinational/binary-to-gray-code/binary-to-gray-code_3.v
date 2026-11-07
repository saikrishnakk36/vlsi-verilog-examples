// bin2gray.v + gray2bin.v - converter and its inverse, used to self-check
module bin2gray #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] bin,
    output wire [WIDTH-1:0] gray
);
    assign gray = bin ^ (bin >> 1);
endmodule

module gray2bin #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] gray,
    output reg  [WIDTH-1:0] bin
);
    integer k;
    always @(*) begin
        bin[WIDTH-1] = gray[WIDTH-1];
        for (k = WIDTH-2; k >= 0; k = k - 1)
            bin[k] = bin[k+1] ^ gray[k];
    end
endmodule

// tb_roundtrip.v - bin -> gray -> bin must return the original value
module tb_roundtrip;
    localparam WIDTH = 4;
    reg  [WIDTH-1:0] bin;
    wire [WIDTH-1:0] gray;
    wire [WIDTH-1:0] back;
    integer i, errors;

    bin2gray #(.WIDTH(WIDTH)) enc (.bin(bin),  .gray(gray));
    gray2bin #(.WIDTH(WIDTH)) dec (.gray(gray), .bin(back));

    initial begin
        errors = 0;
        $display("BIN  -> GRAY -> BIN   status");
        $display("----------------------------");
        for (i = 0; i < (1 << WIDTH); i = i + 1) begin
            bin = i[WIDTH-1:0];
            #1;
            if (back === bin)
                $display("%b -> %b -> %b   OK", bin, gray, back);
            else begin
                $display("%b -> %b -> %b   MISMATCH", bin, gray, back);
                errors = errors + 1;
            end
        end
        $display("----------------------------");
        $display("Round-trip errors: %0d", errors);
        $finish;
    end
endmodule
