// spi_master_mode0: SPI master, Mode 0 (CPOL=0, CPHA=0)
// CLK_DIV = number of system-clock cycles in one SCLK period (even, >= 2).
module spi_master_mode0 #(
    parameter CLK_DIV = 4
)(
    input  wire       clk,       // system clock
    input  wire       rst_n,     // active-low reset
    input  wire       start,     // pulse to launch one 8-bit transfer
    input  wire [7:0] tx_data,   // byte to transmit, MSB first
    output reg  [7:0] rx_data,   // byte received from the slave
    output reg        busy,      // high while a transfer runs
    output reg        done,      // single-cycle pulse at completion
    output reg        sclk,      // serial clock to the slave
    output reg        mosi,      // master out, slave in
    input  wire       miso,      // master in, slave out
    output reg        cs_n       // active-low chip select
);
    localparam HALF = CLK_DIV >> 1;   // system cycles per SCLK half-period

    reg [15:0] div_cnt;
    reg [7:0]  shift_reg;
    reg [3:0]  bit_cnt;
    reg        phase;             // 0 = next edge is rising, 1 = next is falling
    reg        running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt   <= 16'd0;
            shift_reg <= 8'd0;
            bit_cnt   <= 4'd0;
            phase     <= 1'b0;
            running   <= 1'b0;
            sclk      <= 1'b0;
            mosi      <= 1'b0;
            cs_n      <= 1'b1;
            busy      <= 1'b0;
            done      <= 1'b0;
            rx_data   <= 8'd0;
        end else begin
            done <= 1'b0;
            if (!running) begin
                if (start) begin
                    shift_reg <= tx_data;
                    mosi      <= tx_data[7];   // present MSB before first edge
                    cs_n      <= 1'b0;
                    busy      <= 1'b1;
                    running   <= 1'b1;
                    sclk      <= 1'b0;
                    phase     <= 1'b0;
                    bit_cnt   <= 4'd0;
                    div_cnt   <= 16'd0;
                end
            end else if (div_cnt == HALF - 1) begin
                div_cnt <= 16'd0;
                if (phase == 1'b0) begin
                    sclk      <= 1'b1;                      // rising edge
                    shift_reg <= {shift_reg[6:0], miso};   // sample MISO
                    bit_cnt   <= bit_cnt + 4'd1;
                    phase     <= 1'b1;
                end else begin
                    sclk  <= 1'b0;                          // falling edge
                    phase <= 1'b0;
                    if (bit_cnt == 4'd8) begin
                        running <= 1'b0;
                        busy    <= 1'b0;
                        cs_n    <= 1'b1;
                        done    <= 1'b1;
                        rx_data <= shift_reg;
                    end else begin
                        mosi <= shift_reg[7];               // shift next bit out
                    end
                end
            end else begin
                div_cnt <= div_cnt + 16'd1;
            end
        end
    end
endmodule

// Testbench: MOSI is wired back to MISO, so every byte sent returns unchanged.
module tb_spi_loopback;
    reg        clk = 1'b0;
    reg        rst_n;
    reg        start;
    reg  [7:0] tx_data;
    wire [7:0] rx_data;
    wire       busy, done, sclk, mosi, cs_n;

    always #1 clk = ~clk;           // 2 time-unit system clock

    spi_master_mode0 #(.CLK_DIV(4)) dut (
        .clk(clk), .rst_n(rst_n), .start(start), .tx_data(tx_data),
        .rx_data(rx_data), .busy(busy), .done(done),
        .sclk(sclk), .mosi(mosi), .miso(mosi), .cs_n(cs_n)  // loopback: miso = mosi
    );

    initial begin
        rst_n = 1'b0; start = 1'b0; tx_data = 8'h00;
        #4 rst_n = 1'b1;
        @(posedge clk);
        tx_data = 8'hA5; start = 1'b1;   // send 0xA5
        @(posedge clk) start = 1'b0;
        wait (done);
        #1;
        $display("sent=0x%02h  received=0x%02h  %s",
                 8'hA5, rx_data, (rx_data == 8'hA5) ? "PASS" : "FAIL");
        #4 $finish;
    end
endmodule

