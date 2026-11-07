// sipo.v - Serial-In Parallel-Out shift register (4-bit)
module sipo #(parameter WIDTH = 4) (
    input  wire             clk,
    input  wire             rst_n,  // active-low synchronous reset
    input  wire             din,    // one bit per clock
    output reg  [WIDTH-1:0] q       // all bits available in parallel
);
    always @(posedge clk) begin
        if (!rst_n)
            q <= {WIDTH{1'b0}};
        else
            q <= {q[WIDTH-2:0], din}; // new bit enters LSB, rest shift left
    end
endmodule

// -------------------- testbench --------------------
module tb_sipo;
    localparam WIDTH = 4;
    reg clk = 0, rst_n = 0, din = 0;
    wire [WIDTH-1:0] q;
    integer i;
    reg [WIDTH-1:0] stream = 4'b1101;  // sent MSB first: 1,1,0,1

    sipo #(.WIDTH(WIDTH)) dut (.clk(clk), .rst_n(rst_n), .din(din), .q(q));

    always #5 clk = ~clk;

    initial begin
        $display("=== SIPO: shift 4 serial bits, read parallel q ===");
        $monitor("t=%0t  din=%b  q=%b", $time, din, q);
        @(negedge clk) rst_n = 0;
        @(negedge clk) rst_n = 1;
        for (i = WIDTH-1; i >= 0; i = i - 1) begin
            din = stream[i];
            @(negedge clk);
        end
        $display(">> after %0d clocks, parallel output q = %b (expected %b)",
                 WIDTH, q, stream);
        $finish;
    end
endmodule
