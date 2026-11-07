module tb;
  bit clk = 0;
  logic req;
  logic gnt;

  always #5 clk = ~clk;

  // Testbench drives req through the clocking block (output skew #1),
  // so the stimulus lands just after the edge and never races the DUT.
  default clocking drv @(posedge clk);
    default output #1;
    output req;
    input  gnt;
  endclocking

  // Simple DUT: grant follows request by one cycle.
  always @(posedge clk) gnt <= req;

  initial begin
    req = 1'b0;
    ##1 drv.req <= 1'b1;   // request on cycle 1
    ##1 drv.req <= 1'b0;   // release on cycle 2
    repeat (3) begin
      @(drv);
      $display("t=%0t req=%b gnt=%b", $time, req, drv.gnt);
    end
    $finish;
  end
endmodule
