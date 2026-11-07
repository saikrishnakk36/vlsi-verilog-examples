// Same mod_n_counter reused with a different modulus -- no RTL changes needed.
module mod_n_counter #(
    parameter N     = 10,
    parameter WIDTH = (N <= 2) ? 1 : $clog2(N)
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    output reg  [WIDTH-1:0] count,
    output wire             tc
);
    assign tc = (count == (N-1));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {WIDTH{1'b0}};
        else if (en) begin
            if (tc)
                count <= {WIDTH{1'b0}};
            else
                count <= count + 1'b1;
        end
    end
endmodule

// tb_mod6.v -- the one module instantiated as a mod-6 counter (count 0..5)
module tb_mod6;
    reg        clk;
    reg        rst_n;
    reg        en;
    wire [2:0] count;   // ceil(log2(6)) = 3 bits
    wire       tc;

    mod_n_counter #(.N(6)) dut (
        .clk(clk), .rst_n(rst_n), .en(en), .count(count), .tc(tc)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 1'b0; en = 1'b0;
        #12 rst_n = 1'b1; en = 1'b1;
        #150 $finish;
    end

    always @(posedge clk)
        if (rst_n && en)
            $display("t=%0t  count=%0d  tc=%b%s",
                     $time, count, tc, tc ? "  <-- wrap next" : "");
endmodule
