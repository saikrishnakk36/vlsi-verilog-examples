// dice.sv - rand vs randc
module tb;
  class Dice;
    rand  bit [2:0] a;   // may repeat freely
    randc bit [2:0] b;   // visits all 8 values before repeating
    constraint c_a { a inside {[1:6]}; }
  endclass

  Dice d;
  int  ok;

  initial begin
    d = new();
    $display("iter | rand a | randc b");
    for (int i = 0; i < 8; i++) begin
      ok = d.randomize();
      if (ok == 0) $display("randomize failed at iter %0d", i);
      $display("  %0d  |   %0d    |   %0d", i, d.a, d.b);
    end
    $finish;
  end
endmodule
