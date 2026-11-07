// pulse_sync.v  -- toggle-based pulse synchronizer
module pulse_sync (
    input  wire sclk,      // source clock
    input  wire srst_n,
    input  wire src_pulse, // 1-cycle pulse in source domain
    input  wire dclk,      // destination clock
    input  wire drst_n,
    output reg  dst_pulse   // 1-cycle pulse in destination domain
);
    // 1. convert pulse to a level toggle in the source domain
    reg toggle;
    always @(posedge sclk or negedge srst_n) begin
        if (!srst_n) toggle <= 1'b0;
        else if (src_pulse) toggle <= ~toggle;
    end

    // 2. synchronize the toggle into the destination domain (3 flops)
    reg t_meta, t_sync, t_prev;
    always @(posedge dclk or negedge drst_n) begin
        if (!drst_n) begin
            t_meta <= 1'b0;
            t_sync <= 1'b0;
            t_prev <= 1'b0;
        end else begin
            t_meta <= toggle;
            t_sync <= t_meta;
            t_prev <= t_sync;
        end
    end

    // 3. edge-detect to regenerate a single-cycle pulse
    always @(posedge dclk or negedge drst_n) begin
        if (!drst_n) dst_pulse <= 1'b0;
        else         dst_pulse <= t_sync ^ t_prev;
    end
endmodule

// --- testbench (fast source, slow destination) ---
module tb_pulse_sync;
    reg sclk, dclk, srst_n, drst_n, src_pulse;
    wire dst_pulse;
    integer dcount;

    pulse_sync dut (
        .sclk(sclk), .srst_n(srst_n), .src_pulse(src_pulse),
        .dclk(dclk), .drst_n(drst_n), .dst_pulse(dst_pulse)
    );

    initial sclk = 1'b0; always #10 sclk = ~sclk;  // 20 ns
    initial dclk = 1'b0; always #33 dclk = ~dclk;  // 66 ns (slower)

    // count received pulses in destination domain
    initial dcount = 0;
    always @(posedge dclk) if (dst_pulse) dcount = dcount + 1;

    initial begin
        srst_n = 1'b0; drst_n = 1'b0; src_pulse = 1'b0;
        #25 srst_n = 1'b1; drst_n = 1'b1;
        // fire three single-cycle source pulses, well spaced
        @(posedge sclk) src_pulse <= 1'b1; @(posedge sclk) src_pulse <= 1'b0;
        repeat (12) @(posedge sclk);
        @(posedge sclk) src_pulse <= 1'b1; @(posedge sclk) src_pulse <= 1'b0;
        repeat (12) @(posedge sclk);
        @(posedge sclk) src_pulse <= 1'b1; @(posedge sclk) src_pulse <= 1'b0;
        repeat (20) @(posedge sclk);
        $display("Source sent 3 pulses; destination received %0d pulses.", dcount);
        $finish;
    end

    always @(posedge dclk)
        if (dst_pulse) $display("t=%0t  dst_pulse received", $time);
endmodule
