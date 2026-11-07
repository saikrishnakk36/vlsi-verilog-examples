// siso.v - 4-bit Serial-In Serial-Out shift register
module siso #(parameter WIDTH = 4) (
    input  wire clk,
    input  wire rst_n,   // active-low synchronous reset
    input  wire din,     // serial data in
    output wire dout     // serial data out
);
    reg [WIDTH-1:0] sr;

    always @(posedge clk) begin
        if (!rst_n)
            sr <= {WIDTH{1'b0}};
        else
            sr <= {sr[WIDTH-2:0], din};  // shift left, din enters LSB
    end

    assign dout = sr[WIDTH-1];           // oldest bit leaves from MSB
endmodule

// -------------------- testbench --------------------
module tb_siso;
    reg clk = 0, rst_n = 0, din = 0;
    wire dout;
    integer i;
    reg [3:0] pattern = 4'b1011;   // pushed in LSB first: 1,1,0,1

    siso #(.WIDTH(4)) dut (.clk(clk), .rst_n(rst_n), .din(din), .dout(dout));

    always #5 clk = ~clk;          // 10 ns clock period

    initial begin
        $display("=== SISO: data appears at dout WIDTH clocks after it enters ===");
        $monitor("t=%0t  din=%b  dout=%b", $time, din, dout);
        @(negedge clk) rst_n = 0;            // hold in reset
        @(negedge clk) rst_n = 1;            // release reset
        for (i = 0; i < 4; i = i + 1) begin
            din = pattern[i];                // feed LSB..MSB
            @(negedge clk);
        end
        din = 0;
        for (i = 0; i < 4; i = i + 1) @(negedge clk);  // flush the pipe
        $display("=== done: the 4 bits came out in the same order they went in ===");
        $finish;
    end
endmodule
