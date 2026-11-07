// SPI master, Mode 0, used to show how CLK_DIV sets the SCLK rate.
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

// Testbench: two masters, same clock, different CLK_DIV. The slower divider
// takes proportionally longer to clock the same byte out.
module tb_spi_divider;
    reg        clk = 1'b0;
    reg        rst_n;
    reg        start;
    reg  [7:0] tx_data;
    wire [7:0] rx_a, rx_b;
    wire       busy_a, busy_b, done_a, done_b;
    wire       sclk_a, mosi_a, cs_a, sclk_b, mosi_b, cs_b;
    integer    t_a, t_b;

    always #1 clk = ~clk;

    spi_master_mode0 #(.CLK_DIV(4)) fast (
        .clk(clk), .rst_n(rst_n), .start(start), .tx_data(tx_data),
        .rx_data(rx_a), .busy(busy_a), .done(done_a),
        .sclk(sclk_a), .mosi(mosi_a), .miso(mosi_a), .cs_n(cs_a));

    spi_master_mode0 #(.CLK_DIV(12)) slow (
        .clk(clk), .rst_n(rst_n), .start(start), .tx_data(tx_data),
        .rx_data(rx_b), .busy(busy_b), .done(done_b),
        .sclk(sclk_b), .mosi(mosi_b), .miso(mosi_b), .cs_n(cs_b));

    initial begin : stim
        rst_n = 1'b0; start = 1'b0; tx_data = 8'h5A;
        #4 rst_n = 1'b1;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk) start = 1'b0;
    end

    initial begin : watch
        @(posedge done_a); t_a = $time;
        $display("CLK_DIV=4   done at t=%0d, rx=0x%02h",  t_a, rx_a);
    end

    initial begin : finish_up
        @(posedge done_b); t_b = $time;
        $display("CLK_DIV=12  done at t=%0d, rx=0x%02h",  t_b, rx_b);
        $display("slow/fast transfer-time ratio = %0d:%0d", t_b, t_a);
        #4 $finish;
    end
endmodule

