// burst.sv - inline constraints and implication
module tb;
  class Burst;
    rand bit       is_wrap;
    rand bit [3:0] len;      // beats in the burst
    // wrapping bursts are restricted to legal power-of-two lengths
    constraint c_wrap { is_wrap -> len inside {1, 2, 4, 8}; }
  endclass

  Burst b;
  int   ok;

  initial begin
    b = new();
    // Force a wrapping burst and demand len > 2 with an inline "with" block.
    for (int i = 0; i < 4; i++) begin
      ok = b.randomize() with { is_wrap == 1; len > 2; };
      if (ok == 0) $display("randomize failed");
      $display("wrap=%0d len=%0d", b.is_wrap, b.len);
    end
    $finish;
  end
endmodule
