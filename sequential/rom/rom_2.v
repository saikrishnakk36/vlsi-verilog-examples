// Synchronous ROM: memory array preloaded in an initial block, registered read
module rom_sync #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter DEPTH      = (1 << ADDR_WIDTH)
)(
    input  wire                  clk,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] data
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    integer k;

    initial begin
        // Load the ROM contents once at elaboration
        for (k = 0; k < DEPTH; k = k + 1)
            mem[k] = k * 3;      // simple pattern: 0, 3, 6, 9, ...
        mem[0] = 8'hAA;          // override a couple of words explicitly
        mem[1] = 8'h55;
    end

    always @(posedge clk)
        data <= mem[addr];       // read is registered -> one cycle of latency
endmodule

module tb_rom_sync;
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    reg                   clk;
    reg  [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] data;
    integer i;

    rom_sync #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut (
        .clk(clk),
        .addr(addr),
        .data(data)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;        // 100 MHz-style clock

    initial begin
        addr = 0;
        $display("TIME ADDR DATA (registered, 1-cycle latency)");
        for (i = 0; i < 6; i = i + 1) begin
            addr = i[ADDR_WIDTH-1:0];
            @(posedge clk);          // present address
            @(posedge clk);          // data valid on next edge
            #1 $display("%4t  %0d   0x%02h", $time, i, data);
        end
        $finish;
    end
endmodule
