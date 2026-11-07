// ex2_counter.sv  --  immediate assertions inside a clocked checker
module tb;
  logic clk = 0, rst_n;
  logic [3:0] count;

  always #5 clk = ~clk;   // 10 ns clock

  // DUT: a modulo-16 up counter with active-low reset
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) count <= 4'd0;
    else        count <= count + 4'd1;

  // Reference model kept in the testbench
  logic [3:0] expect_count;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) expect_count <= 4'd0;
    else        expect_count <= expect_count + 4'd1;

  initial begin
    rst_n = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;

    // Check the invariant once per cycle, just after the clock edge settles.
    repeat (20) begin
      @(posedge clk);
      #1;  // let non-blocking updates settle before sampling
      assert (count == expect_count)
        else $error("mismatch @%0t: count=%0d expected=%0d",
                    $time, count, expect_count);
    end

    $display("Counter matched reference for 20 cycles. count=%0d", count);
    $finish;
  end
endmodule
