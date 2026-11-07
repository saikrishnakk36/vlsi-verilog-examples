// async_fifo.v  -- dual-clock asynchronous FIFO (Verilog-2005)
// Gray-code read/write pointers + two-flop synchronizers + full/empty flags.

module async_fifo #(
    parameter DW = 8,   // data width
    parameter AW = 2    // address width -> depth = 2**AW
)(
    // write clock domain
    input  wire          wclk,
    input  wire          wrst_n,
    input  wire          wr_en,
    input  wire [DW-1:0] wdata,
    output reg           wfull,
    // read clock domain
    input  wire          rclk,
    input  wire          rrst_n,
    input  wire          rd_en,
    output wire [DW-1:0] rdata,
    output reg           rempty
);
    localparam DEPTH = (1 << AW);

    reg [DW-1:0] mem [0:DEPTH-1];

    // Write-domain pointers (AW+1 bits: extra MSB distinguishes full from empty)
    reg  [AW:0] wbin, wgray;
    reg  [AW:0] wq1, wq2;              // read-gray synchronized into write clock
    wire [AW:0] wbin_nxt  = wbin + (wr_en & ~wfull);
    wire [AW:0] wgray_nxt = (wbin_nxt >> 1) ^ wbin_nxt;

    // Read-domain pointers
    reg  [AW:0] rbin, rgray;
    reg  [AW:0] rq1, rq2;             // write-gray synchronized into read clock
    wire [AW:0] rbin_nxt  = rbin + (rd_en & ~rempty);
    wire [AW:0] rgray_nxt = (rbin_nxt >> 1) ^ rbin_nxt;

    // ---------------- write clock domain ----------------
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) {wq2, wq1} <= 0;
        else         {wq2, wq1} <= {wq1, rgray};   // 2-flop sync of read pointer

    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) begin wbin <= 0; wgray <= 0; end
        else         begin wbin <= wbin_nxt; wgray <= wgray_nxt; end

    // Full when next write-gray equals read-gray with top two bits inverted
    wire wfull_nxt = (wgray_nxt == {~wq2[AW:AW-1], wq2[AW-2:0]});
    always @(posedge wclk or negedge wrst_n)
        if (!wrst_n) wfull <= 1'b0;
        else         wfull <= wfull_nxt;

    always @(posedge wclk)
        if (wr_en & ~wfull) mem[wbin[AW-1:0]] <= wdata;

    // ---------------- read clock domain ----------------
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) {rq2, rq1} <= 0;
        else         {rq2, rq1} <= {rq1, wgray};   // 2-flop sync of write pointer

    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) begin rbin <= 0; rgray <= 0; end
        else         begin rbin <= rbin_nxt; rgray <= rgray_nxt; end

    // Empty when next read-gray equals synchronized write-gray
    wire rempty_nxt = (rgray_nxt == rq2);
    always @(posedge rclk or negedge rrst_n)
        if (!rrst_n) rempty <= 1'b1;
        else         rempty <= rempty_nxt;

    assign rdata = mem[rbin[AW-1:0]];
endmodule

// ----------------------------- testbench -----------------------------
module tb_async_fifo;
    localparam DW = 8, AW = 2;        // depth = 4

    reg          wclk = 0, rclk = 0;
    reg          wrst_n = 0, rrst_n = 0;
    reg          wr_en = 0, rd_en = 0;
    reg  [DW-1:0] wdata = 8'hA0;
    wire [DW-1:0] rdata;
    wire          wfull, rempty;
    integer       i;

    async_fifo #(.DW(DW), .AW(AW)) dut (
        .wclk(wclk), .wrst_n(wrst_n), .wr_en(wr_en), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rd_en(rd_en), .rdata(rdata), .rempty(rempty)
    );

    always #5 wclk = ~wclk;    // 100 MHz write clock
    always #8 rclk = ~rclk;    // slower read clock

    // WRITE SIDE: keep offering data; next value only after a real write
    initial begin
        repeat (2) @(negedge wclk);
        wrst_n = 1;
        for (i = 0; i < 24; i = i + 1) begin
            @(negedge wclk);
            if (!wfull && wdata < 8'hA6) begin
                wr_en <= 1'b1;
                $display("T=%0t  WRITE 0x%02h  (wfull=%b)", $time, wdata, wfull);
            end else begin
                wr_en <= 1'b0;
            end
        end
        @(negedge wclk) wr_en <= 1'b0;
    end

    // advance wdata one step after each accepted write
    always @(posedge wclk)
        if (wr_en && !wfull) wdata <= wdata + 1'b1;

    // report flag RISING edges so full/empty are visible without flooding the log
    reg wfull_d, rempty_d;
    always @(posedge wclk) begin
        wfull_d <= wfull;
        if (wfull & ~wfull_d) $display("T=%0t  >> wfull asserted (writes stall)", $time);
    end
    always @(posedge rclk) begin
        rempty_d <= rempty;
        if (rempty & ~rempty_d) $display("T=%0t  >> rempty asserted (reads stall)", $time);
    end

    // READ SIDE: let a few words build up, then drain
    initial begin
        repeat (3) @(negedge rclk);
        rrst_n = 1;
        repeat (4) @(negedge rclk);     // allow FIFO to fill a little
        for (i = 0; i < 24; i = i + 1) begin
            @(negedge rclk);
            if (!rempty) begin
                rd_en <= 1'b1;
                $display("T=%0t  READ  0x%02h  (rempty=%b)", $time, rdata, rempty);
            end else begin
                rd_en <= 1'b0;
            end
        end
        @(negedge rclk) rd_en <= 1'b0;
    end

    initial begin
        #700;
        $display("DONE  final wfull=%b rempty=%b", wfull, rempty);
        $finish;
    end
endmodule

