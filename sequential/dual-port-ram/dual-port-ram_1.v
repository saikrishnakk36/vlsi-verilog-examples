// Simple (pseudo) dual-port RAM: one write port, one read port.
// Each port has its own clock, so the read and write sides are independent.
module dp_ram_simple #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 4
)(
  input                        wclk,
  input                        we,
  input       [ADDR_WIDTH-1:0] waddr,
  input       [DATA_WIDTH-1:0] wdata,
  input                        rclk,
  input       [ADDR_WIDTH-1:0] raddr,
  output reg  [DATA_WIDTH-1:0] rdata
);
  localparam DEPTH = 1 << ADDR_WIDTH;
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Write port
  always @(posedge wclk) begin
    if (we)
      mem[waddr] <= wdata;
  end

  // Read port: registered (synchronous) output, one-cycle latency
  always @(posedge rclk) begin
    rdata <= mem[raddr];
  end
endmodule

module tb_dp_ram_simple;
  localparam DW = 8, AW = 4;
  reg             clk = 1'b0;
  reg             we  = 1'b0;
  reg  [AW-1:0]   waddr = 0, raddr = 0;
  reg  [DW-1:0]   wdata = 0;
  wire [DW-1:0]   rdata;
  integer i;

  dp_ram_simple #(.DATA_WIDTH(DW), .ADDR_WIDTH(AW)) dut (
    .wclk(clk), .we(we), .waddr(waddr), .wdata(wdata),
    .rclk(clk), .raddr(raddr), .rdata(rdata)
  );

  always #5 clk = ~clk;  // 10 ns period

  initial begin
    // Fill addresses 0..3 with 0xA0..0xA3
    for (i = 0; i < 4; i = i + 1) begin
      @(negedge clk);
      we    = 1'b1;
      waddr = i[AW-1:0];
      wdata = 8'hA0 + i[DW-1:0];
    end
    @(negedge clk);
    we = 1'b0;

    // Read back (one-cycle latency on a registered read port)
    for (i = 0; i < 4; i = i + 1) begin
      @(negedge clk);
      raddr = i[AW-1:0];
      @(posedge clk);
      #1 $display("read  addr=%0d  rdata=0x%02h", i, rdata);
    end
    $finish;
  end
endmodule
