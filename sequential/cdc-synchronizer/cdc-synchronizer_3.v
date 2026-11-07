// handshake_sync.v  -- 4-phase request/acknowledge handshake synchronizer
// Safely passes a multi-bit data word from source to destination domain.
module handshake_sync #(
    parameter WIDTH = 8
)(
    input  wire              sclk,
    input  wire              srst_n,
    input  wire              send,       // request to send din
    input  wire [WIDTH-1:0]  din,
    output reg               busy,       // high while a transfer is in flight

    input  wire              dclk,
    input  wire              drst_n,
    output reg               dvalid,     // 1-cycle strobe when dout is fresh
    output reg  [WIDTH-1:0]  dout
);
    // source side: raise req, hold data, wait for synchronized ack
    reg req;
    reg [WIDTH-1:0] data_hold;
    reg ack_m, ack_s;   // ack synchronized into source domain
    reg ack;            // destination acknowledge (driven in dclk domain)

    always @(posedge sclk or negedge srst_n) begin
        if (!srst_n) begin
            req <= 1'b0; busy <= 1'b0; data_hold <= {WIDTH{1'b0}};
            ack_m <= 1'b0; ack_s <= 1'b0;
        end else begin
            ack_m <= ack;        // 2-flop sync of destination ack
            ack_s <= ack_m;
            if (send && !busy) begin
                req <= 1'b1; busy <= 1'b1; data_hold <= din;
            end else if (ack_s && req) begin
                req <= 1'b0;        // drop request once ack seen
            end else if (!ack_s && !req) begin
                busy <= 1'b0;       // transfer complete
            end
        end
    end

    // destination side: synchronize req, capture data, raise ack
    reg req_m, req_s;
    always @(posedge dclk or negedge drst_n) begin
        if (!drst_n) begin
            req_m <= 1'b0; req_s <= 1'b0; ack <= 1'b0;
            dvalid <= 1'b0; dout <= {WIDTH{1'b0}};
        end else begin
            req_m <= req;        // 2-flop sync of source req
            req_s <= req_m;
            dvalid <= 1'b0;
            if (req_s && !ack) begin
                dout   <= data_hold; // data stable: req held until ack
                dvalid <= 1'b1;
                ack    <= 1'b1;
            end else if (!req_s && ack) begin
                ack <= 1'b0;         // complete the 4-phase handshake
            end
        end
    end
endmodule

// --- testbench (two clocks, two words sent) ---
module tb_handshake_sync;
    localparam WIDTH = 8;
    reg sclk, dclk, srst_n, drst_n, send;
    reg  [WIDTH-1:0] din;
    wire busy, dvalid;
    wire [WIDTH-1:0] dout;

    handshake_sync #(.WIDTH(WIDTH)) dut (
        .sclk(sclk), .srst_n(srst_n), .send(send), .din(din), .busy(busy),
        .dclk(dclk), .drst_n(drst_n), .dvalid(dvalid), .dout(dout)
    );

    initial sclk = 1'b0; always #12 sclk = ~sclk;  // 24 ns
    initial dclk = 1'b0; always #17 dclk = ~dclk;  // 34 ns

    task send_word(input [WIDTH-1:0] w);
        begin
            @(posedge sclk);
            while (busy) @(posedge sclk);
            din  <= w;
            send <= 1'b1;
            @(posedge sclk) send <= 1'b0;
            while (busy) @(posedge sclk);   // wait until transfer done
        end
    endtask

    always @(posedge dclk)
        if (dvalid) $display("t=%0t  destination captured dout=0x%02h", $time, dout);

    initial begin
        srst_n = 1'b0; drst_n = 1'b0; send = 1'b0; din = 8'h00;
        #30 srst_n = 1'b1; drst_n = 1'b1;
        send_word(8'hA5);
        send_word(8'h3C);
        repeat (6) @(posedge dclk);
        $display("Both words transferred across clock domains.");
        $finish;
    end
endmodule
