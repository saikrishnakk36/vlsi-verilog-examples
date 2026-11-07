// sync_fifo.v  --  parameterized single-clock (synchronous) FIFO
// DATA_WIDTH : bit width of each word
// DEPTH      : number of words (use a power of 2)
module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8
)(
    input  wire                   clk,
    input  wire                   rst_n,   // active-low synchronous-ish reset
    input  wire                   wr_en,
    input  wire                   rd_en,
    input  wire [DATA_WIDTH-1:0]  din,
    output reg  [DATA_WIDTH-1:0]  dout,
    output wire                   full,
    output wire                   empty
);
    // ADDR_WIDTH indexes DEPTH locations; pointers carry one EXTRA MSB
    // (the "wrap" bit) so we can tell a full FIFO from an empty one.
    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0]   wr_ptr;   // {wrap, addr}
    reg [ADDR_WIDTH:0]   rd_ptr;   // {wrap, addr}

    // A write/read only happens when it is legal (guards overflow/underflow).
    wire do_write = wr_en & ~full;
    wire do_read  = rd_en & ~empty;

    // Write port
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (do_write) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // Read port (registered: dout is valid one clock after do_read)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rd_ptr <= 0;
        else if (do_read) begin
            dout   <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // Empty: pointers identical (same addr AND same wrap bit).
    assign empty = (wr_ptr == rd_ptr);
    // Full: same addr but wrap bits differ (writer lapped the reader once).
    assign full  = (wr_ptr[ADDR_WIDTH]     != rd_ptr[ADDR_WIDTH]) &&
                   (wr_ptr[ADDR_WIDTH-1:0]  == rd_ptr[ADDR_WIDTH-1:0]);
endmodule


`timescale 1ns/1ps
// tb_fifo_rw.v -- write four words, then read them back in FIFO order
module tb_fifo_rw;
    localparam DW = 8;
    localparam DEPTH = 8;

    reg              clk, rst_n, wr_en, rd_en;
    reg  [DW-1:0]    din;
    wire [DW-1:0]    dout;
    wire             full, empty;

    sync_fifo #(.DATA_WIDTH(DW), .DEPTH(DEPTH)) dut (
        .clk(clk), .rst_n(rst_n), .wr_en(wr_en), .rd_en(rd_en),
        .din(din), .dout(dout), .full(full), .empty(empty)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;   // 100 MHz

    integer i;
    initial begin
        rst_n = 0; wr_en = 0; rd_en = 0; din = 0;
        @(posedge clk); #1;
        rst_n = 1;
        $display("[%0t] reset released: empty=%b full=%b", $time, empty, full);

        // ---- write phase: push 0xA0,0xA1,0xA2,0xA3 ----
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            wr_en = 1; din = 8'hA0 + i[7:0];
            @(posedge clk); #1;
            $display("[%0t] WRITE 0x%0h   empty=%b full=%b", $time, din, empty, full);
        end
        @(negedge clk); wr_en = 0; din = 0;

        // ---- read phase: pop and print in order ----
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            rd_en = 1;
            @(posedge clk); #1;        // dout updated on this edge
            $display("[%0t] READ  0x%0h   empty=%b full=%b", $time, dout, empty, full);
        end
        @(negedge clk); rd_en = 0;

        @(posedge clk); #1;
        $display("[%0t] drained: empty=%b full=%b", $time, empty, full);
        $finish;
    end
endmodule


`timescale 1ns/1ps
// tb_fifo_flags.v -- fill a depth-4 FIFO to full, prove the overflow guard,
//                    then drain to empty and prove the underflow guard
module tb_fifo_flags;
    localparam DW = 8;
    localparam DEPTH = 4;

    reg              clk, rst_n, wr_en, rd_en;
    reg  [DW-1:0]    din;
    wire [DW-1:0]    dout;
    wire             full, empty;

    sync_fifo #(.DATA_WIDTH(DW), .DEPTH(DEPTH)) dut (
        .clk(clk), .rst_n(rst_n), .wr_en(wr_en), .rd_en(rd_en),
        .din(din), .dout(dout), .full(full), .empty(empty)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer i;
    reg decision;   // what the guard will allow on the next rising edge
    initial begin
        rst_n = 0; wr_en = 0; rd_en = 0; din = 0;
        @(posedge clk); #1; rst_n = 1;
        $display("[%0t] start: empty=%b full=%b", $time, empty, full);

        // push 6 words into a 4-deep FIFO: last two must be rejected by guard
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk); wr_en = 1; din = 8'h10 + i[7:0];
            #1 decision = wr_en & ~full;          // sampled before the edge
            @(posedge clk); #1;
            $display("[%0t] try WRITE 0x%0h -> accepted=%b  empty=%b full=%b",
                     $time, din, decision, empty, full);
        end
        @(negedge clk); wr_en = 0;

        // pull 6 words out: last two reads hit an empty FIFO (guarded)
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge clk); rd_en = 1;
            #1 decision = rd_en & ~empty;         // sampled before the edge
            @(posedge clk); #1;
            if (decision)
                $display("[%0t] READ  0x%0h   empty=%b full=%b", $time, dout, empty, full);
            else
                $display("[%0t] READ  blocked (empty)  empty=%b full=%b", $time, empty, full);
        end
        @(negedge clk); rd_en = 0;
        $display("[%0t] done: empty=%b full=%b", $time, empty, full);
        $finish;
    end
endmodule


`timescale 1ns/1ps
// tb_fifo_stream.v -- prime the FIFO, then read and write on the SAME cycles
//                     so data streams through while occupancy stays constant
module tb_fifo_stream;
    localparam DW = 8;
    localparam DEPTH = 8;

    reg              clk, rst_n, wr_en, rd_en;
    reg  [DW-1:0]    din;
    wire [DW-1:0]    dout;
    wire             full, empty;

    sync_fifo #(.DATA_WIDTH(DW), .DEPTH(DEPTH)) dut (
        .clk(clk), .rst_n(rst_n), .wr_en(wr_en), .rd_en(rd_en),
        .din(din), .dout(dout), .full(full), .empty(empty)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    integer i;
    initial begin
        rst_n = 0; wr_en = 0; rd_en = 0; din = 0;
        @(posedge clk); #1; rst_n = 1;

        // prime with two words so a read always has something to return
        @(negedge clk); wr_en = 1; din = 8'h50;
        @(negedge clk);            din = 8'h51;
        @(posedge clk); #1;
        $display("[%0t] primed: empty=%b full=%b", $time, empty, full);

        // stream: write 0x52..0x56 while reading on the very same cycles
        for (i = 0; i < 5; i = i + 1) begin
            @(negedge clk); wr_en = 1; rd_en = 1; din = 8'h52 + i[7:0];
            @(posedge clk); #1;
            $display("[%0t] in=0x%0h  out=0x%0h  empty=%b full=%b",
                     $time, din, dout, empty, full);
        end

        // stop writing, flush the two words still inside
        @(negedge clk); wr_en = 0; rd_en = 1;
        repeat (2) begin
            @(posedge clk); #1;
            $display("[%0t] flush out=0x%0h  empty=%b full=%b", $time, dout, empty, full);
        end
        @(negedge clk); rd_en = 0;
        @(posedge clk); #1;
        $display("[%0t] done: empty=%b full=%b", $time, empty, full);
        $finish;
    end
endmodule

