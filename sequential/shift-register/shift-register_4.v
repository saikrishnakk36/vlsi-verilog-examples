// univ_shift.v - Parameterized universal shift register
// mode: 00 hold | 01 shift right (sr_in -> MSB) | 10 shift left (sl_in -> LSB) | 11 load
module univ_shift #(parameter WIDTH = 8) (
    input  wire             clk,
    input  wire             rst_n,  // active-low synchronous reset
    input  wire [1:0]       mode,   // operation select
    input  wire             sr_in,  // serial in for right shift
    input  wire             sl_in,  // serial in for left shift
    input  wire [WIDTH-1:0] din,    // parallel load data
    output reg  [WIDTH-1:0] q       // register contents
);
    always @(posedge clk) begin
        if (!rst_n)
            q <= {WIDTH{1'b0}};
        else begin
            case (mode)
                2'b00: q <= q;                        // hold
                2'b01: q <= {sr_in, q[WIDTH-1:1]};    // shift right
                2'b10: q <= {q[WIDTH-2:0], sl_in};    // shift left
                2'b11: q <= din;                      // parallel load
            endcase
        end
    end
endmodule

// -------------------- testbench --------------------
module tb_univ_shift;
    localparam WIDTH = 8;
    reg clk = 0, rst_n = 0, sr_in = 0, sl_in = 0;
    reg [1:0] mode = 2'b00;
    reg [WIDTH-1:0] din = 0;
    wire [WIDTH-1:0] q;

    univ_shift #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst_n(rst_n), .mode(mode),
        .sr_in(sr_in), .sl_in(sl_in), .din(din), .q(q));

    always #5 clk = ~clk;

    task step(input [1:0] m, input r, input l, input [WIDTH-1:0] d,
              input [8*8:1] name);
        begin
            mode = m; sr_in = r; sl_in = l; din = d;
            @(negedge clk);
            $display("%-6s mode=%b q=%b", name, m, q);
        end
    endtask

    initial begin
        $display("=== Universal %0d-bit shift register ===", WIDTH);
        @(negedge clk) rst_n = 0;
        @(negedge clk) rst_n = 1;
        step(2'b11, 0, 0, 8'b0000_1111, "LOAD");
        step(2'b00, 0, 0, 0,            "HOLD");
        step(2'b01, 1, 0, 0,            "SR");    // 1 enters MSB
        step(2'b01, 0, 0, 0,            "SR");
        step(2'b10, 0, 1, 0,            "SL");    // 1 enters LSB
        step(2'b10, 0, 0, 0,            "SL");
        step(2'b11, 0, 0, 8'hA5,        "LOAD");
        $display("=== done ===");
        $finish;
    end
endmodule
