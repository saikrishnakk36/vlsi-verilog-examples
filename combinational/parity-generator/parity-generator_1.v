// parity_gen.v  -- parameterized even/odd parity generator
module parity_gen #(
    parameter WIDTH = 8,   // number of data bits
    parameter ODD   = 0    // 0 = even parity, 1 = odd parity
) (
    input  wire [WIDTH-1:0] data_in,
    output wire             parity
);
    // XOR-reduction of all data bits.
    // ^data_in is 1 when data_in holds an ODD number of 1s.
    // That value is exactly the EVEN-parity bit: appending it makes
    // the total number of 1s even. Invert it for odd parity.
    wire xor_all = ^data_in;
    assign parity = ODD ? ~xor_all : xor_all;
endmodule

// ---- testbench (self-contained, module last) ----
module tb_parity_gen;
    localparam WIDTH = 8;

    reg  [WIDTH-1:0] data;
    wire             even_p, odd_p;

    parity_gen #(.WIDTH(WIDTH), .ODD(0)) u_even (.data_in(data), .parity(even_p));
    parity_gen #(.WIDTH(WIDTH), .ODD(1)) u_odd  (.data_in(data), .parity(odd_p));

    // count 1s so the log is easy to read (synthesizable-free, TB only)
    function integer ones;
        input [WIDTH-1:0] v;
        integer k;
        begin
            ones = 0;
            for (k = 0; k < WIDTH; k = k + 1) ones = ones + v[k];
        end
    endfunction

    integer i;
    reg [WIDTH-1:0] vec [0:4];
    initial begin
        vec[0] = 8'b0000_0000;
        vec[1] = 8'b0000_0001;
        vec[2] = 8'b0000_0011;
        vec[3] = 8'b1011_0100;
        vec[4] = 8'b1111_1111;

        $display("  data_in    ones  even_p  odd_p");
        $display("  --------   ----  ------  -----");
        for (i = 0; i < 5; i = i + 1) begin
            data = vec[i];
            #5;
            $display("  %b   %0d      %b       %b", data, ones(data), even_p, odd_p);
        end
        $finish;
    end
endmodule
