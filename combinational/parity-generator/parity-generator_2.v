// parity_check.v  -- parameterized even/odd parity checker
module parity_check #(
    parameter WIDTH = 8,
    parameter ODD   = 0    // must match the generator's setting
) (
    input  wire [WIDTH-1:0] data_in,
    input  wire             parity_in,   // received parity bit
    output wire             error        // 1 = parity mismatch detected
);
    // Re-derive what the parity bit SHOULD be, then compare.
    wire xor_all  = ^data_in;
    wire expected = ODD ? ~xor_all : xor_all;
    assign error  = (expected ^ parity_in);  // XOR == "not equal"
endmodule

// ---- testbench (self-contained, module last) ----
module tb_parity_check;
    localparam WIDTH = 8;

    reg  [WIDTH-1:0] data;
    reg              rx_parity;
    wire             error;

    parity_check #(.WIDTH(WIDTH), .ODD(0)) dut (
        .data_in(data), .parity_in(rx_parity), .error(error)
    );

    // helper: correct EVEN parity for a value
    function automatic even_par;
        input [WIDTH-1:0] v;
        begin even_par = ^v; end
    endfunction

    initial begin
        $display("  data_in    rx_parity  error  note");
        $display("  --------   ---------  -----  ----");

        // 1) clean frame: parity matches the data
        data = 8'b1011_0100; rx_parity = even_par(data); #5;
        $display("  %b      %b       %b    clean", data, rx_parity, error);

        // 2) same data, parity bit flipped in transit
        data = 8'b1011_0100; rx_parity = ~even_par(data); #5;
        $display("  %b      %b       %b    parity flipped", data, rx_parity, error);

        // 3) one data bit flipped, parity unchanged
        data = 8'b1011_0101; rx_parity = even_par(8'b1011_0100); #5;
        $display("  %b      %b       %b    data bit flipped", data, rx_parity, error);

        // 4) another clean frame
        data = 8'b0000_0001; rx_parity = even_par(data); #5;
        $display("  %b      %b       %b    clean", data, rx_parity, error);

        $finish;
    end
endmodule
