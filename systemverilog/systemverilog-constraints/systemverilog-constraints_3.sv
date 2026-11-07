module tb;
  class Addr;
    rand bit        use_high;
    rand bit [7:0]  addr;

    // Without a hint, the solver treats {use_high, addr} as one space,
    // making use_high==1 rare. solve...before makes the tool pick
    // use_high first, so both halves of the map are exercised evenly.
    constraint c_map {
      if (use_high) addr inside {[200:255]};
      else          addr inside {[0:63]};
    }
    constraint c_order { solve use_high before addr; }
  endclass

  Addr a;
  int high_cnt;

  initial begin
    a = new();
    for (int i = 0; i < 10; i++) begin
      if (a.randomize() == 0) $fatal(1, "randomize failed");
      if (a.use_high) high_cnt++;
    end
    $display("use_high chosen %0d/10 times (solve-before balances it)", high_cnt);

    for (int i = 0; i < 4; i++) begin
      if (a.randomize() with { use_high == 1; addr < 220; } == 0)
        $fatal(1, "inline randomize failed");
      $display("inline draw %0d: use_high=%0d addr=%0d", i, a.use_high, a.addr);
    end
    $finish;
  end
endmodule
