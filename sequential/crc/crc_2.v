// crc16_ccitt.v -- same parameterized serial LFSR, configured as CRC-16-CCITT.
module crc_serial #(
    parameter             WIDTH = 16,
    parameter [WIDTH-1:0] POLY  = 16'h1021,
    parameter [WIDTH-1:0] INIT  = 16'hFFFF
) (
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    input  wire             bit_in,
    output reg  [WIDTH-1:0] crc
);
    wire feedback = bit_in ^ crc[WIDTH-1];

    always @(posedge clk) begin
        if (rst)
            crc <= INIT;
        else if (en)
            crc <= {crc[WIDTH-2:0], 1'b0} ^ (feedback ? POLY : {WIDTH{1'b0}});
    end
endmodule

// Testbench: CRC-16-CCITT-FALSE (poly 0x1021, init 0xFFFF) over "123456789".
// The published check value for this configuration is 0x29B1.
module tb_crc16;
    reg         clk = 1'b0;
    reg         rst, en, bit_in;
    wire [15:0] crc;

    crc_serial #(.WIDTH(16), .POLY(16'h1021), .INIT(16'hFFFF)) dut (
        .clk(clk), .rst(rst), .en(en), .bit_in(bit_in), .crc(crc)
    );

    always #5 clk = ~clk;

    reg [7:0] msg [0:8];
    integer   i, b;

    initial begin
        msg[0]=8'h31; msg[1]=8'h32; msg[2]=8'h33; msg[3]=8'h34; msg[4]=8'h35;
        msg[5]=8'h36; msg[6]=8'h37; msg[7]=8'h38; msg[8]=8'h39;

        rst = 1'b1; en = 1'b0; bit_in = 1'b0;
        @(posedge clk); #1 rst = 1'b0;

        for (b = 0; b < 9; b = b + 1) begin
            for (i = 7; i >= 0; i = i - 1) begin
                en = 1'b1; bit_in = msg[b][i];
                @(posedge clk);
            end
        end
        en = 1'b0;
        #1;

        $display("Final CRC-16-CCITT = 0x%04h (expected 0x29B1)", crc);
        if (crc === 16'h29B1) $display("RESULT: PASS");
        else                  $display("RESULT: FAIL");
        $finish;
    end
endmodule
