// crc_serial.v -- parameterized serial (bit-at-a-time) CRC with an LFSR.
// MSB-first, no input/output reflection, no final XOR.
module crc_serial #(
    parameter             WIDTH = 8,        // CRC register width in bits
    parameter [WIDTH-1:0] POLY  = 8'h07,    // generator polynomial (x^WIDTH term implied)
    parameter [WIDTH-1:0] INIT  = 8'h00     // value loaded on reset
) (
    input  wire             clk,
    input  wire             rst,     // synchronous: reloads INIT
    input  wire             en,      // 1 = absorb bit_in this clock
    input  wire             bit_in,  // one message bit, fed MSB-first
    output reg  [WIDTH-1:0] crc
);
    // Feedback is the XOR of the incoming bit and the top CRC bit.
    wire feedback = bit_in ^ crc[WIDTH-1];

    always @(posedge clk) begin
        if (rst)
            crc <= INIT;
        else if (en)
            // Shift left one place, then conditionally XOR the polynomial.
            crc <= {crc[WIDTH-2:0], 1'b0} ^ (feedback ? POLY : {WIDTH{1'b0}});
    end
endmodule

// Testbench: CRC-8 (poly 0x07, init 0x00) over the ASCII string "123456789".
// The canonical check value for this configuration is 0xF4.
module tb_crc8;
    reg        clk = 1'b0;
    reg        rst, en, bit_in;
    wire [7:0] crc;

    crc_serial #(.WIDTH(8), .POLY(8'h07), .INIT(8'h00)) dut (
        .clk(clk), .rst(rst), .en(en), .bit_in(bit_in), .crc(crc)
    );

    always #5 clk = ~clk;   // 10 time-unit period

    // 9-byte message "123456789"
    reg [7:0] msg [0:8];
    integer   i, b;

    initial begin
        msg[0]=8'h31; msg[1]=8'h32; msg[2]=8'h33; msg[3]=8'h34; msg[4]=8'h35;
        msg[5]=8'h36; msg[6]=8'h37; msg[7]=8'h38; msg[8]=8'h39;

        // Reset for one clock to load INIT.
        rst = 1'b1; en = 1'b0; bit_in = 1'b0;
        @(posedge clk); #1 rst = 1'b0;

        // Feed every byte, MSB first, one bit per clock.
        for (b = 0; b < 9; b = b + 1) begin
            for (i = 7; i >= 0; i = i - 1) begin
                en = 1'b1; bit_in = msg[b][i];
                @(posedge clk);
            end
        end
        en = 1'b0;
        #1;

        $display("Final CRC-8 = 0x%02h (expected 0xF4)", crc);
        if (crc === 8'hF4) $display("RESULT: PASS");
        else               $display("RESULT: FAIL");
        $finish;
    end
endmodule
