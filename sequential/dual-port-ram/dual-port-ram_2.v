// True dual-port RAM: two ports, each able to read AND write, sharing one array.
module tdp_ram #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 4
)(
  input                        clk,
  // Port A
  input                        we_a,
  input       [ADDR_WIDTH-1:0] addr_a,
  input       [DATA_WIDTH-1:0] din_a,
  output reg  [DATA_WIDTH-1:0] dout_a,
  // Port B
  input                        we_b,
  input       [ADDR_WIDTH-1:0] addr_b,
  input       [DATA_WIDTH-1:0] din_b,
  output reg  [DATA_WIDTH-1:0] dout_b
);
  localparam DEPTH = 1 << ADDR_WIDTH;
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Port A (read-first: dout gets the OLD contents on a write)
  always @(posedge clk) begin
    if (we_a)
      mem[addr_a] <= din_a;
    dout_a <= mem[addr_a];
  end

  // Port B (read-first)
  always @(posedge clk) begin
    if (we_b)
      mem[addr_b] <= din_b;
    dout_b <= mem[addr_b];
  end
endmodule

module tb_tdp_ram;
  localparam DW = 8, AW = 4;
  reg            clk = 1'b0;
  reg            we_a = 0, we_b = 0;
  reg  [AW-1:0]  addr_a = 0, addr_b = 0;
  reg  [DW-1:0]  din_a = 0, din_b = 0;
  wire [DW-1:0]  dout_a, dout_b;

  tdp_ram #(.DATA_WIDTH(DW), .ADDR_WIDTH(AW)) dut (
    .clk(clk),
    .we_a(we_a), .addr_a(addr_a), .din_a(din_a), .dout_a(dout_a),
    .we_b(we_b), .addr_b(addr_b), .din_b(din_b), .dout_b(dout_b)
  );

  always #5 clk = ~clk;  // 10 ns period

  initial begin
    // Cycle 1: Port A writes 0x11 -> addr 2, Port B writes 0x22 -> addr 5
    @(negedge clk);
    we_a = 1; addr_a = 2; din_a = 8'h11;
    we_b = 1; addr_b = 5; din_b = 8'h22;

    // Cycle 2: Port A reads addr 5, Port B reads addr 2 (cross read-back)
    @(negedge clk);
    we_a = 0; addr_a = 5;
    we_b = 0; addr_b = 2;

    // Let the reads register out
    @(posedge clk);
    #1 $display("A reads addr5 -> 0x%02h   B reads addr2 -> 0x%02h", dout_a, dout_b);

    // Cycle 3: both ports write different data to the SAME address (6)
    @(negedge clk);
    we_a = 1; addr_a = 6; din_a = 8'hAA;
    we_b = 1; addr_b = 6; din_b = 8'hBB;  // write-write conflict: result is racey

    @(negedge clk);
    we_a = 0; addr_a = 6;
    we_b = 0; addr_b = 6;
    @(posedge clk);
    #1 $display("addr6 after same-address write: dout_a=0x%02h dout_b=0x%02h", dout_a, dout_b);

    $finish;
  end
endmodule
