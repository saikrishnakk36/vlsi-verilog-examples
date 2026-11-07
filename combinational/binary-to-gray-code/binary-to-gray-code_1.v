// bin2gray.v - parameterized binary-to-gray converter (combinational XOR)
module bin2gray #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] bin,
    output wire [WIDTH-1:0] gray
);
    // Gray = Binary XOR (Binary >> 1)
    assign gray = bin ^ (bin >> 1);
endmodule

// tb_bin2gray.v - sweep every 4-bit code and print the mapping
module tb_bin2gray;
    localparam WIDTH = 4;
    reg  [WIDTH-1:0] bin;
    wire [WIDTH-1:0] gray;
    integer i;

    bin2gray #(.WIDTH(WIDTH)) dut (.bin(bin), .gray(gray));

    initial begin
        $display("BIN  -> GRAY  (WIDTH=%0d)", WIDTH);
        $display("---------------------------");
        for (i = 0; i < (1 << WIDTH); i = i + 1) begin
            bin = i[WIDTH-1:0];
            #1; // let the combinational logic settle
            $display("%b -> %b   (%0d -> %0d)", bin, gray, bin, gray);
        end
        $finish;
    end
endmodule
