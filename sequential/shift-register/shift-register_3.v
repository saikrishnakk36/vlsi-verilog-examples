// piso.v - Parallel-In Serial-Out shift register (4-bit)
module piso #(parameter WIDTH = 4) (
    input  wire             clk,
    input  wire             rst_n,  // active-low synchronous reset
    input  wire             load,   // 1 = parallel load, 0 = shift
    input  wire [WIDTH-1:0] din,    // parallel data in
    output wire             dout    // serial data out (MSB first)
);
    reg [WIDTH-1:0] sr;

    always @(posedge clk) begin
        if (!rst_n)
            sr <= {WIDTH{1'b0}};
        else if (load)
            sr <= din;                     // capture all bits at once
        else
            sr <= {sr[WIDTH-2:0], 1'b0};   // shift left, feed 0 behind
    end

    assign dout = sr[WIDTH-1];             // MSB streams out first
endmodule

// -------------------- testbench --------------------
module tb_piso;
    localparam WIDTH = 4;
    reg clk = 0, rst_n = 0, load = 0;
    reg [WIDTH-1:0] din = 0;
    wire dout;
    integer i;

    piso #(.WIDTH(WIDTH)) dut (.clk(clk), .rst_n(rst_n),
                               .load(load), .din(din), .dout(dout));

    always #5 clk = ~clk;

    initial begin
        $display("=== PISO: load 1010 in parallel, read it out serially ===");
        @(negedge clk) rst_n = 0;
        @(negedge clk) rst_n = 1; load = 1; din = 4'b1010;  // load
        @(negedge clk) load = 0;                            // now shift
        $display("loaded din=%b", 4'b1010);
        for (i = 0; i < WIDTH; i = i + 1) begin
            $display("clock %0d: dout = %b", i, dout);
            @(negedge clk);
        end
        $display("=== done (serial stream was MSB-first) ===");
        $finish;
    end
endmodule
