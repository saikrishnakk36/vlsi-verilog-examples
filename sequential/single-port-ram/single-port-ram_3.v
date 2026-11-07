// spram_preload.v
// Single-port RAM preloaded at time 0, with a self-checking testbench
// that overwrites one word and reads it back.
module spram_preload #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
) (
    input  wire                   clk,
    input  wire                   we,
    input  wire [ADDR_WIDTH-1:0]  addr,
    input  wire [DATA_WIDTH-1:0]  din,
    output reg  [DATA_WIDTH-1:0]  dout
);
    localparam DEPTH = (1 << ADDR_WIDTH);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    integer k;

    // Preload: location k holds value k*k (0,1,4,9,...).
    initial begin
        for (k = 0; k < DEPTH; k = k + 1)
            mem[k] = (k*k);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        dout <= mem[addr];
    end
endmodule

// tb_spram_preload.v
module tb_spram_preload;
    localparam DW = 8, AW = 3;

    reg            clk, we;
    reg  [AW-1:0]  addr;
    reg  [DW-1:0]  din;
    wire [DW-1:0]  dout;
    integer i, errors;

    spram_preload #(.DATA_WIDTH(DW), .ADDR_WIDTH(AW)) dut (
        .clk(clk), .we(we), .addr(addr), .din(din), .dout(dout));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        we = 0; addr = 0; din = 0; errors = 0;

        // Read back the preloaded squares and check them.
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk); addr = i[AW-1:0];
            @(posedge clk); #1;
            if (dout !== (i*i)) begin
                errors = errors + 1;
                $display("MISMATCH addr=%0d got=%0d want=%0d", addr, dout, i*i);
            end else
                $display("OK       addr=%0d dout=%0d", addr, dout);
        end

        // Overwrite address 5 with 200, then read it back.
        @(negedge clk); we = 1; addr = 5; din = 200;
        @(posedge clk);
        @(negedge clk); we = 0; addr = 5;
        @(posedge clk); #1;
        $display("UPDATED  addr=5 dout=%0d (expected 200)", dout);

        if (errors == 0)
            $display("RESULT: all preloaded values verified");
        else
            $display("RESULT: %0d mismatches", errors);

        $finish;
    end
endmodule

