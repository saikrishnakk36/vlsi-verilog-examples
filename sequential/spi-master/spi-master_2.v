// SPI master, Mode 0 (CPOL=0, CPHA=0), with a multi-byte loopback testbench.
module spi_master_mode0 #(
    parameter CLK_DIV = 4
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    output reg        busy,
    output reg        done,
    output reg        sclk,
    output reg        mosi,
    input  wire       miso,
    output reg        cs_n
);
    localparam HALF = CLK_DIV >> 1;

    reg [15:0] div_cnt;
    reg [7:0]  shift_reg;
    reg [3:0]  bit_cnt;
    reg        phase;
    reg        running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt <= 16'd0; shift_reg <= 8'd0; bit_cnt <= 4'd0;
            phase <= 1'b0; running <= 1'b0; sclk <= 1'b0; mosi <= 1'b0;
            cs_n <= 1'b1; busy <= 1'b0; done <= 1'b0; rx_data <= 8'd0;
        end else begin
            done <= 1'b0;
            if (!running) begin
                if (start) begin
                    shift_reg <= tx_data; mosi <= tx_data[7];
                    cs_n <= 1'b0; busy <= 1'b1; running <= 1'b1;
                    sclk <= 1'b0; phase <= 1'b0; bit_cnt <= 4'd0; div_cnt <= 16'd0;
                end
            end else if (div_cnt == HALF - 1) begin
                div_cnt <= 16'd0;
                if (phase == 1'b0) begin
                    sclk <= 1'b1;
                    shift_reg <= {shift_reg[6:0], miso};
                    bit_cnt <= bit_cnt + 4'd1;
                    phase <= 1'b1;
                end else begin
                    sclk <= 1'b0; phase <= 1'b0;
                    if (bit_cnt == 4'd8) begin
                        running <= 1'b0; busy <= 1'b0; cs_n <= 1'b1;
                        done <= 1'b1; rx_data <= shift_reg;
                    end else begin
                        mosi <= shift_reg[7];
                    end
                end
            end else begin
                div_cnt <= div_cnt + 16'd1;
            end
        end
    end
endmodule

// Testbench: a small task sends one byte and waits; two bytes go back-to-back.
module tb_spi_multibyte;
    reg        clk = 1'b0;
    reg        rst_n;
    reg        start;
    reg  [7:0] tx_data;
    wire [7:0] rx_data;
    wire       busy, done, sclk, mosi, cs_n;
    integer    pass = 0;

    always #1 clk = ~clk;

    spi_master_mode0 #(.CLK_DIV(4)) dut (
        .clk(clk), .rst_n(rst_n), .start(start), .tx_data(tx_data),
        .rx_data(rx_data), .busy(busy), .done(done),
        .sclk(sclk), .mosi(mosi), .miso(mosi), .cs_n(cs_n)
    );

    task send_byte(input [7:0] b);
        begin
            @(posedge clk);
            tx_data = b; start = 1'b1;
            @(posedge clk) start = 1'b0;
            wait (done); #1;
            if (rx_data == b) pass = pass + 1;
            $display("tx=0x%02h -> rx=0x%02h  %s", b, rx_data,
                     (rx_data == b) ? "ok" : "BAD");
        end
    endtask

    initial begin
        rst_n = 1'b0; start = 1'b0; tx_data = 8'h00;
        #4 rst_n = 1'b1;
        send_byte(8'h3C);
        send_byte(8'hF0);
        $display("result: %0d/2 bytes matched", pass);
        #4 $finish;
    end
endmodule

