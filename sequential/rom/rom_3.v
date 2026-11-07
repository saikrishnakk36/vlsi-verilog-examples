// Fully parameterized ROM: initial-block load + asynchronous read.
// The same module is instantiated twice with different parameters.
module rom #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter DEPTH      = (1 << ADDR_WIDTH)
)(
    input  wire [ADDR_WIDTH-1:0] addr,
    output wire [DATA_WIDTH-1:0] data
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    integer k;

    initial begin
        for (k = 0; k < DEPTH; k = k + 1)
            mem[k] = (k * k) & {DATA_WIDTH{1'b1}};  // squares, masked to width
    end

    assign data = mem[addr];   // combinational (asynchronous) read
endmodule

module tb_rom_param;
    // Instance A: 8-bit x 16 words
    reg  [3:0] a_addr;
    wire [7:0] a_data;
    rom #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) romA (.addr(a_addr), .data(a_data));

    // Instance B: 4-bit x 4 words (narrow, shallow)
    reg  [1:0] b_addr;
    wire [3:0] b_data;
    rom #(.DATA_WIDTH(4), .ADDR_WIDTH(2)) romB (.addr(b_addr), .data(b_data));

    integer i;

    initial begin
        $display("romA (8b x16)   romB (4b x4)");
        for (i = 0; i < 4; i = i + 1) begin
            a_addr = i[3:0];
            b_addr = i[1:0];
            #2;
            $display(" A[%0d]=0x%02h        B[%0d]=0x%01h", i, a_data, i, b_data);
        end
        // Show a deeper address on the wide ROM only
        a_addr = 4'd15; #2;
        $display(" A[15]=0x%02h (15*15=225=0xE1)", a_data);
        $finish;
    end
endmodule
