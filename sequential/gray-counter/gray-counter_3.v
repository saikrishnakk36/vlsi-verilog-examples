// gray_roundtrip.v -- Gray counter + Gray->binary decoder, self-checking
module gray_roundtrip #(
    parameter WIDTH = 4
) (
    input  wire              clk,
    input  wire              rst_n,
    output reg  [WIDTH-1:0]  bin,     // reference binary count
    output wire [WIDTH-1:0]  gray,    // Gray output
    output reg  [WIDTH-1:0]  decoded  // Gray decoded back to binary
);
    integer k;

    always @(posedge clk) begin
        if (!rst_n)
            bin <= {WIDTH{1'b0}};
        else
            bin <= bin + {{(WIDTH-1){1'b0}}, 1'b1};
    end

    // Encode: binary -> Gray
    assign gray = bin ^ (bin >> 1);

    // Decode: Gray -> binary. MSB passes through; each lower bit
    // is the XOR of the Gray bit with the decoded bit above it.
    always @(*) begin
        decoded[WIDTH-1] = gray[WIDTH-1];
        for (k = WIDTH-2; k >= 0; k = k - 1)
            decoded[k] = gray[k] ^ decoded[k+1];
    end
endmodule

// --- Testbench (last module) ---
module tb_gray_roundtrip;
    localparam W = 4;
    reg          clk;
    reg          rst_n;
    wire [W-1:0] bin;
    wire [W-1:0] gray;
    wire [W-1:0] decoded;
    integer      i;
    integer      errors;

    gray_roundtrip #(.WIDTH(W)) dut (
        .clk(clk), .rst_n(rst_n), .bin(bin), .gray(gray), .decoded(decoded)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        errors = 0;
        rst_n  = 1'b0;
        #12 rst_n = 1'b1;
        $display("step  bin   gray  decoded  check");
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk);
            #1;
            if (decoded !== bin) errors = errors + 1;
            $display("%4d  %b  %b   %b     %s",
                     i, bin, gray, decoded,
                     (decoded === bin) ? "OK" : "MISMATCH");
        end
        $display("decode errors = %0d", errors);
        $finish;
    end
endmodule
