// Dual-port RAM with a synchronous write port and an ASYNCHRONOUS read port.
// The read data follows raddr combinationally (no clock, zero latency).
module dp_ram_async #(
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 4
)(
  input                    clk,
  input                    we,
  input   [ADDR_WIDTH-1:0] waddr,
  input   [DATA_WIDTH-1:0] wdata,
  input   [ADDR_WIDTH-1:0] raddr,
  output  [DATA_WIDTH-1:0] rdata
);
  localparam DEPTH = 1 << ADDR_WIDTH;
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  always @(posedge clk)
    if (we)
      mem[waddr] <= wdata;

  // Asynchronous (combinational) read: no register, data available same cycle
  assign rdata = mem[raddr];
endmodule

module tb_dp_ram_async;
  localparam DW = 8, AW = 4;
  reg            clk = 1'b0;
  reg            we  = 1'b0;
  reg  [AW-1:0]  waddr = 0, raddr = 0;
  reg  [DW-1:0]  wdata = 0;
  wire [DW-1:0]  rdata;
  integer i;

  dp_ram_async #(.DATA_WIDTH(DW), .ADDR_WIDTH(AW)) dut (
    .clk(clk), .we(we), .waddr(waddr), .wdata(wdata),
    .raddr(raddr), .rdata(rdata)
  );

  always #5 clk = ~clk;  // 10 ns period

  initial begin
    // Write 0x30..0x32 into addresses 0..2
    for (i = 0; i < 3; i = i + 1) begin
      @(negedge clk);
      we    = 1'b1;
      waddr = i[AW-1:0];
      wdata = 8'h30 + i[DW-1:0];
    end
    @(negedge clk);
    we = 1'b0;

    // Asynchronous read: just set the address and look, no clock edge needed
    for (i = 0; i < 3; i = i + 1) begin
      raddr = i[AW-1:0];
      #1 $display("async read addr=%0d -> rdata=0x%02h", i, rdata);
    end
    $finish;
  end
endmodule
