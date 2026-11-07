// gray_counter.v -- parameterized-width binary counter + Gray conversion
module gray_counter #(
    parameter WIDTH = 4
) (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              en,     // count enable
    output reg  [WIDTH-1:0]  bin,
    output wire [WIDTH-1:0]  gray
);
    always @(posedge clk) begin
        if (!rst_n)
            bin <= {WIDTH{1'b0}};
        else if (en)
            bin <= bin + {{(WIDTH-1){1'b0}}, 1'b1};
    end

    // Reflected binary Gray code
    assign gray = bin ^ (bin >> 1);
endmodule

// --- Testbench (last module) ---
module tb_gray_counter;
    localparam W = 3;              // instantiate a 3-bit counter
    reg          clk;
    reg          rst_n;
    reg          en;
    wire [W-1:0] bin;
    wire [W-1:0] gray;
    integer      i;

    gray_counter #(.WIDTH(W)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .bin(bin), .gray(gray)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0;
        en    = 1'b1;
        #12 rst_n = 1'b1;
        $display("WIDTH=%0d", W);
        $display("step  bin  gray");
        for (i = 0; i < 2*(1<<W); i = i + 1) begin
            @(posedge clk);
            #1 $display("%4d  %b  %b", i, bin, gray);
        end
        $finish;
    end
endmodule
