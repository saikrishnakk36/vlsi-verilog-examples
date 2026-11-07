// spi_slave.v  -  SPI slave, mode 0 (CPOL=0, CPHA=0), 8-bit, MSB first
// Receive shift register sampled on rising SCLK; transmit MUX changes on
// falling SCLK; cs_n frames one 8-bit transaction.
module spi_slave (
    input  wire        sclk,     // SPI clock from the master (mode 0)
    input  wire        cs_n,     // active-low chip select / frame
    input  wire        mosi,     // master-out slave-in
    output wire        miso,     // master-in slave-out (tri-stated when idle)
    input  wire [7:0]  tx_data,  // byte this slave shifts back, MSB first
    output reg  [7:0]  rx_data,  // last fully received byte
    output reg         rx_valid  // high after a complete byte
);
    reg [2:0] rxcnt;             // counts the 8 sampled bits
    reg [2:0] txbit;             // index of the bit currently on MISO
    reg [7:0] rxsh;              // receive shift register

    // Transmit: present MSB first, advance on each falling SCLK edge.
    assign miso = cs_n ? 1'bz : tx_data[3'd7 - txbit];

    always @(negedge sclk or posedge cs_n) begin
        if (cs_n)
            txbit <= 3'd0;             // idle: point back at the MSB
        else
            txbit <= txbit + 3'd1;     // shift out on the falling edge
    end

    // Receive: sample MOSI on the rising edge, shift in MSB first.
    always @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            rxcnt <= 3'd0;             // deasserting CS ends the frame
        end else begin
            rxsh <= {rxsh[6:0], mosi};
            if (rxcnt == 3'd7) begin
                rx_data  <= {rxsh[6:0], mosi};
                rx_valid <= 1'b1;
                rxcnt    <= 3'd0;
            end else begin
                if (rxcnt == 3'd0) rx_valid <= 1'b0;
                rxcnt <= rxcnt + 3'd1;
            end
        end
    end
endmodule

// tb_spi_slave.v  -  a mode-0 SPI master drives one byte per frame
module tb_spi_slave;
    reg        sclk, cs_n, mosi;
    wire       miso;
    reg  [7:0] tx_data;
    wire [7:0] rx_data;
    wire       rx_valid;

    reg  [7:0] mosi_byte;   // byte the master sends to the slave
    reg  [7:0] miso_byte;   // byte the master reads back from the slave
    integer    k;

    spi_slave dut (
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .miso(miso),
        .tx_data(tx_data), .rx_data(rx_data), .rx_valid(rx_valid)
    );

    // Clock one byte: CS low, 8 SCLK pulses, MSB first, CS high.
    task spi_byte(input [7:0] data);
        begin
            mosi_byte = data;
            cs_n = 1'b0;             // start the frame
            mosi = mosi_byte[7];     // MSB valid before the first edge
            #10;
            for (k = 0; k < 8; k = k + 1) begin
                sclk = 1'b1;  #10;                  // rising: both sample
                miso_byte = {miso_byte[6:0], miso};
                sclk = 1'b0;                        // falling: change data
                if (k < 7) mosi = mosi_byte[6-k];
                #10;
            end
            cs_n = 1'b1;             // end the frame
            #10;
        end
    endtask

    initial begin
        sclk = 1'b0; mosi = 1'b0; miso_byte = 8'h00;
        cs_n = 1'b0; tx_data = 8'hA5;   // settle, then raise CS to arm slave
        #10 cs_n = 1'b1;
        #10;

        spi_byte(8'h3C);                // master sends 0x3C, slave returns 0xA5
        $display("Frame 1: slave rx=0x%02h valid=%b | master rx=0x%02h",
                 rx_data, rx_valid, miso_byte);

        tx_data = 8'h5A;                // queue the next response while idle
        spi_byte(8'hF0);                // master sends 0xF0, slave returns 0x5A
        $display("Frame 2: slave rx=0x%02h valid=%b | master rx=0x%02h",
                 rx_data, rx_valid, miso_byte);

        #20 $finish;
    end
endmodule
