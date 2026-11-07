// crc8_byte.v -- byte-at-a-time CRC-8 built from a serial LFSR unrolled 8x.
// Same polynomial math as the bit-serial version, but one byte per clock.
module crc8_byte (
    input  wire       clk,
    input  wire       rst,       // synchronous: reloads 0x00
    input  wire       valid,     // 1 = absorb data_in this clock
    input  wire [7:0] data_in,
    output reg  [7:0] crc
);
    localparam [7:0] POLY = 8'h07;

    // Combinational: fold one byte into the running CRC, MSB-first.
    function [7:0] next_crc;
        input [7:0] c_in;
        input [7:0] d;
        integer   k;
        reg [7:0] c;
        reg       feedback;
        begin
            c = c_in;
            for (k = 7; k >= 0; k = k - 1) begin
                feedback = d[k] ^ c[7];
                c = {c[6:0], 1'b0} ^ (feedback ? POLY : 8'h00);
            end
            next_crc = c;
        end
    endfunction

    always @(posedge clk) begin
        if (rst)        crc <= 8'h00;
        else if (valid) crc <= next_crc(crc, data_in);
    end
endmodule

// Testbench: compute CRC-8 of {0xAB, 0xCD} (expected 0xE2), then show the
// receiver property -- feeding the message plus its CRC byte leaves 0x00.
// Stimulus changes on the negative edge so inputs are stable at each posedge.
module tb_crc8_byte;
    reg        clk = 1'b0;
    reg        rst, valid;
    reg  [7:0] data_in;
    wire [7:0] crc;

    crc8_byte dut (.clk(clk), .rst(rst), .valid(valid),
                   .data_in(data_in), .crc(crc));

    always #5 clk = ~clk;

    initial begin
        // ---- Transmitter: CRC over {0xAB, 0xCD} ----
        rst = 1'b1; valid = 1'b0; data_in = 8'h00;
        @(negedge clk); rst = 1'b0;             // one clock in reset

        @(negedge clk); valid = 1'b1; data_in = 8'hAB;
        @(negedge clk);               data_in = 8'hCD;
        @(negedge clk); valid = 1'b0;           // both bytes now absorbed
        $display("TX CRC-8 = 0x%02h (expected 0xE2)", crc);
        if (crc === 8'hE2) $display("RESULT: PASS"); else $display("RESULT: FAIL");

        // ---- Receiver: data + CRC should fold back to 0x00 ----
        @(negedge clk); rst = 1'b1;
        @(negedge clk); rst = 1'b0;
        @(negedge clk); valid = 1'b1; data_in = 8'hAB;
        @(negedge clk);               data_in = 8'hCD;
        @(negedge clk);               data_in = 8'hE2;
        @(negedge clk); valid = 1'b0;
        $display("RX remainder = 0x%02h (expected 0x00)", crc);
        if (crc === 8'h00) $display("RESULT: PASS"); else $display("RESULT: FAIL");
        $finish;
    end
endmodule
