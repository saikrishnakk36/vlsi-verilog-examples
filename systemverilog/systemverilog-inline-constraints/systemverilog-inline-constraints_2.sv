class Transfer;
  rand bit [3:0] burst;
  constraint c_default { soft burst == 1; }
endclass

module tb;
  Transfer t = new();
  int ok;
  initial begin
    ok = t.randomize();
    $display("default    : burst=%0d", t.burst);

    ok = t.randomize() with { burst inside {[4:8]}; };
    $display("overridden : burst=%0d", t.burst);

    ok = t.randomize() with { burst == 2; };
    $display("hard set   : burst=%0d", t.burst);
    $finish;
  end
endmodule
