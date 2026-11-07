module tb;
  logic clk = 0;
  logic [3:0] count;

  always #5 clk = ~clk;

  // Sampling clocking block: input skew #1step reads the value
  // stabilised just before each posedge, never the mid-cycle churn.
  clocking sample_cb @(posedge clk);
    default input #1step;
    input count;
  endclocking

  // DUT-like free-running counter.
  always @(posedge clk) count <= count + 1'b1;

  initial begin
    count = 4'd0;
    repeat (4) begin
      @(sample_cb);
      $display("t=%0t sampled count=%0d", $time, sample_cb.count);
    end
    $finish;
  end
endmodule
