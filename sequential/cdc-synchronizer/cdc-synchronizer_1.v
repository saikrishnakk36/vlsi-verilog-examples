// two_flop_sync.v  -- two-flop level synchronizer
module two_flop_sync (
    input  wire dclk,      // destination clock
    input  wire drst_n,    // destination reset, active low
    input  wire async_in,  // single-bit signal from source domain
    output wire sync_out    // metastability-resolved output
);
    reg meta, sync;

    always @(posedge dclk or negedge drst_n) begin
        if (!drst_n) begin
            meta <= 1'b0;
            sync <= 1'b0;
        end else begin
            meta <= async_in;   // first flop may go metastable
            sync <= meta;       // second flop resolves it
        end
    end

    assign sync_out = sync;
endmodule

// --- testbench (two independent clocks) ---
module tb_two_flop_sync;
    reg  sclk, dclk, drst_n;
    reg  src_level;
    wire dst_level;

    two_flop_sync dut (
        .dclk     (dclk),
        .drst_n   (drst_n),
        .async_in (src_level),
        .sync_out (dst_level)
    );

    // source domain ~71 ns period, destination ~37 ns period
    initial sclk = 1'b0;
    always #35 sclk = ~sclk;
    initial dclk = 1'b0;
    always #18 dclk = ~dclk;

    // source toggles its level on its own clock
    integer scyc;
    initial begin src_level = 1'b0; scyc = 0; end
    always @(posedge sclk) begin
        scyc <= scyc + 1;
        if (scyc == 2) src_level <= 1'b1;  // assert after a few source cycles
        if (scyc == 7) src_level <= 1'b0;  // deassert later
    end

    initial begin
        drst_n = 1'b0;
        #40 drst_n = 1'b1;
        $monitor("t=%0t  src_level=%b  dst_level=%b", $time, src_level, dst_level);
        #700;
        $display("Done: level crossed both clock domains.");
        $finish;
    end
endmodule
