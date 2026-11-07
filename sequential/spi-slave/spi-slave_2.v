// spi_rx.v  -  minimal mode-0 SPI receive slave (shift register + bit counter)
module spi_rx (
    input  wire       sclk,   // mode 0: sample on the rising edge
    input  wire       cs_n,   // active-low frame
    input  wire       mosi,   // serial data in, MSB first
    output reg  [7:0] data,   // last byte captured
    output reg        done    // high once 8 bits are in
);
    reg [2:0] cnt;
    reg [7:0] sh;

    always @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            cnt <= 3'd0;                 // CS high: reset the bit counter
        end else begin
            sh <= {sh[6:0], mosi};       // shift MOSI in from the LSB side
            if (cnt == 3'd7) begin
                data <= {sh[6:0], mosi}; // 8th bit completes the byte
                done <= 1'b1;
                cnt  <= 3'd0;
            end else begin
                if (cnt == 3'd0) done <= 1'b0;
                cnt <= cnt + 3'd1;
            end
        end
    end
endmodule

// tb_spi_rx.v  -  drive 0xB7 into the slave, one bit per SCLK pulse
module tb_spi_rx;
    reg        sclk, cs_n, mosi;
    wire [7:0] data;
    wire       done;
    reg  [7:0] b;
    integer    k;

    spi_rx dut (.sclk(sclk), .cs_n(cs_n), .mosi(mosi), .data(data), .done(done));

    initial begin
        sclk = 1'b0; cs_n = 1'b1; mosi = 1'b0;
        $monitor("t=%0t cs_n=%b sclk=%b mosi=%b done=%b data=0x%02h",
                 $time, cs_n, sclk, mosi, done, data);
        #10;
        b = 8'hB7;              // 1011_0111
        cs_n = 1'b0;            // open the frame
        mosi = b[7];            // MSB first
        #10;
        for (k = 0; k < 8; k = k + 1) begin
            sclk = 1'b1; #10;                 // rising edge: slave samples
            sclk = 1'b0; if (k < 7) mosi = b[6-k];
            #10;
        end
        cs_n = 1'b1;            // close the frame
        #10;
        $display("Captured byte = 0x%02h, done = %b", data, done);
        #10 $finish;
    end
endmodule
