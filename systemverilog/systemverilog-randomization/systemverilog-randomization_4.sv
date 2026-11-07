// frame.sv - pre_randomize and post_randomize hooks
module tb;
  class Frame;
    rand bit [3:0] payload;
    bit            parity;   // derived, not randomized
    int            attempts; // bookkeeping

    function void pre_randomize();
      attempts++;
      $display("pre : attempt #%0d starting", attempts);
    endfunction

    function void post_randomize();
      parity = ^payload;      // XOR reduction = parity bit
      $display("post: payload=%b parity=%b", payload, parity);
    endfunction
  endclass

  Frame f;
  int   ok;

  initial begin
    f = new();
    for (int i = 0; i < 3; i++) begin
      ok = f.randomize();
      if (ok == 0) $display("randomize failed");
    end
    $display("total attempts = %0d", f.attempts);
    $finish;
  end
endmodule
