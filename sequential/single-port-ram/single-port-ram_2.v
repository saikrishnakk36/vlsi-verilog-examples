// spram_collision.v
// Same single-port RAM, with a parameter that selects what happens when a
// write and a read hit the SAME address in the SAME clock cycle.
module spram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3,
    parameter WRITE_FIRST = 0   // 0 = read-first (old data), 1 = write-first (new data)
) (
    input  wire                   clk,
    input  wire                   we,
    input  wire [ADDR_WIDTH-1:0]  addr,
    input  wire [DATA_WIDTH-1:0]  din,
    output reg  [DATA_WIDTH-1:0]  dout
);
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
            if (WRITE_FIRST)
                dout <= din;      // forward the freshly written value
            else
                dout <= mem[addr]; // return the value stored before this write
        end else begin
            dout <= mem[addr];
        end
    end
endmodule

// tb_spram_collision.v
module tb_spram_collision;
    localparam DW = 8, AW = 3;

    reg            clk, we;
    reg  [AW-1:0]  addr;
    reg  [DW-1:0]  din;
    wire [DW-1:0]  dout_rf;   // read-first instance
    wire [DW-1:0]  dout_wf;   // write-first instance

    spram #(.DATA_WIDTH(DW), .ADDR_WIDTH(AW), .WRITE_FIRST(0)) rf (
        .clk(clk), .we(we), .addr(addr), .din(din), .dout(dout_rf));
    spram #(.DATA_WIDTH(DW), .ADDR_WIDTH(AW), .WRITE_FIRST(1)) wf (
        .clk(clk), .we(we), .addr(addr), .din(din), .dout(dout_wf));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        we = 0; addr = 0; din = 0;

        // Seed address 2 with the value 99.
        @(negedge clk); we = 1; addr = 2; din = 99;
        @(posedge clk); #1 $display("seed   : wrote 99 to addr 2");

        // COLLISION cycle: write 123 to addr 2 while reading addr 2.
        @(negedge clk); we = 1; addr = 2; din = 123;
        @(posedge clk); #1;
        $display("collide: read-first dout=%0d  write-first dout=%0d", dout_rf, dout_wf);

        // Next cycle, plain read of addr 2 (no write): both see the new value.
        @(negedge clk); we = 0; addr = 2;
        @(posedge clk); #1;
        $display("after  : read-first dout=%0d  write-first dout=%0d", dout_rf, dout_wf);

        $finish;
    end
endmodule

