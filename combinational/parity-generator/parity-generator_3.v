// parity_link.v  -- transmitter + noisy channel + receiver
module parity_gen #(parameter WIDTH = 8) (
    input  wire [WIDTH-1:0] data_in,
    output wire             parity        // even parity
);
    assign parity = ^data_in;
endmodule

module parity_check #(parameter WIDTH = 8) (
    input  wire [WIDTH-1:0] data_in,
    input  wire             parity_in,
    output wire             error         // even parity
);
    assign error = ^{parity_in, data_in};  // 0 when word has even # of 1s
endmodule

// ---- testbench: clocked link with fault injection (module last) ----
module tb_parity_link;
    localparam WIDTH = 8;

    reg              clk = 0;
    reg  [WIDTH-1:0] tx_data;
    reg  [WIDTH:0]   fault;        // bit 8 = parity, bits 7:0 = data
    wire             tx_parity;

    wire [WIDTH:0]   tx_word = {tx_parity, tx_data};
    wire [WIDTH:0]   rx_word = tx_word ^ fault;   // channel flips bits in 'fault'
    wire [WIDTH-1:0] rx_data   = rx_word[WIDTH-1:0];
    wire             rx_parity = rx_word[WIDTH];
    wire             error;

    parity_gen   #(.WIDTH(WIDTH)) tx (.data_in(tx_data), .parity(tx_parity));
    parity_check #(.WIDTH(WIDTH)) rx (.data_in(rx_data), .parity_in(rx_parity), .error(error));

    always #5 clk = ~clk;

    task send;
        input [WIDTH-1:0] d;
        input [WIDTH:0]   f;
        begin
            @(negedge clk);
            tx_data = d;
            fault   = f;
            @(posedge clk);  // receiver samples here
            #1 $display("  %b       %b     %b     %b", d, f, error,
                        (|f) ? ((error) ? 1'b0 : 1'b1) : 1'b0);
        end
    endtask

    initial begin
        $display("  tx_data    fault(p,d)  error  undetected?");
        $display("  --------   ----------  -----  -----------");
        send(8'b1011_0100, 9'b0_0000_0000); // clean frame
        send(8'b1011_0100, 9'b0_0000_0001); // 1 data bit flipped
        send(8'b1011_0100, 9'b1_0000_0000); // parity bit flipped
        send(8'b0010_1101, 9'b0_0000_0011); // 2 data bits flipped
        send(8'b0010_1101, 9'b0_0000_0000); // clean frame
        $finish;
    end
endmodule
