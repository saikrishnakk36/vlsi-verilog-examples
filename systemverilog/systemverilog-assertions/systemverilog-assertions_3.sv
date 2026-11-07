// ex3_handshake.sv  --  an "if-then" invariant, the idea behind |->
module tb;
  logic clk = 0;
  logic req, ack;

  always #5 clk = ~clk;

  // Stimulus: ack is only ever raised while req is high (legal protocol).
  initial begin
    req = 0; ack = 0;
    for (int i = 0; i < 12; i++) begin
      @(negedge clk);
      req = $urandom_range(0, 1);
      ack = req ? $urandom_range(0, 1) : 1'b0;  // ack implies req
    end
  end

  // Checker: sample after each rising edge and assert the implication by hand.
  int checks = 0;
  initial begin
    repeat (12) begin
      @(posedge clk);
      #1;
      // "ack high -> req high": only meaningful when ack is high.
      if (ack)
        assert (req)
          else $error("protocol violation @%0t: ack without req", $time);
      checks++;
    end
    $display("Handshake invariant held on %0d sampled cycles.", checks);
    $finish;
  end
endmodule
