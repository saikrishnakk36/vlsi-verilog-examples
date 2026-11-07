// single_port_ram.v
// Parameterized synchronous single-port RAM (read-first on collision).
module single_port_ram #(
    parameter DATA_WIDTH = 8,   // bits per word
    parameter ADDR_WIDTH = 4    // 2**ADDR_WIDTH words deep
) (
    input  wire                   clk,
    input  wire                   we,    // write enable
    input  wire [ADDR_WIDTH-1:0]  addr,  // shared read/write address
    input  wire [DATA_WIDTH-1:0]  din,   // write data
    output reg  [DATA_WIDTH-1:0]  dout   // registered read data
);
    // Storage: 2**ADDR_WIDTH locations, DATA_WIDTH bits each.
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;   // synchronous write
        dout <= mem[addr];      // synchronous read: returns OLD contents
    end
endmodule

// tb_single_port_ram.v
module tb_single_port_ram;
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    reg                   clk;
    reg                   we;
    reg  [ADDR_WIDTH-1:0] addr;
    reg  [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    integer i;

    single_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk), .we(we), .addr(addr), .din(din), .dout(dout)
    );

    // 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        we = 0; addr = 0; din = 0;

        // ---- WRITE phase: store 10*i + 5 into locations 0..3 ----
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            we   = 1'b1;
            addr = i[ADDR_WIDTH-1:0];
            din  = 10*i + 5;
            @(posedge clk);          // write commits here
            $display("WRITE addr=%0d din=%0d", addr, din);
        end

        // ---- READ phase: read the same locations back ----
        @(negedge clk);
        we = 1'b0;
        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            addr = i[ADDR_WIDTH-1:0];
            @(posedge clk);          // dout latches here
            #1;                      // settle after the clock edge
            $display("READ  addr=%0d dout=%0d", addr, dout);
        end

        $finish;
    end
endmodule

